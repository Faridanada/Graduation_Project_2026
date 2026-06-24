const axios = require('axios');
const https = require('https');

// Use your deployed EC2 server
const API_BASE_URL = 'https://flexio-rehab.duckdns.org/api'; 
const DEVICE_ID = 'dev_test_001';

// We need an agent to ignore self-signed cert issues if testing locally
const agent = new https.Agent({ rejectUnauthorized: false });

async function recordLiveMinute() {
  console.log('================================================');
  console.log('🎙️  RECORDING LIVE ESP32 DATA FOR 1 MINUTE');
  console.log('================================================\n');

  try {
    // 1. Login to get auth token
    console.log('🔑 Logging in as patient...');
    const loginRes = await axios.post(`${API_BASE_URL}/login`, {
      email: 'yomnayehia18@gmail.com', // Change this if you use a different test account
      password: 'Ananas12$'
    }, { httpsAgent: agent });
    const token = loginRes.data.token;

    // 2. Start the Session on the Node Backend
    // This tells Node to start buffering the MQTT data coming from your ESP32!
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
    
    // 3. Wait 60 seconds while the ESP32 pumps data into the MQTT broker
    console.log(`\n⏳ Recording live data from ESP32 for 60 seconds...`);
    console.log(`💪 Move your leg and perform the exercise now!`);
    
    let secondsLeft = 60;
    const timer = setInterval(() => {
      secondsLeft--;
      process.stdout.write(`\r⏳ Time remaining: ${secondsLeft} seconds...`);
    }, 1000);

    await new Promise(resolve => setTimeout(resolve, 60000));
    clearInterval(timer);

    // 4. End the Session
    // This tells Node to flush the 60s of RAM data to S3, and ping the AI laptop!
    console.log(`\n\n🛑 60 seconds reached! Ending session...`);
    const endRes = await axios.post(`${API_BASE_URL}/sessions/${sessionId}/end`, { 
      status: 'completed' 
    }, {
      headers: { Authorization: `Bearer ${token}` },
      httpsAgent: agent
    });

    const sampleCount = endRes.data.session.sampleCount;
    
    console.log(`\n🎉 DONE!`);
    console.log(`- AWS S3 Upload: SUCCESS`);
    console.log(`- Total Live Samples Captured: ${sampleCount}`);
    
    if (sampleCount === 0) {
      console.log(`\n⚠️ WARNING: 0 samples were captured. Make sure your ESP32 was turned on and sending to 'flexio/${DEVICE_ID}/bundle'!`);
    } else {
      console.log(`\n🚀 The Node backend just pinged your friend's AI laptop with the S3 keys for this live data!`);
    }

  } catch (error) {
    console.error('\n❌ Script Failed!');
    if (error.response) {
      console.error('API Error:', error.response.data);
    } else {
      console.error(error.message);
    }
  }
}

recordLiveMinute();
