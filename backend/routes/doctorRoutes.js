const express = require('express');
const router = express.Router();
const doctorController = require('../controllers/doctorController');
const woundController = require('../controllers/woundController');
const notifController = require('../controllers/notifController');
const authMiddleware = require('../middleware/authMiddleware');

// Protect all doctor routes
router.use(authMiddleware);

// Routes
router.get('/stats', doctorController.getStats);
router.get('/patients', doctorController.getPatients);
router.get('/patients/all', doctorController.getAllPatients);
router.post('/patients/assign', doctorController.assignExistingPatient);
router.post('/patients/add', doctorController.addPatient);
router.post('/exercises/assign', doctorController.assignExercise);
router.get('/appointments/today', doctorController.getTodayAppointments);
router.get('/requests', doctorController.getRequests);
router.put('/requests/:id/accept', doctorController.acceptRequest);
router.put('/requests/:id/reject', doctorController.rejectRequest);

// Recovery Plan for doctor
router.post('/recovery-plan', doctorController.createRecoveryPlan);
router.put('/recovery-plan/:planId/phases/:phaseIndex/approve', doctorController.approvePhase);
router.put('/recovery-plan/:planId/phases/:phaseIndex/decline', doctorController.declinePhase);
router.delete('/recovery-plan/:id', doctorController.deleteRecoveryPlan);

// Specific patient detail profile (Keep this below other /patients specific routes to avoid routing conflicts)
router.get('/patients/:id', doctorController.getPatientProfile);
router.delete('/patients/:id', doctorController.removePatient);

// Wound records for doctor
router.get('/wounds', woundController.getDoctorWounds);

// Notifications for doctor
router.get('/notifications', notifController.getNotifications);
router.put('/notifications/read-all', doctorController.markAllNotificationsRead);
router.put('/notifications/:id/read', notifController.markAsRead);

// Availability for doctor
router.get('/availability', doctorController.getAvailability);
router.put('/availability', doctorController.setAvailability);

module.exports = router;
