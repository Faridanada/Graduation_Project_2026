import json
import os
from typing import Optional

from dotenv import load_dotenv

load_dotenv()


def generate_llm_summary(payload: dict, model: Optional[str] = None) -> Optional[str]:
    """Send a compact structured payload to OpenAI and return a generated summary."""
    api_key = os.getenv("OPENAI_API_KEY", "").strip()
    if not api_key:
        return None

    try:
        from openai import OpenAI
    except Exception:
        return None

    try:
        client = OpenAI(api_key=api_key)
        selected_model = model or os.getenv("OPENAI_MODEL", "gpt-4o-mini")
        prompt = (
            "You are a rehabilitation and physical therapy analysis assistant. "
            "Analyze the following session metrics and classifier output for a clinician. "
            "Use the knee angle values produced by the compute_metrics() function and its _knee_angle_series() helper, rather than raw IMU sensor readings. "
            "Do not report raw accelerometer or gyroscope values. "
            "Do not diagnose the patient. Keep the response concise, evidence-based, and professional. "
            "If a classifier label is present, describe form quality without mentioning confidence or probability. "
            "Interpret the angle using the following small helper logic: "
            "function computeKneeAngle(ax1, ay1, az1, gx1, ax2, ay2, az2, gx2, dt) { "
            "const thighAngle = Math.atan2(ay1, az1) * (180 / Math.PI); "
            "const calfAngle = Math.atan2(ay2, az2) * (180 / Math.PI); "
            "return thighAngle - calfAngle; "
            "} "
            f"Payload:\n{json.dumps(payload, indent=2)}"
        )
        response = client.chat.completions.create(
            model=selected_model,
            messages=[{"role": "system", "content": "You are a helpful clinical analysis assistant."}, {"role": "user", "content": prompt}],
            temperature=0.2,
        )
        return response.choices[0].message.content or None
    except Exception as e:
        print(f"❌ OpenAI Error: {type(e).__name__} - {e}")
        return None
