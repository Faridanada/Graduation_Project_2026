const axios = require('axios');

async function testPatchReport() {
  const sessionId = "sess_71fd2016-645b-4749-88f9-559e06495e83";
  const url = `http://localhost:5000/api/sessions/${sessionId}/report`;
  
  // From .env
  const serviceToken = "7d291b5c4f69742a9b1c7e9a0c2b5d4e1f8e9a5c6d3b2a1f0e9d8c7b6a5f4e3d";
  
  const payload = {
    report: {
      generatedAt: new Date().toISOString(),
      model: "claude-sonnet-3.5",
      summary: "This is a mock report generated from our test script.",
      metrics: {
        duration: { value: 600, unit: "seconds" },
        repetitionsCompleted: 15,
        rangeOfMotion: {
          imu1: { min: 10, max: 120, average: 65 },
          imu2: { min: 12, max: 118, average: 64 }
        },
        peakEmg: {
          emg1: { peak: 0.8, rms: 0.4 },
          emg2: { peak: 0.75, rms: 0.38 }
        },
        muscleSymmetry: { score: 0.9, interpretation: "Good" },
        fatigueIndex: { emg1: 0.8, emg2: 0.85, interpretation: "Minimal fatigue" }
      },
      observations: ["Good range of motion observed.", "Patient maintained steady pace."],
      concerns: [
        { severity: "low", type: "fatigue", description: "Slight decrease in EMG amplitude towards end." }
      ],
      recommendations: ["Continue current plan", "Increase reps by 5 next week"],
      safetyEvents: []
    }
  };

  console.log(`Sending PATCH request to ${url}...`);

  try {
    const res = await axios.patch(url, payload, {
      headers: {
        'x-service-token': serviceToken,
        'Content-Type': 'application/json'
      }
    });
    console.log("Success! Response status:", res.status);
    console.log("Response data:", res.data);
  } catch (err) {
    console.error("Error sending request:", err.message);
    if (err.response) {
      console.error("Response status:", err.response.status);
      console.error("Response data:", err.response.data);
    }
  }
}

testPatchReport();
