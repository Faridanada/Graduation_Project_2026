import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildNotificationCard(
                  icon: Icons.calendar_today,
                  iconColor: Colors.blue,
                  iconBgColor: Colors.blue.withOpacity(0.1),
                  title: 'Appointment Reminder',
                  message: 'You have a patient session today at 11:30 AM',
                  time: '10 min ago',
                ),
                _buildNotificationCard(
                  icon: Icons.check_circle_outline,
                  iconColor: Colors.green,
                  iconBgColor: Colors.green.withOpacity(0.1),
                  title: 'Exercise Completed 🎉',
                  message: 'John Doe finished today\'s exercise session!',
                  time: '1 hour ago',
                ),
                _buildNotificationCard(
                  icon: Icons.mail_outline,
                  iconColor: Colors.blue,
                  iconBgColor: Colors.blue.withOpacity(0.1),
                  title: 'New Message',
                  message: 'Sarah Johnson sent you a message',
                  time: '2 hours ago',
                ),
                _buildNotificationCard(
                  icon: Icons.check_circle_outline,
                  iconColor: Colors.green,
                  iconBgColor: Colors.green.withOpacity(0.1),
                  title: 'Wound Review Update',
                  message: 'New wound photo uploaded by patient.',
                  time: 'Yesterday',
                ),
                _buildNotificationCard(
                  icon: Icons.error_outline,
                  iconColor: Colors.red,
                  iconBgColor: Colors.red.withOpacity(0.1),
                  title: 'Recovery Alert',
                  message: 'Patient compliance decreased this week.',
                  time: '2 days ago',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String message,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
