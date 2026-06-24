"""
report_builder.py — Assembles the final report JSON the doctor sees.
Pure templating from metrics + optional SVM classification.
"""

from datetime import datetime, timezone
from typing import Optional


def _now_iso():
    return datetime.now(timezone.utc).isoformat()


def _format_event(event, session_start_ms):
    ts_ms = event.get("ts") or event.get("timestamp_ms") or 0
    at_sec = max(0.0, (float(ts_ms) - float(session_start_ms)) / 1000.0)
    return {
        "type": event.get("type") or event.get("event") or "event",
        "timestamp": datetime.fromtimestamp(ts_ms / 1000.0, tz=timezone.utc).isoformat()
        if ts_ms else _now_iso(),
        "atSecond": round(at_sec, 1),
        "context": event.get("detail") or event.get("context") or "Event recorded.",
    }


def build_report(
    metrics: dict,
    events: list,
    session_start_ms: float,
    classification: Optional[dict] = None,
    llm_summary: Optional[str] = None,
) -> dict:
    """
    Build the report JSON the backend stores.

    classification: optional dict from classifier.classify_session():
      {label, confidence, window_count, correct_windows, model_version}
    """
    dur = metrics.get("duration", {}).get("value", 0)
    rom_avg = metrics.get("rangeOfMotion", {}).get("imu1", {}).get("average", 0.0)
    rom_min = metrics.get("rangeOfMotion", {}).get("imu1", {}).get("min", 0.0)
    rom_max = metrics.get("rangeOfMotion", {}).get("imu1", {}).get("max", 0.0)
    peak_e1 = metrics.get("peakEmg", {}).get("emg1", {}).get("peak", 0.0)
    peak_e2 = metrics.get("peakEmg", {}).get("emg2", {}).get("peak", 0.0)
    sym = metrics.get("muscleSymmetry", {})
    sym_score = sym.get("score", 0.0)
    sym_interp = sym.get("interpretation", "balanced")
    fat = metrics.get("fatigueIndex", {})
    reps = metrics.get("repetitionsCompleted")

    duration_min = dur / 60.0

    # Summary
    if classification:
        cls_label = classification["label"]
        cls_conf_pct = classification["confidence"] * 100
        cls_phrase = (
            f"AI classifier rated the form as {cls_label} "
            f"(confidence {cls_conf_pct:.0f}%)."
        )
    else:
        cls_phrase = ""

    if reps and reps >= 3:
        summary = (
            f"Patient completed a {duration_min:.0f}-minute session with "
            f"{reps} repetitions. Range of motion averaged "
            f"{rom_avg:.1f}° with peak EMG values of {peak_e1:.2f} and "
            f"{peak_e2:.2f}. Muscle symmetry was {sym_interp} "
            f"({sym_score * 100:.0f}%). {cls_phrase}"
        ).strip()
    else:
        summary = (
            f"Patient completed a {duration_min:.0f}-minute session. "
            f"Range of motion averaged {rom_avg:.1f}°. Peak EMG was "
            f"{peak_e1:.2f} (channel 1) and {peak_e2:.2f} (channel 2). "
            f"{cls_phrase}"
        ).strip()

    # Observations
    observations = [
        f"Session duration: {duration_min:.0f} minutes.",
        f"Average knee angle: {rom_avg:.1f}° (min {rom_min:.1f}°, max {rom_max:.1f}°).",
    ]
    if reps:
        observations.append(f"{reps} repetitions detected from motion signal.")
    if sym_score and sym_score < 0.85:
        observations.append(
            f"Muscle activation showed {sym_interp} between channels."
        )
    fat_max = max(float(fat.get("emg1", 0)), float(fat.get("emg2", 0)))
    if fat_max > 0.3:
        observations.append(
            f"Fatigue indicators rose by {fat_max * 100:.0f}% over the session."
        )
    if classification:
        observations.append(
            f"AI form classification: {classification['label']} "
            f"({classification['correct_windows']}/{classification['window_count']} "
            f"windows correct)."
        )

    # Concerns
    concerns = []
    if sym_score and sym_score < 0.70:
        concerns.append({
            "severity": "medium",
            "type": "asymmetry",
            "description": "Significant muscle asymmetry detected. "
                           "Consider evaluating compensation patterns.",
        })
    elif sym_score and 0.70 <= sym_score < 0.85:
        concerns.append({
            "severity": "low",
            "type": "asymmetry",
            "description": "Mild muscle asymmetry observed. Monitor in "
                           "subsequent sessions.",
        })
    if fat_max > 0.5:
        concerns.append({
            "severity": "medium",
            "type": "fatigue",
            "description": "Elevated fatigue indicators in EMG signal. "
                           "Consider adjusting session intensity.",
        })
    if reps is not None and reps < 10:
        concerns.append({
            "severity": "low",
            "type": "engagement",
            "description": "Low repetition count. Consider reviewing session "
                           "length or exercise selection.",
        })
    # Safety event from keyword detection
    for ev in events or []:
        if ev.get("type") == "verbal_stop" or ev.get("event") == "verbal_stop":
            concerns.append({
                "severity": "high",
                "type": "safety",
                "description": "Patient triggered verbal stop during session. "
                               "Review context.",
            })
            break
    # Classifier concern
    if classification and classification["label"] == "incorrect":
        severity = "medium" if classification["confidence"] > 0.6 else "low"
        concerns.append({
            "severity": severity,
            "type": "form",
            "description": (
                f"AI classifier flagged session form as incorrect "
                f"(confidence {classification['confidence'] * 100:.0f}%). "
                f"Review technique or schedule supervised session."
            ),
        })

    # Recommendations
    if not concerns:
        recommendations = [
            "Continue current exercise prescription.",
            "Monitor progress in the next session.",
        ]
    elif any(c["severity"] == "high" for c in concerns):
        recommendations = [
            "Schedule a follow-up review of session metrics.",
            "Consider modifying exercise parameters.",
            "Discuss safety triggers with the patient.",
        ]
    elif any(c["severity"] == "medium" for c in concerns):
        recommendations = [
            "Schedule a follow-up review of session metrics.",
            "Consider modifying exercise parameters.",
        ]
    else:
        recommendations = [
            "Review technique with patient at next visit.",
            "Continue current program with monitoring.",
        ]

    # Safety events
    safety_events = [_format_event(e, session_start_ms) for e in (events or [])]

    # Metrics: include classification if present
    metrics_out = dict(metrics)
    if classification:
        metrics_out["formClassification"] = {
            "label": classification["label"],
            "confidence": classification["confidence"],
            "windowCount": classification["window_count"],
            "correctWindows": classification["correct_windows"],
            "model": classification["model_version"],
        }

    report = {
        "generatedAt": _now_iso(),
        "model": "flexio-svm-v1" if classification else "flexio-metrics-v1",
        "summary": summary,
        "metrics": metrics_out,
        "observations": observations,
        "concerns": concerns,
        "recommendations": recommendations,
        "safetyEvents": safety_events,
    }
    if llm_summary:
        report["aiSummary"] = llm_summary
        report["aiAnalysis"] = llm_summary
    return report