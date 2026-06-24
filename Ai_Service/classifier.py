"""
classifier.py — SVM-based session classifier.

MUST use the exact same preprocessing, channel slicing, and feature
extraction as `train_svm_for_flexio.py`. Any drift between the two
will silently degrade accuracy.
"""

import os
import logging
from pathlib import Path
from typing import Optional

import joblib
import numpy as np

logger = logging.getLogger(__name__)

MODEL_PATH = os.getenv("SVM_MODEL_PATH", "svm_model.pkl")
SCALER_PATH = os.getenv("SVM_SCALER_PATH", "scaler.pkl")
WINDOW_SAMPLES = int(os.getenv("WINDOW_SAMPLES_EMG", "100"))
STEP_SAMPLES = int(os.getenv("STEP_SAMPLES_EMG", "50"))

_model = None
_scaler = None
_model_load_error: Optional[str] = None


def _load():
    """Lazily load model + scaler. Returns True if both available."""
    global _model, _scaler, _model_load_error
    if _model is not None and _scaler is not None:
        return True
    try:
        if not Path(MODEL_PATH).is_file():
            _model_load_error = f"model not found at {MODEL_PATH}"
            return False
        if not Path(SCALER_PATH).is_file():
            _model_load_error = f"scaler not found at {SCALER_PATH}"
            return False
        _model = joblib.load(MODEL_PATH)
        _scaler = joblib.load(SCALER_PATH)
        n_features = getattr(_model, "n_features_in_", "unknown")
        logger.info(f"[classifier] loaded SVM (n_features={n_features})")
        return True
    except Exception as e:
        _model_load_error = f"load failed: {e}"
        logger.exception("[classifier] failed to load model/scaler")
        return False


# ---------- preprocessing (must match train_svm_for_flexio.py) ----------

def preprocess_signals(emg: np.ndarray, imu: np.ndarray):
    """
    Channel merging — IDENTICAL to training script.

    EMG (in, shape 8 x N):
      env1 (quad)     ← avg of dataset sensors 1 & 5 → idx 0 + idx 4
      env2 (hamstring)← avg of dataset sensors 2 & 6 → idx 1 + idx 5

    IMU (in, shape 48 x N):
      upper (thigh) ← avg of sensors 1 & 5 → rows 0:6 + rows 24:30
      lower (shank) ← avg of sensors 3 & 7 → rows 12:18 + rows 36:42

    BUT at inference our EMG comes in already as 2 channels (env1, env2)
    and IMU as 12 channels (ax1..gz2). So at inference we SKIP the
    merging step — the data is already merged.
    """
    # Inference shortcut: data is already in 2x N and 12x N shape.
    if emg.shape[0] == 2 and imu.shape[0] == 12:
        return emg, imu

    # Otherwise apply the training-style merge (used for unit tests).
    if emg.shape[0] != 8 or imu.shape[0] != 48:
        raise ValueError(
            f"Unexpected shapes for preprocessing: emg={emg.shape}, imu={imu.shape}"
        )

    emg_upper = (emg[0, :] + emg[4, :]) / 2.0
    emg_hams = (emg[1, :] + emg[5, :]) / 2.0
    emg_merged = np.vstack([emg_upper, emg_hams])

    imu_upper = (imu[0:6, :] + imu[24:30, :]) / 2.0
    imu_lower = (imu[12:18, :] + imu[36:42, :]) / 2.0
    imu_merged = np.vstack([imu_upper, imu_lower])

    return emg_merged, imu_merged


def extract_features(signal_array: np.ndarray) -> np.ndarray:
    """
    Per-channel 10 features. IDENTICAL to training script.
    """
    features = []
    for ch in signal_array:
        mean = np.mean(ch)
        std = np.std(ch)
        min_val = np.min(ch)
        max_val = np.max(ch)
        rms = np.sqrt(np.mean(ch ** 2))
        energy = np.sum(ch ** 2)
        mav = np.mean(np.abs(ch))
        wl = np.sum(np.abs(np.diff(ch)))
        zc = np.sum((ch[:-1] * ch[1:]) < 0)
        ssc = np.sum(((ch[1:-1] - ch[:-2]) * (ch[1:-1] - ch[2:])) > 0)
        features.extend([mean, std, min_val, max_val, rms, energy, mav, wl, zc, ssc])
    return np.array(features)


def _windows(signal_array: np.ndarray, w: int, s: int):
    out = []
    for start in range(0, signal_array.shape[1] - w + 1, s):
        out.append(signal_array[:, start:start + w])
    return out


# ---------- public API ----------

def classify_session(emg: np.ndarray, imu: np.ndarray) -> Optional[dict]:
    """
    Classify a session given already-channel-merged + resampled signals.

    Args:
      emg: shape (2, N_emg) at the training EMG rate
      imu: shape (12, N_imu) at the training IMU rate

    Returns:
      {
        "label": "correct" | "incorrect",
        "confidence": float,
        "window_count": int,
        "correct_windows": int,
        "model_version": "flexio-svm-v1",
      }
      Or None if the model/scaler isn't available.
    """
    if not _load():
        logger.warning(f"[classifier] unavailable: {_model_load_error}")
        return None

    if emg.shape[0] != 2 or imu.shape[0] != 12:
        logger.error(
            f"[classifier] wrong channel shapes: emg={emg.shape}, imu={imu.shape}"
        )
        return None

    # Make EMG and IMU produce the same number of windows by aligning indices.
    # Training treats them as parallel windows from the same trial. Since the
    # source rates differ, the number of windows would differ too — so we
    # truncate to the shorter one's window count.
    emg_w = _windows(emg, WINDOW_SAMPLES, STEP_SAMPLES)
    imu_w = _windows(imu, WINDOW_SAMPLES, STEP_SAMPLES)
    n = min(len(emg_w), len(imu_w))
    if n == 0:
        logger.warning(f"[classifier] no usable windows (emg_w={len(emg_w)}, imu_w={len(imu_w)})")
        return None

    feats = []
    for i in range(n):
        f_emg = extract_features(emg_w[i])   # 20
        f_imu = extract_features(imu_w[i])   # 120
        feats.append(np.concatenate([f_emg, f_imu]))   # 140
    X = np.array(feats)

    expected = getattr(_model, "n_features_in_", None)
    if expected is not None and X.shape[1] != expected:
        logger.error(
            f"[classifier] feature length mismatch: got {X.shape[1]}, "
            f"model expects {expected}"
        )
        return None

    X_scaled = _scaler.transform(X)
    preds = _model.predict(X_scaled)

    # Confidence per window via decision_function distance.
    # SVC without probability=True doesn't have predict_proba, but
    # decision_function gives signed distance to the boundary.
    try:
        dist = _model.decision_function(X_scaled)
        # Normalize distances to a pseudo-confidence in [0,1]
        # tanh keeps it bounded; |dist| > 2 is very confident
        conf_per = np.tanh(np.abs(dist))
    except Exception:
        conf_per = np.ones(len(preds)) * 0.5

    correct_count = int(np.sum(preds == 1))
    total = len(preds)
    correct_ratio = correct_count / total if total else 0.0
    final_label = "correct" if correct_ratio >= 0.5 else "incorrect"
    mean_conf = float(np.mean(conf_per))

    return {
        "label": final_label,
        "confidence": round(mean_conf, 3),
        "window_count": total,
        "correct_windows": correct_count,
        "model_version": "flexio-svm-v1",
    }