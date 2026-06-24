require('dotenv').config();
const { flushSessionToS3 } = require('../utils/waveformWriter');
const { triggerReportGeneration } = require('../services/reportTrigger');

async function createMockSession() {
  const patientId = "1773960006547";
  const sessionId = "sess_mock_" + Date.now();

  console.log(`Generating 140 samples of perfect, noise-free rehab data for session: ${sessionId}`);

  const TOTAL_SAMPLES = 140;

  const emgSamples = [];
  const imuSamples = [];

  const baseTime = Date.now();

  for (let i = 0; i < TOTAL_SAMPLES; i++) {
    const ts = baseTime + (i * 20); // 50Hz = 20ms per sample
    const cyclePosition = i / TOTAL_SAMPLES;
    const activation = Math.sin(Math.PI * cyclePosition);

    // Flat EMG data (2 data columns + 2 on columns = 4 columns + ts = 5 columns in CSV)
    const emg1 = Math.max(0.02, Math.min(1.0, 0.05 + activation * 0.9));
    const emg2 = Math.max(0.02, Math.min(0.3, 0.03 + activation * 0.12));

    emgSamples.push({
      ts,
      emg1: Number(emg1.toFixed(4)),
      emg2: Number(emg2.toFixed(4)),
      on1: 1,
      on2: 1
    });

    // Flat IMU data (12 data columns + ts = 13 columns in CSV)
    // 12 IMU columns + 4 EMG columns = 16 data columns total across the two CSVs
    const kneeAngle = activation * 70; // 0 to 70 degrees
    const thighPitch = kneeAngle * 0.25;
    const shinPitch = kneeAngle;

    const thighRad = (thighPitch * Math.PI) / 180;
    const shinRad = (shinPitch * Math.PI) / 180;

    // We populate the 12 columns: ax1..gz1 and ax2..gz2
    imuSamples.push({
      ts,
      ax1: Number(Math.sin(thighRad).toFixed(4)),
      ay1: 0.0000,
      az1: Number(Math.cos(thighRad).toFixed(4)),
      gx1: 0.01, gy1: 0.0, gz1: 0.0,
      ax2: Number(Math.sin(shinRad).toFixed(4)),
      ay2: 0.0000,
      az2: Number(Math.cos(shinRad).toFixed(4)),
      gx2: 0.01, gy2: 0.0, gz2: 0.0
    });
  }

  const buffer = {
    patientId,
    emg: emgSamples,
    imu: imuSamples,
    events: []
  };

  console.log(`Uploading noise-free CSVs to S3 using the flat 16-column format...`);
  const s3Prefix = await flushSessionToS3(sessionId, buffer);
  console.log(`Successfully uploaded to S3: ${s3Prefix}`);

  console.log(`Triggering the AI backend process...`);
  await triggerReportGeneration(sessionId, patientId, s3Prefix);
  console.log(`Mock test complete!`);
}

createMockSession().catch(err => console.error("Test failed:", err));