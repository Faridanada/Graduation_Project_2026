const express = require('express');
const router = express.Router();
const patientController = require('../controllers/patientController');
const authMiddleware = require('../middleware/authMiddleware');

// Protect all patient routes
router.use(authMiddleware);

// Profile
router.get('/profile', patientController.getProfile);
router.put('/profile', patientController.updateProfile);
router.get('/stats', patientController.getDashboardStats);

// Exercises
router.get('/exercises/today', patientController.getTodayExercises);
router.get('/exercises', patientController.getAllExercises);
router.put('/exercises/:id/complete', patientController.completeExercise);

// Appointments
router.get('/appointments', patientController.getAppointments);
router.get('/appointments/next', patientController.getNextAppointment);

// Assigned doctor
router.get('/doctor', patientController.getMyDoctor);

// Reminders
router.get('/reminders', patientController.getReminders);

// Notifications
router.get('/notifications', patientController.getNotifications);
router.put('/notifications/:id/read', patientController.markNotificationRead);

// Doctor discovery & requests
router.get('/doctors', patientController.getAllDoctors);
router.post('/request', patientController.sendRequest);
router.get('/doctors/:id/availability', patientController.getDoctorAvailability);

module.exports = router;
