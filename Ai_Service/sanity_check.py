"""
sanity_check.py — Quick verification of the SVM model.

Run AFTER copying your svm_model.pkl and scaler.pkl into models/.
Confirms:
  1. Both files load without error
  2. n_features_in_ == 140
  3. The model does NOT collapse to a single prediction on plausible inputs

If this fails, do NOT plug the SVM into the live AI service.

Usage:
  python sanity_check.py
"""
import os
import sys
from pathlib import Path

import joblib
import numpy as np

MODEL_PATH = os.getenv("SVM_MODEL_PATH", "models/svm_model.pkl")
SCALER_PATH = os.getenv("SVM_SCALER_PATH", "models/scaler.pkl")


def main():
    p_m = Path(MODEL_PATH)
    p_s = Path(SCALER_PATH)
    if not p_m.is_file():
        print(f"FAIL: model not found at {MODEL_PATH}")
        sys.exit(1)
    if not p_s.is_file():
        print(f"FAIL: scaler not found at {SCALER_PATH}")
        sys.exit(1)

    model = joblib.load(MODEL_PATH)
    scaler = joblib.load(SCALER_PATH)

    n_feat = getattr(model, "n_features_in_", None)
    print(f"Model loaded: {type(model).__name__}, n_features_in_={n_feat}")
    print(f"Scaler loaded: {type(scaler).__name__}, n_features_in_={getattr(scaler, 'n_features_in_', None)}")

    if n_feat != 140:
        print(f"WARN: expected 140 features, got {n_feat}. AI service assumes 140.")

    # Probe with diverse synthetic feature vectors
    np.random.seed(0)
    preds = []
    decisions = []
    for i in range(50):
        np.random.seed(i)
        # mimic per-channel features after channel normalization
        feat = []
        for _ in range(14):  # 14 channels (2 EMG + 12 IMU)
            feat.extend([
                np.random.randn() * 0.5,                # mean
                0.8 + np.random.randn() * 0.3,          # std
                -2.0 + np.random.randn(),               # min
                2.0 + np.random.randn(),                # max
                0.9 + np.random.randn() * 0.3,          # rms
                100 + np.random.randn() * 50,           # energy
                0.7 + np.random.randn() * 0.3,          # mav
                50 + np.random.randn() * 20,            # wl
                15 + np.random.randn() * 8,             # zc
                30 + np.random.randn() * 15,            # ssc
            ])
        x = np.array(feat).reshape(1, -1)
        x_s = scaler.transform(x)
        preds.append(int(model.predict(x_s)[0]))
        try:
            decisions.append(float(model.decision_function(x_s)[0]))
        except Exception:
            decisions.append(None)

    print()
    print(f"50 synthetic inputs:")
    print(f"  Correct (1): {preds.count(1)}")
    print(f"  Incorrect (0): {preds.count(0)}")
    print(f"  Distinct values: {sorted(set(preds))}")
    if decisions and decisions[0] is not None:
        print(f"  Decision function range: {min(decisions):.3f} to {max(decisions):.3f}")
        print(f"  Decision function mean: {sum(decisions)/len(decisions):.3f}")

    if len(set(preds)) < 2:
        print()
        print("FAIL: model collapsed to a single class on diverse inputs.")
        print("Do NOT plug this model into the live AI service.")
        sys.exit(2)

    if decisions and decisions[0] is not None:
        dec_range = max(decisions) - min(decisions)
        if dec_range < 0.1:
            print()
            print(f"WARN: decision function range only {dec_range:.4f}.")
            print("Model is borderline collapsing. Predictions may be unreliable.")

    print()
    print("OK: model produces varied predictions. Safe to wire into AI service.")
    return 0


if __name__ == "__main__":
    sys.exit(main())