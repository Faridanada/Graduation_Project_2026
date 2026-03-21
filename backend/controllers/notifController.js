const dbService = require('../services/dbService');

const notifController = {

  // GET /api/doctor/notifications
  async getNotifications(req, res) {
    try {
      if (!req.user) return res.status(401).json({ message: 'Unauthorized' });
      const notifications = await dbService.getNotificationsForUser(req.user.id);
      res.json({ data: notifications });
    } catch (error) {
      console.error('Error fetching notifications:', error);
      res.status(500).json({ message: 'Server error' });
    }
  },

  // PUT /api/doctor/notifications/:id/read
  async markAsRead(req, res) {
    try {
      if (!req.user) return res.status(401).json({ message: 'Unauthorized' });
      await dbService.markNotificationRead(req.params.id);
      res.json({ message: 'Notification marked as read' });
    } catch (error) {
      console.error('Error marking notification as read:', error);
      res.status(500).json({ message: 'Server error' });
    }
  },
};

module.exports = notifController;
