const express = require('express');
const router = express.Router();
const woundController = require('../controllers/woundController');
const authMiddleware = require('../middleware/authMiddleware');
const multer = require('multer');

// Configure multer for saving uploads to backend /uploads directory
const upload = multer({ dest: 'uploads/' });

// Protect all wound routes
router.use(authMiddleware);

// POST /api/wounds (Requires a multipart/form-data upload field called "woundImage")
router.post('/', upload.single('woundImage'), woundController.createWoundRecord);

// GET /api/wounds/patient/:patientId
router.get('/patient/:patientId', woundController.getPatientWounds);

// PUT /api/wounds/:id/status
router.put('/:id/status', woundController.updateWoundStatus);

module.exports = router;
