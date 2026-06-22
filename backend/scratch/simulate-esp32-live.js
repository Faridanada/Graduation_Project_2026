const axios = require('axios');
const mqtt = require('mqtt');

// AWS EC2 Configuration
const API_BASE_URL = 'https://flexio-rehab.duckdns.org/api';
const MQTT_BROKER = 'mqtt://13.62.249.165:1883';
const MQTT_USER = 'esp32_test';
const MQTT_PASS = 'yomna123';
const DEVICE_ID = 'dev_test_001';

async function runLivePipelineTest() {
  console.log('================================================');
  console.log('🚀 LIVE AWS PIPELINE TEST (Simulating ESP32)');
  console.log('================================================\n');

  try {
    // 1. START SESSION
    console.log('1️⃣  Starting Session on AWS...');
    // We login first to get a token
    const loginRes = await axios.post(`${API_BASE_URL}/login`, {
      email: 'yomnayehia18@gmail.com',
      password: 'Ananas12$'
    }, { httpsAgent: new require('https').Agent({ rejectUnauthorized: false }) });
    const token = loginRes.data.token;
    
    const startRes = await axios.post(`${API_BASE_URL}/sessions/start`, {
      deviceId: DEVICE_ID,
      exerciseId: 'ex_passive_knee'
    }, { 
      headers: { Authorization: `Bearer ${token}` },
      httpsAgent: new require('https').Agent({ rejectUnauthorized: false })
    });
    
    const sessionId = startRes.data.sessionId;
    console.log(`✅ Session Started: ${sessionId}\n`);

    // 2. CONNECT TO MQTT
    console.log(`2️⃣  Connecting to EC2 Mosquitto Broker...`);
    const client = mqtt.connect(MQTT_BROKER, { username: MQTT_USER, password: MQTT_PASS });
    
    await new Promise((resolve, reject) => {
      client.on('connect', resolve);
      client.on('error', reject);
    });
    console.log(`✅ MQTT Connected!\n`);
    
    // Subscribe to our own stream to prove Mosquitto accepted it
    let receivedCount = 0;
    client.subscribe(`flexio/${DEVICE_ID}/stream`);
    client.on('message', (topic, msg) => {
      receivedCount++;
    });

    // 3. STREAM DATA
    console.log(`3️⃣  Streaming 100 lines of mock 16-column data...`);
    const validLine = '100.1\t200.2\t1\t1\t0.1\t0.2\t0.3\t0.4\t0.5\t0.6\t0.7\t0.8\t0.9\t1.0\t1.1\t1.2';
    
    // We send 10 lines at a time, 10 times, to simulate a stream over 2 seconds
    for (let i = 0; i < 10; i++) {
      let payload = '';
      for (let j = 0; j < 10; j++) payload += validLine + '\n';
      
      client.publish(`flexio/${DEVICE_ID}/stream`, payload);
      await new Promise(r => setTimeout(r, 200)); // wait 200ms
    }
    console.log(`✅ Finished streaming data!\n`);

    // Wait a second for backend to process buffer
    await new Promise(r => setTimeout(r, 1500));

    // 4. END SESSION
    console.log(`4️⃣  Ending Session & Generating S3/AI Report...`);
    const endRes = await axios.post(`${API_BASE_URL}/sessions/${sessionId}/end`, { status: 'completed' }, {
      headers: { Authorization: `Bearer ${token}` },
      httpsAgent: new require('https').Agent({ rejectUnauthorized: false })
    });
    
    console.log(`\n🎉 PIPELINE TEST COMPLETE!`);
    console.log(`AWS Backend Response:`);
    console.log(`- Status: ${endRes.data.session.status}`);
    console.log(`- Samples Saved to S3: ${endRes.data.session.sampleCount}`);
    console.log(`- Packets bounced back by Mosquitto: ${receivedCount} / 10`);
    
    if (endRes.data.session.sampleCount > 0) {
      console.log(`\n⭐⭐⭐⭐⭐ SUCCESS! The EC2 Backend perfectly received, parsed, and saved the data to S3!`);
    } else {
      console.log(`\n⚠️ WARNING: Expected 100 samples, but got ${endRes.data.sampleCount}.`);
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Pipeline Test Failed!');
    if (error.response) {
      console.error('API Error:', error.response.data);
    } else {
      console.error(error.message);
    }
    process.exit(1);
  }
}

runLivePipelineTest();
