const axios = require('axios');
const mqtt = require('mqtt');
const https = require('https');

// Point to the live EC2 server
const API_BASE_URL = 'https://flexio-rehab.duckdns.org/api'; 
const MQTT_BROKER = 'mqtt://flexio-rehab.duckdns.org';
const DEVICE_ID = 'dev_test_001';

const agent = new https.Agent({ rejectUnauthorized: false });

async function runFullTest() {
  console.log('================================================');
  console.log('🚀 FULL CLOUD PIPELINE TEST (Simulating ESP32)');
  console.log('================================================\n');

  try {
    // 1. Login
    console.log('🔑 1. Logging in...');
    const loginRes = await axios.post(`${API_BASE_URL}/login`, {
      email: 'yomnayehia18@gmail.com',
      password: 'Ananas12$'
    }, { httpsAgent: agent });
    const token = loginRes.data.token;

    // 2. Start Session
    console.log('🟢 2. Starting session on EC2...');
    const startRes = await axios.post(`${API_BASE_URL}/sessions/start`, {
      deviceId: DEVICE_ID,
      exerciseId: 'ex_passive_knee'
    }, { headers: { Authorization: `Bearer ${token}` }, httpsAgent: agent });
    const sessionId = startRes.data.sessionId;
    console.log(`✅ Session Started: ${sessionId}\n`);

    // 3. Connect to MQTT
    console.log('📡 3. Connecting to EC2 MQTT Broker...');
    const mqttClient = mqtt.connect(MQTT_BROKER, { username: 'esp32_test', password: 'yomna123' });
    
    await new Promise((resolve) => mqttClient.on('connect', resolve));
    console.log('✅ MQTT Connected!\n');

    // 4. Pump Fake Data for 5 seconds (50Hz = 250 packets)
    console.log('💦 4. Pumping 5 seconds of perfect mock data over MQTT...');
    let count = 0;
    const interval = setInterval(() => {
      const payload = {
        ts: Date.now(),
        deviceId: DEVICE_ID,
        emg1: Number(Math.random().toFixed(4)),
        emg2: Number((Math.random() * 0.5).toFixed(4)),
        on1: 1, on2: 1,
        ax1: 0.1, ay1: 0.2, az1: 0.9, gx1: 0, gy1: 0, gz1: 0,
        ax2: 0.1, ay2: 0.2, az2: 0.9, gx2: 0, gy2: 0, gz2: 0
      };
      mqttClient.publish(`flexio/${DEVICE_ID}/bundle`, JSON.stringify(payload));
      count++;
    }, 20);

    // Wait 5 seconds
    await new Promise(r => setTimeout(r, 5000));
    clearInterval(interval);
    mqttClient.end();
    console.log(`✅ Sent ${count} MQTT packets.\n`);

    // Wait 2 seconds for buffer to catch up
    await new Promise(r => setTimeout(r, 2000));

    // 5. End Session
    console.log('🛑 5. Ending Session and triggering AI...');
    const endRes = await axios.post(`${API_BASE_URL}/sessions/${sessionId}/end`, { status: 'completed' }, {
      headers: { Authorization: `Bearer ${token}` }, httpsAgent: agent
    });

    console.log(`\n🎉 PIPELINE TEST COMPLETE!`);
    console.log(`- Samples Saved to S3: ${endRes.data.session.sampleCount}`);

    // 6. Wait for AI Report
    console.log(`\n⏳ 6. Waiting for AI Service on EC2 to generate the clinical report...`);
    let reportStatus = 'pending';
    let attempts = 0;
    
    while (reportStatus !== 'completed' && attempts < 20) {
      await new Promise(r => setTimeout(r, 2000)); // check every 2 seconds
      attempts++;
      
      const sessionRes = await axios.get(`${API_BASE_URL}/sessions/${sessionId}`, {
        headers: { Authorization: `Bearer ${token}` }, httpsAgent: agent
      });
      
      reportStatus = sessionRes.data.session.reportStatus;
      process.stdout.write(`...${reportStatus}`);
      
      if (reportStatus === 'completed') {
        console.log(`\n\n✅ AI REPORT RECEIVED FROM OPENAI!`);
        console.log('================================================');
        console.log(JSON.stringify(sessionRes.data.session.report, null, 2));
        console.log('================================================\n');
        break;
      }
    }
    
    if (reportStatus !== 'completed') {
      console.log(`\n\n⚠️ Timed out waiting for AI report. Run 'pm2 logs ai-service' on EC2 to check for errors.`);
    }

  } catch (err) {
    console.error('❌ Test Failed:', err.response ? err.response.data : err.message);
  }
}

runFullTest();
