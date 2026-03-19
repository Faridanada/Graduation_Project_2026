const express = require('express');
const router = express.Router();
const appointmentController = require('../controllers/appointmentController');
const authMiddleware = require('../middleware/authMiddleware');

// Protect all appointment routes
router.use(authMiddleware);

// GET /api/appointments
router.get('/', appointmentController.getAppointments);

// POST /api/appointments
router.post('/', appointmentController.createAppointment);

module.exports = router;
