import 'package:flutter/material.dart';

import 'package:rehabilitation_app/ui/patient/home/patientHome.dart';

class PatientBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final bool hideActiveState;

  const PatientBottomNavBar({
    super.key,
    this.currentIndex = 0,
    this.hideActiveState = false,
  });

  void _goToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PatientHomeScreen(initialTab: 0)),
      (route) => false,
    );
  }

  void _goToChats(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PatientHomeScreen(initialTab: 1)),
      (route) => false,
    );
  }

  void _goToProfile(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PatientHomeScreen(initialTab: 2)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor:
          hideActiveState ? Colors.grey : const Color(0xFF2196F3),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        switch (index) {
          case 0:
            _goToHome(context);
            break;
          case 1:
            _goToChats(context);
            break;
          case 2:
            _goToProfile(context);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline_rounded),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
