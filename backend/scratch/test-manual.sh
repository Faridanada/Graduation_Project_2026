#!/bin/bash

# ==========================================
# MANUAL PIPELINE TEST SCRIPT
# Run this in Git Bash, WSL, or on your EC2
# ==========================================

API_URL="https://flexio-rehab.duckdns.org/api"
MQTT_HOST="flexio-rehab.duckdns.org"
DEVICE_ID="dev_test_001"

echo "🔑 1. Logging in..."
TOKEN=$(curl -s -X POST "$API_URL/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"yomnayehia18@gmail.com","password":"Ananas12$"}' | grep -o '"token":"[^"]*' | grep -o '[^"]*$')

if [ -z "$TOKEN" ]; then
  echo "❌ Login failed!"
  exit 1
fi
echo "✅ Logged in. Token received."

echo "🟢 2. Starting Session..."
SESSION_RES=$(curl -s -X POST "$API_URL/sessions/start" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"deviceId":"'"$DEVICE_ID"'","exerciseId":"ex_passive_knee"}')

SESSION_ID=$(echo $SESSION_RES | grep -o '"sessionId":"[^"]*' | grep -o '[^"]*$')
echo "✅ Session Started: $SESSION_ID"

echo "📡 3. Sending 1 manual MQTT packet..."
# Note: You need mosquitto-clients installed to use mosquitto_pub
mosquitto_pub -h "$MQTT_HOST" -t "flexio/$DEVICE_ID/bundle" -u "esp32_test" -P "yomna123" \
  -m '{"ts":'$(date +%s%3N)',"deviceId":"'"$DEVICE_ID"'","emg1":0.55,"emg2":0.22,"on1":1,"on2":1,"ax1":0.1,"ay1":0.2,"az1":0.9,"gx1":0.0,"gy1":0.0,"gz1":0.0,"ax2":0.1,"ay2":0.2,"az2":0.9,"gx2":0.0,"gy2":0.0,"gz2":0.0}'
echo "✅ Packet sent."

echo "⏳ Waiting 2 seconds for buffer to catch up..."
sleep 2

echo "🛑 4. Ending Session..."
curl -s -X POST "$API_URL/sessions/$SESSION_ID/end" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"status":"completed"}'

echo ""
echo "🎉 Manual Test Complete! Check your EC2 or AI laptop logs!"
