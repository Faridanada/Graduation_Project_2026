"""
metrics.py — Compute real biomechanical metrics from session waveforms.
These are computed regardless of whether the SVM is available.
"""

import logging
from typing import Optional
import numpy as np
import pandas as pd
from scipy.signal import find_peaks

logger = logging.getLogger(__name__)


def _safe(value, default=0.0):
    try:
        v = float(value)
        if np.isnan(v) or np.isinf(v):
            return default
        return v
    except Exception:
        return default


def _knee_angle_series(imu_df: pd.DataFrame) -> Optional[np.ndarray]:
    """
    Pull a knee-angle-like signal for ROM and rep counting.
    - If legacy CSV has 'kneeAngle' column, use it.
    - If wide format, compute a proxy from accel z-axis difference.
    Returns 1D array or None.
    """
    if "kneeAngle" in imu_df.columns:
        return imu_df["kneeAngle"].to_numpy(dtype=np.float64)

    # Wide format: use az1 - az2 as a rough angle proxy (gravity projection)
    if {"az1", "az2"}.issubset(imu_df.columns):
        a = imu_df["az1"].to_numpy(dtype=np.float64)
        b = imu_df["az2"].to_numpy(dtype=np.float64)
        # not a real angle — just relative orientation change
        return a - b
    return None


def compute_metrics(emg_df: pd.DataFrame, imu_df: pd.DataFrame, events: list, fs_imu_hz: float) -> dict:
    """
    Compute the metrics block for the report.
    Inputs are the raw DataFrames as read from S3 (any format).
    """
    metrics = {}

    # ---- Duration ----
    try:
        t_start = float(min(emg_df["timestamp_ms"].min(), imu_df["timestamp_ms"].min()))
        t_end = float(max(emg_df["timestamp_ms"].max(), imu_df["timestamp_ms"].max()))
        duration_s = max(0.0, (t_end - t_start) / 1000.0)
    except Exception:
        duration_s = 0.0
    metrics["duration"] = {"value": int(round(duration_s)), "unit": "seconds"}

    # ---- Range of motion ----
    knee = _knee_angle_series(imu_df)
    if knee is not None and len(knee) > 0:
        rom = {
            "min": _safe(np.min(knee)),
            "max": _safe(np.max(knee)),
            "average": _safe(np.mean(knee)),
        }
    else:
        rom = {"min": 0.0, "max": 0.0, "average": 0.0}
    metrics["rangeOfMotion"] = {
        "imu1": rom,
        "imu2": rom,  # single derived angle; documented limitation
        "unit": "degrees",
    }

    # ---- Peak EMG (handles both wide and long formats) ----
    def emg_channel_stats(values):
        if values is None or len(values) == 0:
            return {"peak": 0.0, "rms": 0.0}
        v = np.asarray(values, dtype=np.float64)
        return {
            "peak": _safe(np.max(np.abs(v))),
            "rms": _safe(np.sqrt(np.mean(v ** 2))),
        }

    if "emg1" in emg_df.columns and "emg2" in emg_df.columns:
        e1 = emg_channel_stats(emg_df["emg1"])
        e2 = emg_channel_stats(emg_df["emg2"])
    elif "channel" in emg_df.columns and "value" in emg_df.columns:
        e1 = emg_channel_stats(emg_df.loc[emg_df["channel"] == "emg1", "value"])
        e2 = emg_channel_stats(emg_df.loc[emg_df["channel"] == "emg2", "value"])
    else:
        e1 = {"peak": 0.0, "rms": 0.0}
        e2 = {"peak": 0.0, "rms": 0.0}
    metrics["peakEmg"] = {"emg1": e1, "emg2": e2, "unit": "normalized"}

    # ---- Muscle symmetry ----
    if e1["peak"] > 0 and e2["peak"] > 0:
        sym = min(e1["peak"], e2["peak"]) / max(e1["peak"], e2["peak"])
    else:
        sym = 0.0
    if sym >= 0.85:
        sym_interp = "balanced"
    elif sym >= 0.70:
        sym_interp = "mild imbalance"
    else:
        sym_interp = "significant imbalance"
    metrics["muscleSymmetry"] = {"score": round(sym, 3), "interpretation": sym_interp}

    # ---- Fatigue index ----
    def fatigue(values):
        v = np.asarray(values, dtype=np.float64)
        if len(v) < 10:
            return 0.0
        n = len(v)
        first = np.mean(np.abs(v[: n // 5]))
        last = np.mean(np.abs(v[-n // 5:]))
        if first <= 1e-9:
            return 0.0
        return float(np.clip(last / first - 1.0, 0.0, 1.0))

    if "emg1" in emg_df.columns and "emg2" in emg_df.columns:
        f1 = fatigue(emg_df["emg1"])
        f2 = fatigue(emg_df["emg2"])
    elif "channel" in emg_df.columns:
        f1 = fatigue(emg_df.loc[emg_df["channel"] == "emg1", "value"])
        f2 = fatigue(emg_df.loc[emg_df["channel"] == "emg2", "value"])
    else:
        f1 = f2 = 0.0
    f_max = max(f1, f2)
    if f_max < 0.3:
        f_interp = "low"
    elif f_max < 0.5:
        f_interp = "moderate"
    else:
        f_interp = "high"
    metrics["fatigueIndex"] = {
        "emg1": round(f1, 3),
        "emg2": round(f2, 3),
        "interpretation": f_interp,
    }

    # ---- Reps ----
    reps = None
    if knee is not None and len(knee) >= 20 and fs_imu_hz > 0:
        try:
            min_dist = max(int(round(fs_imu_hz * 1.0)), 5)  # at least 1s between peaks
            prominence = (np.max(knee) - np.min(knee)) * 0.2
            peaks, _ = find_peaks(knee, distance=min_dist, prominence=prominence)
            if len(peaks) >= 3:
                reps = int(len(peaks))
        except Exception:
            reps = None
    metrics["repetitionsCompleted"] = reps

    return metrics