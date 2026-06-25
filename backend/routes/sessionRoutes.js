const express = require('express');
const router = express.Router();
const sessionController = require('../controllers/sessionController');
const authMiddleware = require('../middleware/authMiddleware');
const reportController = require('../controllers/reportController');

// === PUBLIC routes (service-token auth only or hardware unprotected) ===
router.patch('/:sessionId/report', sessionController.receiveAiReport);

// === Everything below here requires JWT ===
router.use(authMiddleware);

// Devices
router.post('/devices', sessionController.registerDevice);
router.get('/devices/me', sessionController.getMyDevices);

// Sessions
router.post('/start', sessionController.startSession);
router.post('/:sessionId/end', sessionController.endSession);
router.post('/:sessionId/abort', sessionController.abortSession);
router.get('/patient/:patientId', sessionController.getPatientSessions);
router.get('/patients/:patientId/active-session', sessionController.getActiveSessionForPatient);
router.get('/:sessionId', sessionController.getSessionDetails);
router.post('/:sessionId/simulate', sessionController.simulateTelemetry);
router.get('/:sessionId/waveform', sessionController.getSessionWaveformUrls);
router.post('/:sessionId/calibrate', sessionController.calibrateSession);
router.post('/:sessionId/command', sessionController.commandSession);

// Reports
router.get('/:sessionId/report', reportController.getReport);
router.post('/:sessionId/regenerate-report', reportController.regenerateReport);

module.exports = router;
