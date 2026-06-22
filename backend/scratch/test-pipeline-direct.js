require('dotenv').config();
const dbService = require('../services/dbService');
const sessionBuffer = require('../services/sessionBuffer');
const mqttService = require('../services/mqttService');
const sessionController = require('../controllers/sessionController');

async function testFullPipeline() {
  const deviceId = "test-device-1";
  const patientId = "1773960006547";
  
  console.log('1. Mocking dbService to force-create an active session...');
  
  dbService.getDeviceById = async (id) => {
    if (id === deviceId) return { id: deviceId, patientId };
    return null;
  };
  
  const newSession = await dbService.createSession(patientId, {
    deviceId: deviceId,
    exerciseId: 'ex_passive_knee',
    status: 'active',
    startTime: new Date().toISOString()
  });
  
  const sessionId = newSession.id;
  console.log(`Created Session ID: ${sessionId} in DynamoDB`);

  console.log('2. Starting Session Buffer locally...');
  sessionBuffer.startSession(sessionId, patientId, 'ex_passive_knee', deviceId);

  console.log('3. Simulating MQTT Stream via mqttService.handleStreamString()...');
  
  let payloadStr = "";
  const TOTAL_SAMPLES = 140;
  for (let i = 0; i < TOTAL_SAMPLES; i++) {
    const cyclePosition = i / TOTAL_SAMPLES;
    const activation = Math.sin(Math.PI * cyclePosition);

    const emg1 = (0.05 + activation * 0.9).toFixed(4);
    const emg2 = (0.03 + activation * 0.12).toFixed(4);
    const thighPitch = activation * 70 * 0.25;
    const tAx = Math.sin(thighPitch * Math.PI / 180).toFixed(4);
    const tAz = Math.cos(thighPitch * Math.PI / 180).toFixed(4);
    const shinPitch = activation * 70;
    const sAx = Math.sin(shinPitch * Math.PI / 180).toFixed(4);
    const sAz = Math.cos(shinPitch * Math.PI / 180).toFixed(4);

    payloadStr += `${emg1} ${emg2} 1 1 ${tAx} 0.0000 ${tAz} 0 0 0 ${sAx} 0.0000 ${sAz} 0 0 0\n`;
  }

  // Push directly into the parser
  await mqttService.handleStreamString(`flexio/${deviceId}/stream`, payloadStr);

  console.log('4. Stream processed! Verifying buffer...');
  const activeBuffer = sessionBuffer.sessions.get(sessionId);
  console.log(`   Buffer contains ${activeBuffer.sampleCount} samples.`);
  
  console.log('5. Manually invoking endSession()...');
  // Mock req/res to bypass express HTTP
  const req = {
    params: { sessionId },
    body: { status: 'completed' },
    user: { id: patientId, role: 'patient' }
  };
  
  const res = {
    json: (data) => console.log('endSession Output:', data),
    status: (code) => {
      console.log(`HTTP Status: ${code}`);
      return res;
    }
  };

  try {
    await sessionController.endSession(req, res);
    console.log('Test Complete! Look for the AI prediction logs above.');
  } catch (err) {
    console.error("endSession crashed:", err);
  }
}

testFullPipeline();
