import 'package:flutter/material.dart';

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({Key? key}) : super(key: key);

  @override
  State<NotificationPreferencesPage> createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends State<NotificationPreferencesPage> {
  bool _appointmentReminders = true;
  bool _progressUpdates = true;
  bool _exerciseReminders = true;
  bool _messageNotifications = true;
  bool _systemNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF6BA5CF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () { if (Navigator.canPop(context)) Navigator.pop(context); },
        ),
        title: const Text(
          'Notification Preferences',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification Types',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                _buildNotificationSwitch(
                  'Appointment Reminders',
                  'Get reminded about upcoming patient appointments',
                  _appointmentReminders,
                  (value) {
                    setState(() {
                      _appointmentReminders = value;
                    });
                  },
                ),
                _buildNotificationSwitch(
                  'Progress Updates',
                  'Receive updates about patient recovery milestones',
                  _progressUpdates,
                  (value) {
                    setState(() {
                      _progressUpdates = value;
                    });
                  },
                ),
                _buildNotificationSwitch(
                  'Exercise Reminders',
                  'Get notified when patients skip scheduled exercises',
                  _exerciseReminders,
                  (value) {
                    setState(() {
                      _exerciseReminders = value;
                    });
                  },
                ),
                _buildNotificationSwitch(
                  'Message Notifications',
                  'Receive notifications for new patient messages',
                  _messageNotifications,
                  (value) {
                    setState(() {
                      _messageNotifications = value;
                    });
                  },
                ),
                _buildNotificationSwitch(
                  'System Notifications',
                  'Receive system and app updates',
                  _systemNotifications,
                  (value) {
                    setState(() {
                      _systemNotifications = value;
                    });
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Preferences saved!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6BA5CF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Preferences',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSwitch(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF6BA5CF),
          ),
        ],
      ),
    );
  }
}


