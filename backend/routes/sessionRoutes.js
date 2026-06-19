const express = require('express');
const router = express.Router();
const sessionController = require('../controllers/sessionController');
const authMiddleware = require('../middleware/authMiddleware');

router.use(authMiddleware);

// Devices
router.post('/devices', sessionController.registerDevice);
router.get('/devices/me', sessionController.getMyDevices);

// Sessions
router.post('/start', sessionController.startSession);
router.post('/:sessionId/end', sessionController.endSession);
router.post('/:sessionId/abort', sessionController.abortSession);
router.get('/patient/:patientId', sessionController.getPatientSessions);
router.get('/:sessionId', sessionController.getSessionDetails);
router.post('/:sessionId/simulate', sessionController.simulateTelemetry);
router.get('/:sessionId/waveform', sessionController.getSessionWaveformUrls);

module.exports = router;
