require('dotenv').config();
const axios = require('axios');
const https = require('https');

async function controlSession() {
  const agent = new https.Agent({ rejectUnauthorized: false });
  const baseUrl = "https://13.62.249.165/api";
  const deviceId = "dev_test_001";
  
  console.log("1. Logging in as patient...");
  let token, sessionId;
  try {
    const loginRes = await axios.post(`${baseUrl}/login`, {
      email: "yomnayehia18@gmail.com",
      password: "Ananas12$"
    }, { httpsAgent: agent });
    token = loginRes.data.token;

    console.log("2. Starting Session...");
    const sessionRes = await axios.post(`${baseUrl}/sessions/start`, {
      deviceId: deviceId,
      exerciseId: 'ex_passive_knee'
    }, {
      headers: { Authorization: `Bearer ${token}` },
      httpsAgent: agent
    });
    sessionId = sessionRes.data.sessionId;
    console.log(`\n✅ Session STARTED! [ID: ${sessionId}]`);
    console.log("-----------------------------------------------------");
    console.log("🔌 TURN ON YOUR ESP32 NOW!");
    console.log("The backend is now listening to your EC2 Mosquitto.");
    console.log("Data streamed from your ESP32 will be captured.");
    console.log("-----------------------------------------------------\n");

  } catch (err) {
    console.error("Failed to start:", err.response?.data || err.message);
    process.exit(1);
  }

  // Wait 60 seconds to collect data from the real STM32 -> ESP32
  let secondsLeft = 60;
  const timer = setInterval(() => {
    process.stdout.write(`\rRecording data from ESP32... Ending session in ${secondsLeft} seconds...`);
    secondsLeft--;
  }, 1000);

  setTimeout(async () => {
    clearInterval(timer);
    console.log("\n\n3. Ending Session & Triggering S3 Upload...");
    try {
      const endRes = await axios.post(`${baseUrl}/sessions/${sessionId}/end`, { status: 'completed' }, {
        headers: { Authorization: `Bearer ${token}` },
        httpsAgent: agent
      });
      console.log("\n✅ Session ENDED successfully!");
      console.log("Your backend just uploaded the CSVs to S3 and called the AI!");
      console.log("\nBackend Response:", JSON.stringify(endRes.data.session, null, 2));
    } catch (err) {
      console.error("\n❌ Failed to end session:", err.response?.data || err.message);
    }
  }, 60000);
}

controlSession();
