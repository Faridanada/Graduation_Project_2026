"""
adapter.py — Convert session CSVs into the numpy arrays the SVM
expects, matching the training script's input shape and rate.

Handles BOTH CSV formats:
  - Wide (new): emg.csv has columns [timestamp_ms, emg1, emg2]
                imu.csv has columns [timestamp_ms, ax1, ay1, az1, gx1, gy1, gz1,
                                     ax2, ay2, az2, gx2, gy2, gz2]
  - Long (current): emg.csv has columns [timestamp_ms, channel, value]
                    imu.csv has columns [timestamp_ms, kneeAngle, thigh1_gx, ...]
                    (kneeAngle + 6 gravity columns)

For the long IMU format we can't recover all 12 axes — so we synthesize
a best-effort 12-channel array by replicating gravity components into
accel positions and zeroing gyro. The classifier will likely produce
poor predictions on this — that's the known limitation.
"""

import os
import logging
import numpy as np
import pandas as pd
from scipy import signal as sp_signal

logger = logging.getLogger(__name__)

EMG_TRAINING_FS = float(os.getenv("EMG_TRAINING_FS", "1259.2592592592594"))
IMU_TRAINING_FS = float(os.getenv("IMU_TRAINING_FS", "148.14814814814815"))


def estimate_sample_rate(timestamps_ms: np.ndarray) -> float:
    """Estimate sample rate (Hz) from a sorted array of timestamps in ms."""
    if len(timestamps_ms) < 2:
        return 0.0
    diffs = np.diff(np.sort(timestamps_ms))
    diffs = diffs[diffs > 0]
    if len(diffs) == 0:
        return 0.0
    median_dt_ms = float(np.median(diffs))
    if median_dt_ms <= 0:
        return 0.0
    return 1000.0 / median_dt_ms


def emg_df_to_array(emg_df: pd.DataFrame) -> tuple[np.ndarray, float]:
    """
    Returns (array of shape (2, N), estimated_sample_rate_hz).
    Handles both wide (timestamp, emg1, emg2) and long
    (timestamp, channel, value) formats.
    """
    cols = set(emg_df.columns)

    if {"emg1", "emg2"} <= cols and "timestamp_ms" in cols:
        # Wide format
        df = emg_df.sort_values("timestamp_ms").reset_index(drop=True)
        emg1 = df["emg1"].to_numpy(dtype=np.float64)
        emg2 = df["emg2"].to_numpy(dtype=np.float64)
        ts = df["timestamp_ms"].to_numpy()
        fs = estimate_sample_rate(ts)
        arr = np.stack([emg1, emg2], axis=0)
        logger.info(f"[adapter] EMG wide format, fs≈{fs:.1f} Hz, shape={arr.shape}")
        return arr, fs

    if {"channel", "value"} <= cols and "timestamp_ms" in cols:
        # Long format → pivot to wide
        df = emg_df.sort_values(["channel", "timestamp_ms"]).reset_index(drop=True)
        emg1_rows = df[df["channel"] == "emg1"]
        emg2_rows = df[df["channel"] == "emg2"]
        emg1 = emg1_rows["value"].to_numpy(dtype=np.float64)
        emg2 = emg2_rows["value"].to_numpy(dtype=np.float64)
        # Truncate to equal length
        n = min(len(emg1), len(emg2))
        emg1, emg2 = emg1[:n], emg2[:n]
        # Use emg1 timestamps to estimate rate
        ts = emg1_rows["timestamp_ms"].to_numpy()[:n]
        fs = estimate_sample_rate(ts)
        arr = np.stack([emg1, emg2], axis=0)
        logger.info(f"[adapter] EMG long format, fs≈{fs:.1f} Hz, shape={arr.shape}")
        return arr, fs

    raise ValueError(f"Unrecognized EMG CSV columns: {cols}")


def imu_df_to_array(imu_df: pd.DataFrame) -> tuple[np.ndarray, float]:
    """
    Returns (array of shape (12, N), estimated_sample_rate_hz).
    12 channels: ax1, ay1, az1, gx1, gy1, gz1, ax2, ay2, az2, gx2, gy2, gz2

    Handles two formats:
    - Wide (new): timestamp_ms + 12 named columns
    - Legacy: timestamp_ms, kneeAngle, thigh1_gx, thigh1_gy, thigh1_gz,
              shin1_gx, shin1_gy, shin1_gz
      For legacy, we synthesize 12 channels by:
        - putting gravity into the accel slots
        - zeroing the gyro slots
      This will produce poor SVM predictions but doesn't crash.
    """
    cols = set(imu_df.columns)
    wide_channels = ["ax1", "ay1", "az1", "gx1", "gy1", "gz1",
                     "ax2", "ay2", "az2", "gx2", "gy2", "gz2"]

    if all(c in cols for c in wide_channels) and "timestamp_ms" in cols:
        # Wide format
        df = imu_df.sort_values("timestamp_ms").reset_index(drop=True)
        ts = df["timestamp_ms"].to_numpy()
        fs = estimate_sample_rate(ts)
        rows = [df[c].to_numpy(dtype=np.float64) for c in wide_channels]
        arr = np.stack(rows, axis=0)
        logger.info(f"[adapter] IMU wide format, fs≈{fs:.1f} Hz, shape={arr.shape}")
        return arr, fs

    legacy_cols = ["thigh1_gx", "thigh1_gy", "thigh1_gz",
                   "shin1_gx", "shin1_gy", "shin1_gz"]
    if all(c in cols for c in legacy_cols) and "timestamp_ms" in cols:
        logger.warning(
            "[adapter] IMU CSV is legacy gravity-only format. "
            "Synthesizing 12-channel array. SVM predictions will be "
            "unreliable until firmware emits raw accel+gyro."
        )
        df = imu_df.sort_values("timestamp_ms").reset_index(drop=True)
        ts = df["timestamp_ms"].to_numpy()
        fs = estimate_sample_rate(ts)
        n = len(df)
        # Map gravity → accel slots, zero gyro slots
        ax1 = df["thigh1_gx"].to_numpy(dtype=np.float64)
        ay1 = df["thigh1_gy"].to_numpy(dtype=np.float64)
        az1 = df["thigh1_gz"].to_numpy(dtype=np.float64)
        ax2 = df["shin1_gx"].to_numpy(dtype=np.float64)
        ay2 = df["shin1_gy"].to_numpy(dtype=np.float64)
        az2 = df["shin1_gz"].to_numpy(dtype=np.float64)
        zero = np.zeros(n, dtype=np.float64)
        arr = np.stack([ax1, ay1, az1, zero, zero, zero,
                        ax2, ay2, az2, zero, zero, zero], axis=0)
        return arr, fs

    raise ValueError(f"Unrecognized IMU CSV columns: {cols}")


def resample_to(signal_array: np.ndarray, fs_source: float, fs_target: float) -> np.ndarray:
    """Resample (n_channels, n_samples) to target rate. No-op if equal."""
    if fs_source <= 0:
        logger.warning("[adapter] source fs unknown, skipping resample")
        return signal_array
    if abs(fs_source - fs_target) < 0.5:
        return signal_array
    n_in = signal_array.shape[1]
    n_out = int(round(n_in * fs_target / fs_source))
    if n_out < 2:
        return signal_array
    return sp_signal.resample(signal_array, n_out, axis=1)