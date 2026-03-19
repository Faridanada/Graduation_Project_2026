const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const authMiddleware = require('../middleware/authMiddleware');

// Protect all chat routes
router.use(authMiddleware);

// GET /api/chat/:userId
router.get('/:userId', chatController.getChatHistory);

// POST /api/chat
router.post('/', chatController.sendMessage);

module.exports = router;
