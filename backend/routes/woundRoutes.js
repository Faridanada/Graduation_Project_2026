const express = require('express');
const router = express.Router();
const woundController = require('../controllers/woundController');
const authMiddleware = require('../middleware/authMiddleware');
const multer = require('multer');

const path = require('path');

// Configure multer with named disk storage (EC2-ready)
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/wounds/'),
  filename: (req, file, cb) => {
    const suffix = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
    cb(null, `wound-${suffix}${path.extname(file.originalname)}`);
  }
});
const upload = multer({ storage });

// Protect all wound routes
router.use(authMiddleware);

// POST /api/wounds — patient submits wound (multipart field: "woundImage")
router.post('/', upload.single('woundImage'), woundController.createWoundRecord);

// GET /api/wounds — patient gets their own wound history
router.get('/', woundController.getMyWounds);

// GET /api/wounds/patient/:patientId — doctor views a specific patient's wounds
router.get('/patient/:patientId', woundController.getPatientWounds);

// PUT /api/wounds/:id/status — doctor marks wound as reviewed/healed
router.put('/:id/status', woundController.updateWoundStatus);

module.exports = router;
