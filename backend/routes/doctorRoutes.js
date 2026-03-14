const express = require('express');
const router = express.Router();
const doctorController = require('../controllers/doctorController');
const authMiddleware = require('../middleware/authMiddleware');

// Protect all doctor routes
router.use(authMiddleware);

// Routes
router.get('/stats', doctorController.getStats);
router.get('/patients', doctorController.getPatients);
router.get('/appointments/today', doctorController.getTodayAppointments);

module.exports = router;
