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
            "You are a rehabilaitation and physical therapy analysis assistant. "
            "Analyze the following session metrics and classifier output for a clinician. "
            "Focus on movement quality, fatigue, asymmetry, safety risks, and potential "
            "recommendations for follow-up or exercise modification. "
            "Do not diagnose the patient. Keep the response concise, evidence-based, and professional. "
            "Make it in the form of a continuous report paragraph explaining what is going on. "
            f"Payload:\n{json.dumps(payload, indent=2)}"
        )
        response = client.chat.completions.create(
            model=selected_model,
            messages=[{"role": "system", "content": "You are a helpful clinical analysis assistant."}, {"role": "user", "content": prompt}],
            temperature=0.2,
        )
        return response.choices[0].message.content or None
    except Exception:
        return None
