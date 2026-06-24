import os
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

api_key = os.getenv("OPENAI_API_KEY", "").strip()

print(f"API Key found: {'Yes' if api_key else 'No'} (starts with {api_key[:10]}...)")

try:
    client = OpenAI(api_key=api_key)
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": "Say hello!"}]
    )
    print("OpenAI Success!")
    print(response.choices[0].message.content)
except Exception as e:
    print(f"OpenAI Error: {type(e).__name__} - {e}")
