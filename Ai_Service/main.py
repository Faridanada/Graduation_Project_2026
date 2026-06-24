"""
main.py — FastAPI app for Flexio Smart AI report service.

Endpoints:
  POST /process — receive a session-ended webhook, process async,
                   PATCH the report back to the Node backend
  GET /healthz  — basic health check
"""

import asyncio
import logging
import os
import time
from typing import Optional

import httpx
import numpy as np
import uvicorn
from dotenv import load_dotenv
from fastapi import FastAPI, BackgroundTasks
from pydantic import BaseModel

load_dotenv()

logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO"),
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger("ai_service")

from s3_loader import download_session_csvs
from adapter import emg_df_to_array, imu_df_to_array, resample_to, EMG_TRAINING_FS, IMU_TRAINING_FS
from classifier import classify_session
from llm import generate_llm_summary
from metrics import compute_metrics
from report_builder import build_report


app = FastAPI(title="Flexio AI Report Service", version="1.0.0")


class ProcessJob(BaseModel):
    sessionId: str
    patientId: str
    waveformS3Key: str
    callbackUrl: str
    serviceToken: str


@app.get("/healthz")
def healthz():
    return {"ok": True, "service": "flexio-ai", "version": "1.0.0"}


@app.post("/process")
def process(job: ProcessJob, background: BackgroundTasks):
    """
    Acknowledge immediately, do the real work in the background.
    """
    logger.info(f"[process] received job {job.sessionId}")
    background.add_task(_handle, job.model_dump())
    return {"accepted": True, "sessionId": job.sessionId}


# ---------- worker ----------

async def _patch_back(callback_url: str, service_token: str, payload: dict):
    headers = {"X-Service-Token": service_token, "Content-Type": "application/json"}
    timeout = httpx.Timeout(30.0, connect=10.0)
    async with httpx.AsyncClient(timeout=timeout) as client:
        try:
            r = await client.patch(callback_url, headers=headers, json=payload)
            logger.info(f"[patch] {callback_url} -> {r.status_code}")
            if r.status_code >= 400:
                logger.error(f"[patch] response: {r.text[:500]}")
        except Exception as e:
            logger.exception(f"[patch] failed: {e}")


def _handle(job: dict):
    """Synchronous wrapper so BackgroundTasks can call it."""
    asyncio.run(_handle_async(job))


async def _handle_async(job: dict):
    session_id = job["sessionId"]
    s3_key = job["waveformS3Key"]
    callback_url = job["callbackUrl"]
    service_token = job["serviceToken"]

    t0 = time.time()
    logger.info(f"[{session_id}] processing")

    try:
        emg_df, imu_df, events = download_session_csvs(s3_key)
        t_dl = time.time()
        logger.info(f"[{session_id}] downloaded CSVs in {t_dl - t0:.2f}s")

        if emg_df is None or imu_df is None or len(emg_df) == 0 or len(imu_df) == 0:
            await _patch_back(callback_url, service_token, {
                "error": "Session waveforms are empty or missing in S3."
            })
            return

        # ---- metrics from raw CSVs (always computed) ----
        # Estimate IMU sample rate for rep detection
        try:
            ts = imu_df["timestamp_ms"].to_numpy()
            diffs = np.diff(np.sort(ts))
            diffs = diffs[diffs > 0]
            fs_imu = 1000.0 / float(np.median(diffs)) if len(diffs) else 0.0
        except Exception:
            fs_imu = 0.0

        metrics = compute_metrics(emg_df, imu_df, events, fs_imu)
        session_start = float(min(emg_df["timestamp_ms"].min(), imu_df["timestamp_ms"].min()))
        t_metrics = time.time()
        logger.info(f"[{session_id}] metrics computed in {t_metrics - t_dl:.2f}s")

        # ---- classifier (optional) ----
        classification = None
        try:
            emg_arr, emg_fs = emg_df_to_array(emg_df)
            imu_arr, imu_fs = imu_df_to_array(imu_df)

            # Upsample to training rates
            emg_resampled = resample_to(emg_arr, emg_fs, EMG_TRAINING_FS)
            imu_resampled = resample_to(imu_arr, imu_fs, IMU_TRAINING_FS)

            logger.info(
                f"[{session_id}] EMG: {emg_arr.shape} @{emg_fs:.1f}Hz -> "
                f"{emg_resampled.shape} @{EMG_TRAINING_FS:.1f}Hz; "
                f"IMU: {imu_arr.shape} @{imu_fs:.1f}Hz -> "
                f"{imu_resampled.shape} @{IMU_TRAINING_FS:.1f}Hz"
            )

            classification = classify_session(emg_resampled, imu_resampled)
            t_cls = time.time()
            logger.info(
                f"[{session_id}] classification {classification} "
                f"in {t_cls - t_metrics:.2f}s"
            )
        except Exception as e:
            logger.exception(f"[{session_id}] classifier failed: {e}")
            classification = None

        # ---- optional LLM analysis ----
        llm_summary = None
        if classification:
            llm_payload = {
                "classification": classification,
                "metrics": metrics,
                "events": events,
            }
            llm_summary = generate_llm_summary(llm_payload)

        # ---- build report ----
        report = build_report(metrics, events, session_start, classification, llm_summary)
        await _patch_back(callback_url, service_token, {"report": report})
        logger.info(f"[{session_id}] done in {time.time() - t0:.2f}s")

    except Exception as e:
        logger.exception(f"[{session_id}] processing failed: {e}")
        try:
            await _patch_back(callback_url, service_token, {
                "error": f"AI service error: {e}"[:500]
            })
        except Exception:
            pass


if __name__ == "__main__":
    port = int(os.getenv("AI_SERVICE_PORT", "8000"))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=False)