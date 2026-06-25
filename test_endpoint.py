import urllib.request
import urllib.error
import json
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

base_url = "http://localhost:5000/api"

try:
    print("Logging in...")
    req = urllib.request.Request(f"{base_url}/login", data=json.dumps({
        "email": "yomnayehia18@gmail.com",
        "password": "Ananas12$"
    }).encode('utf-8'), headers={"Content-Type": "application/json"})
    
    with urllib.request.urlopen(req, context=ctx) as response:
        res = json.loads(response.read().decode('utf-8'))
        token = res.get('token')
        print("Obtained token.")

    print("\nFetching active session...")
    req2 = urllib.request.Request(f"{base_url}/sessions/patients/1773960006547/active-session", headers={
        "Authorization": f"Bearer {token}"
    })
    
    try:
        with urllib.request.urlopen(req2, context=ctx) as response2:
            print(f"Status: {response2.status}")
            print(response2.read().decode('utf-8'))
    except urllib.error.HTTPError as e:
        print(f"HTTP Error: {e.code}")
        print(e.read().decode('utf-8'))
        
except Exception as e:
    print(f"Error: {e}")
