const express = require('express');
const router = express.Router();
const patientController = require('../controllers/patientController');
const authMiddleware = require('../middleware/authMiddleware');

// Protect all patient routes
router.use(authMiddleware);

// Routes
router.get('/exercises/today', patientController.getTodayExercises);
router.get('/appointments/next', patientController.getNextAppointment);
router.get('/reminders', patientController.getReminders);

router.get('/doctors', patientController.getAllDoctors);
router.post('/request', patientController.sendRequest);

module.exports = router;
