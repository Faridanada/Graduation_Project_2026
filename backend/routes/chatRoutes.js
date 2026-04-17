const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const authMiddleware = require('../middleware/authMiddleware');

// Protect all chat routes
router.use(authMiddleware);

// GET /api/chat
router.get('/', chatController.getConversations);

// GET /api/chat/unread-count
router.get('/unread-count', chatController.getUnreadCount);

// GET /api/chat/:userId
router.get('/:userId', chatController.getChatHistory);

// POST /api/chat
router.post('/', chatController.sendMessage);

// PUT /api/chat/mark-read/:senderId
router.put('/mark-read/:senderId', chatController.markAsRead);

module.exports = router;
