import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'patientRequest.dart';
import 'Chats.dart';
import 'ManageWounds.dart';
import 'ActivePatientsPage.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final data = await ApiService.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await ApiService.markNotificationRead(id);
      // Optimistically update UI
      if (mounted) {
        setState(() {
          final index = _notifications.indexWhere((n) => n['id'] == id);
          if (index != -1) {
            _notifications[index]['isRead'] = true;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _markAllAsRead() async {
    try {
      await ApiService.markAllNotificationsRead();
      if (mounted) {
        setState(() {
          for (var i = 0; i < _notifications.length; i++) {
            _notifications[i]['isRead'] = true;
          }
        });
      }
    } catch (_) {}
  }

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
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.blue),
            tooltip: 'Mark all as read',
            onPressed: () {
              if (_notifications.any((n) => !(n['isRead'] ?? false))) {
                _markAllAsRead();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: _fetchNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : SafeArea(
                  child: RefreshIndicator(
                    onRefresh: _fetchNotifications,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notif = _notifications[index];
                        return _buildNotificationCard(notif);
                      },
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "We'll let you know when there's an update.",
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif) {
    final bool isRead = notif['isRead'] ?? false;
    final String type = notif['title'] ?? '';

    IconData iconData = Icons.notifications;
    Color iconColor = Colors.blue;

    if (type.contains('Message')) {
      iconData = Icons.mail_outline;
      iconColor = Colors.orange;
    } else if (type.contains('Wound') || type.contains('Recovery')) {
      iconData = Icons.healing_outlined;
      iconColor = Colors.red;
    } else if (type.contains('Exercise')) {
      iconData = Icons.check_circle_outline;
      iconColor = Colors.green;
    }

    return GestureDetector(
      onTap: () {
        if (!isRead) _markAsRead(notif['id']);

        // Navigate based on notification type
        if (type.contains('Connection Request')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PatientRequest()),
          );
        } else if (type.contains('Message')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Chats(showNavBar: true),
            ),
          );
        } else if (type.contains('Wound')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManageWounds()),
          );
        } else if (type.contains('Exercise') || type.contains('Recovery')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ActivePatientsPage()),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isRead
              ? null
              : Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: iconColor, size: 24),
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
                          notif['title'] ?? 'Notification',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                isRead ? FontWeight.w600 : FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: Colors.blue, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif['message'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(notif['createdAt']),
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(dynamic dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return dateStr.toString();
    }
  }
}
