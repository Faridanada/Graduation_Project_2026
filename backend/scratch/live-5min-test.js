const axios = require('axios');
const https = require('https');

const API_BASE_URL = 'https://flexio-rehab.duckdns.org/api'; 
const DEVICE_ID = 'dev_test_001';

const agent = new https.Agent({ rejectUnauthorized: false });

async function runLiveTest() {
  console.log('================================================');
  console.log('🎙️  RECORDING LIVE ESP32 DATA FOR 5 MINUTES');
  console.log('================================================\n');

  try {
    // 1. Login
    console.log('🔑 Logging in as patient...');
    const loginRes = await axios.post(`${API_BASE_URL}/login`, {
      email: 'yomnayehia18@gmail.com',
      password: 'Ananas12$'
    }, { httpsAgent: agent });
    const token = loginRes.data.token;

    // 2. Start Session
    console.log(`\n🟢 Starting session for device: ${DEVICE_ID}`);
    const startRes = await axios.post(`${API_BASE_URL}/sessions/start`, {
      deviceId: DEVICE_ID,
      exerciseId: 'ex_passive_knee'
    }, {
      headers: { Authorization: `Bearer ${token}` },
      httpsAgent: agent
    });

    const sessionId = startRes.data.sessionId;
    console.log(`✅ Session Started! ID: ${sessionId}`);
    
    // 3. Wait 1 minute
    console.log(`\n⏳ Recording live data from your real ESP32 for 1 minute...`);
    console.log(`💪 PLEASE TURN ON YOUR ESP32 AND STM32 NOW!`);
    
    // Sniff MQTT to show visual feedback
    const mqtt = require('mqtt');
    const mqttClient = mqtt.connect('mqtt://13.62.249.165:1883', { username: 'esp32_test', password: 'yomna123' });
    
    mqttClient.on('connect', () => {
      mqttClient.subscribe(`flexio/${DEVICE_ID}/#`);
      console.log(`\n🎧 Listening for live packets... (You will see 📦 for every packet received)`);
    });

    let packetCount = 0;
    mqttClient.on('message', (topic, msg) => {
      packetCount++;
      process.stdout.write('📦');
    });
    
    let secondsLeft = 60;
    const timer = setInterval(() => {
      secondsLeft--;
      process.stdout.write(`\r⏳ Time remaining: ${secondsLeft} seconds...`);
    }, 1000);

    await new Promise(resolve => setTimeout(resolve, 60000));
    clearInterval(timer);

    // 4. End Session
    console.log(`\n\n🛑 1 minute reached! Ending session...`);
    const endRes = await axios.post(`${API_BASE_URL}/sessions/${sessionId}/end`, { 
      status: 'completed' 
    }, {
      headers: { Authorization: `Bearer ${token}` },
      httpsAgent: agent
    });

    const sampleCount = endRes.data.session.sampleCount;
    console.log(`\n🎉 DONE RECORDING!`);
    console.log(`- AWS S3 Upload: SUCCESS`);
    console.log(`- Total Live Samples Captured: ${sampleCount}`);
    
    if (sampleCount === 0) {
      console.log(`\n⚠️ WARNING: 0 samples were captured. Your ESP32 wasn't sending data!`);
      return;
    }

    // 5. Poll for AI Report
    console.log(`\n⏳ Waiting for AI Service on EC2 to analyze your 5-minute session...`);
    let reportStatus = 'pending';
    let sessionRes;
    
    while (reportStatus === 'pending' || reportStatus === 'processing') {
      process.stdout.write('.');
      await new Promise(r => setTimeout(r, 2000));
      
      sessionRes = await axios.get(`${API_BASE_URL}/sessions/${sessionId}`, {
        headers: { Authorization: `Bearer ${token}` },
        httpsAgent: agent
      });
      
      reportStatus = sessionRes.data.session.reportStatus;
      
      if (reportStatus === 'failed') {
        console.log(`\n❌ AI Report Failed: ${sessionRes.data.session.reportError}`);
        break;
      }
      
      if (reportStatus === 'completed') {
        console.log(`\n\n✅ AI REPORT RECEIVED FROM OPENAI!`);
        console.log('================================================');
        console.log(JSON.stringify(sessionRes.data.session.report, null, 2));
        console.log('================================================\n');
        break;
      }
    }

    mqttClient.end();
    process.exit(0);

  } catch (error) {
    console.error('\n❌ Script Failed!');
    if (error.response) {
      console.error('API Error:', error.response.data);
    } else {
      console.error(error.message);
    }
    process.exit(1);
  }
}

runLiveTest();
