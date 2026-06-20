# AI Service Integration Guide

This document describes the contract between the Flexio backend
(Node.js, on EC2) and the AI analysis service (Python, to be built).
Anyone building the Python service can read this doc and have
everything they need.

## Purpose

After a patient finishes a rehabilitation session, sensor waveforms
(EMG, IMU) are written to S3 and session metadata is written to
DynamoDB. The backend fires a webhook to the AI service asking it
to analyze the session and produce a structured report. The doctor
sees the report in the Flexio app.

## Architecture
The AI service runs on the same EC2 instance as the backend. They
communicate over localhost. The AI service downloads waveform CSVs
from S3 using the EC2 instance's IAM role (no AWS credentials needed
in the AI service code).

## What you need to build

A small HTTP service (Flask, FastAPI, anything you prefer) that:

  1. Exposes `POST /process` and accepts incoming jobs
  2. Downloads waveform CSVs from S3 based on the job's S3 key
  3. Computes metrics from the CSVs
  4. Calls an LLM API to produce summary, observations, concerns,
     recommendations
  5. POSTs the structured report back to the backend's PATCH endpoint
  6. Responds 200 immediately on the inbound POST — do not block

The service listens on `localhost:8000` by convention. Run it as a
separate process from the Node backend (PM2 can manage both).

## The inbound request — what your service receives

```http
POST /process
Content-Type: application/json

{
  "sessionId": "sess_b59ead5e-...",
  "patientId": "1773960006547",
  "waveformS3Key": "sessions/1773960006547/sess_b59ead5e-.../",
  "callbackUrl": "https://flexio-rehab.duckdns.org/api/sessions/sess_b59ead5e-.../report",
  "serviceToken": "the-shared-secret-string"
}
```

Fields:

  - **sessionId**: the unique session ID. Use it to identify the
    session everywhere.
  - **patientId**: the user ID of the patient.
  - **waveformS3Key**: the S3 prefix where the CSV files live. Three
    files are inside this prefix:
        emg.csv
        imu.csv
        events.json
  - **callbackUrl**: the backend URL where you must PATCH your final
    report. Includes the protocol (https) and full path.
  - **serviceToken**: send this back in the `X-Service-Token` header
    when you PATCH the callbackUrl. The backend uses it to verify
    the request came from a legitimate AI service.

Respond `200 OK` immediately. Do the actual work asynchronously.

## The S3 waveform files

The S3 bucket is `flexio-smart-waveforms` in eu-north-1. Use boto3
with the default credentials chain — the EC2 IAM role will be
picked up automatically.

```python
import boto3
s3 = boto3.client("s3", region_name="eu-north-1")
BUCKET = "flexio-smart-waveforms"

emg_key = f"{waveform_s3_key}emg.csv"
obj = s3.get_object(Bucket=BUCKET, Key=emg_key)
emg_data = obj["Body"].read().decode("utf-8")
```

### emg.csv structure

Columns: `timestamp_ms,channel,value`
- `timestamp_ms` is epoch milliseconds.
- `channel` is `"emg1"` or `"emg2"` — there are exactly two EMG
  channels in the system.
- `value` is a normalized float (typically 0.0 to 1.0).
- Samples come at approximately 50 Hz per channel.

### imu.csv structure

Columns: `timestamp_ms,kneeAngle,thigh1_gx,thigh1_gy,thigh1_gz,shin1_gx,shin1_gy,shin1_gz`


- One row per IMU sample (~50 Hz).
- `kneeAngle` is the computed joint angle in degrees, derived from
  the two IMUs on-device.
- `thigh1_*` is gravity vector from the thigh-mounted IMU.
- `shin1_*` is gravity vector from the shin-mounted IMU.
- There are two IMUs total (one thigh, one shin), not two of each.

### events.json structure

```json
[
  {
    "type": "verbal_stop",
    "timestamp": "2026-06-19T14:32:18.450Z",
    "atSecond": 145.2,
    "confidence": 0.92
  },
  {
    "type": "abnormal_motion",
    "timestamp": "2026-06-19T14:33:01.200Z",
    "atSecond": 188.0,
    "confidence": 0.78
  }
]
```

Sparse events that occurred during the session. May be empty `[]`.

## Metrics to compute

Compute these from the CSVs before calling the LLM:

  - **duration_seconds** — last timestamp minus first
  - **rangeOfMotion** per IMU — min, max, average kneeAngle across
    the session (you may need to compute separate left/right knee
    angles if applicable; for now, treat kneeAngle as the single
    joint metric, with imu1 = thigh-side view and imu2 = shin-side
    view of the same joint)
  - **peakEmg** per channel — peak amplitude (max abs value) and
    RMS (root mean square) over the full session
  - **muscleSymmetry** — score from 0 to 1, calculated as
    `min(peakEmg1.peak, peakEmg2.peak) / max(peakEmg1.peak, peakEmg2.peak)`
  - **fatigueIndex** per channel — proxy for muscle fatigue. Simplest:
    ratio of mean EMG amplitude in the last 20% of session vs the
    first 20%. Refine as you wish.
  - **repetitionsCompleted** — approximate. Count zero-crossings or
    peaks in the kneeAngle signal. Rough is OK.

These are NUMERICAL fields. Do not ask the LLM to compute them.
Compute them in Python and pass them to the LLM as context.

## Calling the LLM

Use whichever provider you prefer (Claude, OpenAI, Gemini). The LLM
produces the **prose** parts of the report: `summary`, `observations`,
`concerns`, `recommendations`. The metrics you already computed.

A starting prompt structure:
You are a physical therapy session analyzer. Given the metrics from

a knee rehabilitation session, write a brief professional report

for the patient's doctor.
Session metrics:

Duration: {duration_min} minutes
Range of motion (IMU 1, thigh): {min}° to {max}° (avg {avg}°)
Range of motion (IMU 2, shin): {min}° to {max}° (avg {avg}°)
Peak EMG channel 1: {peak} (RMS {rms})
Peak EMG channel 2: {peak} (RMS {rms})
Muscle symmetry: {score}
Fatigue index channel 1: {fc1}
Fatigue index channel 2: {fc2}
Repetitions: {reps}
Safety events: {events_summary}

Patient context (if available):

Diagnosis: {diagnosis}
Rehabilitation goal: {goal}
Session number: {n}

Produce ONLY valid JSON matching this schema. No prose outside JSON.
{

"summary": "1-2 paragraph summary for the doctor",

"observations": ["short clinical observation", ...],

"concerns": [{"severity": "low|medium|high", "type": "...", "description": "..."}],

"recommendations": ["actionable suggestion", ...]

}
Guidelines:

Use clinical but accessible language.
Flag muscle symmetry below 0.85 as a low or medium concern.
Flag fatigue index above 0.6 in either channel as a concern.
Flag any safety events as a concern with appropriate severity.
Do not invent metrics that aren't given to you.
Keep observations to 2-5 items, recommendations to 2-4.

Refine this over time.

## The callback — what your service sends back

When you're done, PATCH the callbackUrl with:

```http
PATCH https://flexio-rehab.duckdns.org/api/sessions/sess_b59ead5e-.../report
Content-Type: application/json
X-Service-Token: <serviceToken from the inbound payload>

{
  "report": {
    "generatedAt": "2026-06-19T20:30:00Z",
    "model": "claude-sonnet-4-7",
    "summary": "Patient completed a 30-minute knee flexion session with good range of motion and mild fatigue indicators...",
    "metrics": {
      "duration": { "value": 1800, "unit": "seconds" },
      "rangeOfMotion": {
        "imu1": { "min": 12.4, "max": 87.3, "average": 56.1 },
        "imu2": { "min": 13.1, "max": 85.7, "average": 55.4 },
        "unit": "degrees"
      },
      "peakEmg": {
        "emg1": { "peak": 0.87, "rms": 0.42 },
        "emg2": { "peak": 0.92, "rms": 0.48 },
        "unit": "normalized"
      },
      "muscleSymmetry": { "score": 0.93, "interpretation": "balanced" },
      "fatigueIndex": {
        "emg1": 0.31,
        "emg2": 0.38,
        "interpretation": "low"
      },
      "repetitionsCompleted": 24
    },
    "observations": [
      "Range of motion improved compared to previous session.",
      "Mild EMG asymmetry observed at peak contractions."
    ],
    "concerns": [
      {
        "severity": "low",
        "type": "asymmetry",
        "description": "Mild EMG asymmetry within normal variance."
      }
    ],
    "recommendations": [
      "Continue current exercise routine.",
      "Monitor for fatigue patterns in the next session."
    ],
    "safetyEvents": [
      {
        "type": "verbal_stop",
        "timestamp": "2026-06-19T20:14:23Z",
        "atSecond": 1080,
        "context": "Patient verbally requested stop."
      }
    ]
  }
}
```

Important:

  - `metrics` should reflect the actual values you computed.
  - `safetyEvents` should mirror `events.json` (you can enhance the
    `context` field with LLM-generated phrasing).
  - `model` should be the actual model ID you called (e.g.
    `"claude-sonnet-4-7"`, `"gpt-4o-mini"`, `"gemini-1.5-pro"`).
  - `generatedAt` is the ISO timestamp when you finished generation.

If anything goes wrong (S3 download failure, LLM error, malformed
output), PATCH with an error instead:

```http
PATCH .../report
X-Service-Token: ...

{
  "error": "LLM returned malformed JSON: <details>"
}
```

The backend will mark the session's reportStatus as "failed" with
your error message. The doctor will see a retry button.

## Service token

The `serviceToken` value comes from the inbound payload. Echo it
back in the `X-Service-Token` header. Don't hardcode it. Don't log
it. Don't commit it.

For local dev, you can read it from an environment variable that's
the same on both Node and Python sides:

```python
SERVICE_TOKEN = os.environ["AI_SERVICE_TOKEN"]
```

## Running the service

For local development:

```bash
python ai_service.py
# or
uvicorn ai_service:app --host 0.0.0.0 --port 8000
```

In production (on EC2), use PM2 to manage the Python process
alongside the Node backend:

```bash
pm2 start ai_service.py --interpreter python3 --name ai-service
pm2 save
```

The Node backend will call `http://localhost:8000/process` when
the env var `USE_FAKE_REPORTS=false` is set. While the AI service
is being built, that flag stays `true` and the Node backend uses
the local fake generator.

## Flipping the switch

When your service is ready and tested, on the EC2 instance:

  1. SSH in
  2. Edit `~/Graduation_Project_2026/backend/.env`
  3. Change `USE_FAKE_REPORTS=true` to `USE_FAKE_REPORTS=false`
  4. Restart Node: `pm2 restart flexio-backend`
  5. Start your service: `pm2 start ai_service.py ...`
  6. Test by ending a session — the report should be generated by
     your real service, identifiable by `model` in the response

If anything breaks, flip back to `USE_FAKE_REPORTS=true` and the
fake generator takes over with no other changes.

## Things to discuss before building

  - Which LLM provider? Each has different pricing, latency, and
    free tier limits. Pick one before writing code.
  - Where do LLM API keys live? Suggest using AWS Secrets Manager
    or a local `.env` (never commit). The Node side does NOT need
    LLM keys — only the Python service does.
  - How are LLM errors retried? Suggest: one retry on transient
    failure, then fail with a clear error.
  - How long does generation take? If it's >60 seconds, the
    backend's session-end response won't be affected (it's fire-
    and-forget), but the doctor's UI will poll for a while.
  - Should the service cache prompts/responses? Probably not for
    medical data — every session is unique.

## Open questions

  - Should the metrics computation live in this service or be
    extracted into a shared library? For now: live here.
  - Should the LLM see waveforms directly, or only the computed
    metrics? Computed metrics only — the waveforms are too large
    and don't fit cleanly in a text prompt.
  - Patient context (diagnosis, goal) — how do we get it? Either
    the inbound payload includes it, or this service fetches it
    from the backend via a `GET /api/patients/:id/context`
    endpoint. To be designed.