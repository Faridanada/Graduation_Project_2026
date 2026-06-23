const axios = require('axios');

async function testAI() {
  const payload = {
    sessionId: "sess_71fd2016-645b-4749-88f9-559e06495e83",
    patientId: "1773960006547",
    waveformS3Key: "sessions/1773960006547/sess_71fd2016-645b-4749-88f9-559e06495e83/",
    callbackUrl: "http://192.168.1.46:5000/api/sessions/sess_71fd2016-645b-4749-88f9-559e06495e83/report",
    serviceToken: "7d291b5c4f69742a9b1c7e9a0c2b5d4e1f8e9a5c6d3b2a1f0e9d8c7b6a5f4e3d"
  };

  // ⚠️ REPLACE THIS with the IP address of the other laptop running the AI
  const AI_URL = "http://192.168.1.57:8000/process";

  console.log(`Sending payload to ${AI_URL}:\n`, JSON.stringify(payload, null, 2));

  try {
    const res = await axios.post(AI_URL, payload);
    console.log("Response status:", res.status);
    console.log("Response data:", res.data);
  } catch (err) {
    console.error("Error calling AI service:", err.message);
    if (err.response) {
      console.error("AI service response status:", err.response.status);
      console.error("AI service response data:", err.response.data);
    }
  }
}

testAI();
