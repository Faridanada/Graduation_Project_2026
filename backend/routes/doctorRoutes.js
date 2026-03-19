const express = require('express');
const router = express.Router();
const doctorController = require('../controllers/doctorController');
const authMiddleware = require('../middleware/authMiddleware');

// Protect all doctor routes
router.use(authMiddleware);

// Routes
router.get('/stats', doctorController.getStats);
router.get('/patients', doctorController.getPatients);
router.post('/patients/add', doctorController.addPatient);
router.get('/appointments/today', doctorController.getTodayAppointments);
router.get('/requests', doctorController.getRequests);
router.put('/requests/:id/accept', doctorController.acceptRequest);
router.put('/requests/:id/reject', doctorController.rejectRequest);

// Specific patient detail profile (Keep this below other /patients specific routes to avoid routing conflicts)
router.get('/patients/:id', doctorController.getPatientProfile);

module.exports = router;
