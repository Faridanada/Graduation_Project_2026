import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/ui/shared/NotificationsPage.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ApiService.unreadNotificationsNotifier,
      builder: (context, unreadCount, child) {
        final labelText = unreadCount > 9 ? '9+' : '$unreadCount';
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text(labelText),
              child: const Icon(
                Icons.notifications_none,
                color: Colors.black,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }
}
