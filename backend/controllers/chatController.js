const dbService = require('../services/dbService');

const chatController = {
    // GET /api/chat/:userId
    // Fetches the chat history between the currently logged-in user and another user
    async getChatHistory(req, res) {
        try {
            const currentUserId = req.user.id; // From authMiddleware
            const otherUserId = req.params.userId;

            const messages = await dbService.getChatHistory(currentUserId, otherUserId);
            res.json({ statusCode: 200, data: messages });
        } catch (error) {
            console.error('Error fetching chat history:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error fetching chat history' });
        }
    },

    // POST /api/chat
    // Sends a message from the currently logged-in user to another user
    async sendMessage(req, res) {
        try {
            const senderId = req.user.id; // From authMiddleware
            const { receiverId, messageText } = req.body;

            if (!receiverId || !messageText) {
                return res.status(400).json({ statusCode: 400, message: 'receiverId and messageText are required' });
            }

            const sentMessage = await dbService.sendMessage(senderId, receiverId, messageText);
            res.status(201).json({ statusCode: 201, data: sentMessage, message: 'Message sent successfully' });
        } catch (error) {
            console.error('Error sending message:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error sending message' });
        }
    }
};

module.exports = chatController;
