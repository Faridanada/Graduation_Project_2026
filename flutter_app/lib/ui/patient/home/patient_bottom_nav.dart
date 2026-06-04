import 'package:flutter/material.dart';

import 'package:rehabilitation_app/ui/chats/Chats.dart';
import 'package:rehabilitation_app/ui/patient/profile/PatientProfile.dart';
import 'package:rehabilitation_app/ui/patient/home/patientHome.dart';

class PatientBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const PatientBottomNavBar({
    super.key,
    this.currentIndex = 0,
  });

  void _goToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
    );
  }

  void _goToChats(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const Chats(showNavBar: false)),
    );
  }

  void _goToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PatientProfile(isTab: false)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF2196F3),
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
