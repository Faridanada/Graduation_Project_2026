require('dotenv').config();
const { triggerReportGeneration } = require('../services/reportTrigger');

async function testBackendTrigger() {
  const sessionId = "sess_71fd2016-645b-4749-88f9-559e06495e83";
  const patientId = "1773960006547";
  const waveformS3Key = "sessions/1773960006547/sess_71fd2016-645b-4749-88f9-559e06495e83/";

  console.log("Starting backend S3 download and AI processing...");
  await triggerReportGeneration(sessionId, patientId, waveformS3Key);
  console.log("Done!");
}

testBackendTrigger();
