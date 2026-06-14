const express = require('express');
const router = express.Router();
const woundController = require('../controllers/woundController');
const authMiddleware = require('../middleware/authMiddleware');
const { woundImageUpload } = require('../middleware/s3Storage');

// Protect all wound routes
router.use(authMiddleware);

// POST /api/wounds — patient submits wound (multipart field: "woundImage")
router.post('/', woundImageUpload.single('woundImage'), woundController.createWoundRecord);

// GET /api/wounds — patient gets their own wound history
router.get('/', woundController.getMyWounds);

// GET /api/wounds/patient/:patientId — doctor views a specific patient's wounds
router.get('/patient/:patientId', woundController.getPatientWounds);

// PUT /api/wounds/:id/status — doctor marks wound as reviewed/healed
router.put('/:id/status', woundController.updateWoundStatus);

module.exports = router;
