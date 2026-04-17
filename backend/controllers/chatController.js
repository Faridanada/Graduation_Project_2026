const dbService = require('../services/dbService');

const chatController = {
    // GET /api/chat
    async getConversations(req, res) {
        try {
            const userId = req.user.id;
            const conversations = await dbService.getConversations(userId);
            res.json({ statusCode: 200, data: conversations });
        } catch (error) {
            console.error('Error fetching conversations:', error);
            res.status(500).json({ statusCode: 500, message: 'Server error fetching conversations' });
        }
    },

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
    },

    // PUT /api/chat/mark-read/:senderId
    async markAsRead(req, res) {
        try {
            const currentUserId = req.user.id;
            const senderId = req.params.senderId;
            await dbService.markMessagesAsRead(senderId, currentUserId);
            res.json({ message: 'Messages marked as read' });
        } catch (error) {
            console.error('Error marking messages as read:', error);
            res.status(500).json({ message: 'Server error marking messages as read' });
        }
    },

    // GET /api/chat/unread-count
    async getUnreadCount(req, res) {
        try {
            const userId = req.user.id;
            const count = await dbService.getUnreadMessageCount(userId);
            res.json({ unreadCount: count });
        } catch (error) {
            console.error('Error fetching unread count:', error);
            res.status(500).json({ message: 'Server error' });
        }
    }
};

module.exports = chatController;
