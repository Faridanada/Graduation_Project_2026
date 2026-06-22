require('dotenv').config();
const mqtt = require('mqtt');
const axios = require('axios');
const jwt = require('jsonwebtoken');

async function runMqttTest() {
  const deviceId = "ESP_TEST_MQTT";
  const patientId = "1773960006547";
  const baseUrl = "http://localhost:5000/api";

  console.log('1. Forging JWT token for test patient...');
  const token = jwt.sign({ id: patientId, role: 'patient' }, process.env.JWT_SECRET, { expiresIn: '1h' });

  console.log('2. Creating active session via HTTP API...');
  let sessionId;
  try {
    const res = await axios.post(`${baseUrl}/sessions/start`, {
      deviceId,
      exerciseId: 'ex_passive_knee'
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    sessionId = res.data.sessionId;
    console.log(`Started session ${sessionId}`);
  } catch (err) {
    console.error("Failed to start session:", err.response ? err.response.data : err.message);
    if (err.response?.status === 403 || err.response?.status === 404) {
      console.log("Adding device mapping to bypass Device Not Found...");
      // Since we don't have an endpoint to mock the DB easily without the actual app logic, 
      // let's just bypass the DB checking in the backend manually, or register the device!
      try {
        await axios.post(`${baseUrl}/sessions/devices`, {
          deviceId,
          mqttUsername: 'test_user'
        }, {
          headers: { Authorization: `Bearer ${token}` }
        });
        console.log("Device registered. Trying to start session again...");
        const res2 = await axios.post(`${baseUrl}/sessions/start`, {
          deviceId,
          exerciseId: 'ex_passive_knee'
        }, {
          headers: { Authorization: `Bearer ${token}` }
        });
        sessionId = res2.data.sessionId;
      } catch (e2) {
        console.error("Still failed:", e2.response?.data || e2.message);
        process.exit(1);
      }
    } else {
      process.exit(1);
    }
  }

  console.log('3. Connecting to Mosquitto...');
  const client = mqtt.connect(process.env.MQTT_URL || 'mqtt://localhost:1883');

  client.on('connect', async () => {
    console.log(`Connected to Mosquitto. Publishing 140 lines of 16-column sensor data...`);
    
    let payloadStr = "";
    const TOTAL_SAMPLES = 140;

    for (let i = 0; i < TOTAL_SAMPLES; i++) {
      const cyclePosition = i / TOTAL_SAMPLES;
      const activation = Math.sin(Math.PI * cyclePosition);

      const emg1 = (0.05 + activation * 0.9).toFixed(4);
      const emg2 = (0.03 + activation * 0.12).toFixed(4);

      const thighPitch = activation * 70 * 0.25;
      const thighRad = (thighPitch * Math.PI) / 180;
      const tAx = Math.sin(thighRad).toFixed(4);
      const tAz = Math.cos(thighRad).toFixed(4);

      const shinPitch = activation * 70;
      const shinRad = (shinPitch * Math.PI) / 180;
      const sAx = Math.sin(shinRad).toFixed(4);
      const sAz = Math.cos(shinRad).toFixed(4);

      payloadStr += `${emg1} ${emg2} 1 1 ${tAx} 0.0000 ${tAz} 0 0 0 ${sAx} 0.0000 ${sAz} 0 0 0\n`;
    }

    client.publish(`flexio/${deviceId}/stream`, payloadStr);
    
    console.log('Published! Waiting 2 seconds for Node backend to process MQTT messages...');
    
    setTimeout(async () => {
      console.log('4. Ending session to trigger S3 Waveform upload and AI Report...');
      try {
        const endRes = await axios.post(`${baseUrl}/sessions/${sessionId}/end`, {
          status: 'completed'
        }, {
          headers: { Authorization: `Bearer ${token}` }
        });
        console.log("Session ended response:", endRes.data);
      } catch (err) {
        console.error("Failed to end session:", err.response?.data || err.message);
      }

      console.log('Test complete! Check the terminal running the Node backend for S3 upload logs.');
      client.end();
      process.exit(0);
    }, 2000);
  });

  client.on('error', (err) => {
    console.error('MQTT error:', err);
    process.exit(1);
  });
}

runMqttTest();
