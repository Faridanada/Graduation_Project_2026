require('dotenv').config();
const mqtt = require('mqtt');
const axios = require('axios');

async function testLivePipe() {
  const https = require('https');
  const agent = new https.Agent({ rejectUnauthorized: false });
  const baseUrl = "https://13.62.249.165/api";
  const deviceId = "dev_test_001";
  
  console.log("7a. Logging in...");
  let token, sessionId, patientId;
  try {
    const loginRes = await axios.post(`${baseUrl}/login`, {
      email: "yomnayehia18@gmail.com",
      password: "Ananas12$"
    }, { httpsAgent: agent });
    token = loginRes.data.token;
    patientId = loginRes.data.user.id;
    console.log("Logged in successfully. Patient ID:", patientId);

    console.log("Starting session...");
    const sessionRes = await axios.post(`${baseUrl}/sessions/start`, {
      deviceId: deviceId,
      exerciseId: 'ex_passive_knee'
    }, {
      headers: { Authorization: `Bearer ${token}` },
      httpsAgent: agent
    });
    sessionId = sessionRes.data.sessionId;
    console.log("Session started:", sessionId);
  } catch (err) {
    console.error("Failed to start session:", err.response?.data || err.message);
    process.exit(1);
  }

  console.log("7b. Connecting to Mosquitto over TLS...");
  const client = mqtt.connect('mqtts://13.62.249.165:8883', {
    username: process.env.MQTT_USERNAME || 'esp32_test',
    password: process.env.MQTT_PASSWORD || 'yomna123',
    rejectUnauthorized: false
  });

  client.on('connect', async () => {
    console.log("Connected! Publishing 10 batches...");
    
    for (let i = 1; i <= 10; i++) {
      const ts = Date.now();
      
      const emgPayload = {
        ts,
        deviceId,
        fs: 50,
        samples: [
          { t: ts, emg1: 0.5, emg2: 0.3 },
          { t: ts + 20, emg1: 0.6, emg2: 0.4 }
        ]
      };
      
      const imuPayload = {
        ts,
        deviceId,
        fs: 50,
        samples: [
          { t: ts, ax1: 0.1, ay1: 0.0, az1: 0.98, gx1: 1.2, gy1: 0.3, gz1: -0.5, ax2: 0.1, ay2: 0.0, az2: 0.98, gx2: 1.2, gy2: 0.3, gz2: -0.5 }
        ]
      };

      client.publish(`flexio/${deviceId}/emg`, JSON.stringify(emgPayload));
      client.publish(`flexio/${deviceId}/imu`, JSON.stringify(imuPayload));
      
      await new Promise(r => setTimeout(r, 500));
    }
    
    console.log("Finished publishing. Waiting 2s for backend buffer...");
    setTimeout(async () => {
      console.log("7d. Ending session...");
      try {
        const endRes = await axios.post(`${baseUrl}/sessions/${sessionId}/end`, { status: 'completed' }, {
          headers: { Authorization: `Bearer ${token}` },
          httpsAgent: agent
        });
        console.log("Session ended:", endRes.data);
      } catch (err) {
        console.error("Failed to end session:", err.response?.data || err.message);
      }
      client.end();
    }, 2000);
  });

  client.on('error', (err) => {
    console.error("MQTT Error:", err.message);
    process.exit(1);
  });
}

testLivePipe();
