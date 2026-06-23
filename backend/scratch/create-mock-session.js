require('dotenv').config();
const { flushSessionToS3 } = require('../utils/waveformWriter');
const { triggerReportGeneration } = require('../services/reportTrigger');

async function createMockSession() {
  const patientId = "1773960006547";
  const sessionId = "sess_mock_" + Date.now();

  console.log(`Generating 140 samples of perfect, noise-free rehab data for session: ${sessionId}`);

  const TOTAL_SAMPLES = 140;

  const emgSamples1 = [];
  const emgSamples2 = [];
  const imuSamples = [];

  for (let i = 0; i < TOTAL_SAMPLES; i++) {
    // 1 smooth cycle over the 140 samples (half sine wave: 0 -> 1 -> 0)
    const cyclePosition = i / TOTAL_SAMPLES;
    const activation = Math.sin(Math.PI * cyclePosition);

    // Clean EMG signals (absolutely NO Math.random noise)
    const emg1 = Math.max(0.02, Math.min(1.0, 0.05 + activation * 0.9));
    const emg2 = Math.max(0.02, Math.min(0.3, 0.03 + activation * 0.12));

    emgSamples1.push(Number(emg1.toFixed(4)));
    emgSamples2.push(Number(emg2.toFixed(4)));

    // Clean IMU signals
    const kneeAngle = activation * 70; // 0 to 70 degrees
    const thighPitch = kneeAngle * 0.25;
    const shinPitch = kneeAngle;

    const thighRad = (thighPitch * Math.PI) / 180;
    const shinRad = (shinPitch * Math.PI) / 180;

    imuSamples.push({
      kneeAngle: Number(kneeAngle.toFixed(2)),
      thighGravity: [
        Number(Math.sin(thighRad).toFixed(4)),
        0.0000,
        Number(Math.cos(thighRad).toFixed(4))
      ],
      shinGravity: [
        Number(Math.sin(shinRad).toFixed(4)),
        0.0000,
        Number(Math.cos(shinRad).toFixed(4))
      ]
    });
  }

  const buffer = {
    patientId,
    emg: [
      {
        ts: Date.now(),
        sensors: [
          { ch: 'emg1', samples: emgSamples1 },
          { ch: 'emg2', samples: emgSamples2 }
        ]
      }
    ],
    imu: [
      {
        ts: Date.now(),
        samples: imuSamples
      }
    ],
    events: []
  };

  console.log(`Uploading noise-free CSVs to S3 using the new wide format...`);
  const s3Prefix = await flushSessionToS3(sessionId, buffer);
  console.log(`Successfully uploaded to S3: ${s3Prefix}`);

  console.log(`Triggering the AI backend process...`);
  await triggerReportGeneration(sessionId, patientId, s3Prefix);
  console.log(`Mock test complete!`);
}

createMockSession().catch(err => console.error("Test failed:", err));