import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rehabilitation_app/ui/patient/home/patientHome.dart';
import 'package:rehabilitation_app/services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool isLoading = true;
  List<dynamic> remindersList = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _fetchReminders();
  }

  Future<void> _fetchReminders() async {
    try {
      final fetchedReminders = await ApiService.getPatientReminders();
      if (mounted) {
        setState(() {
          remindersList = fetchedReminders;
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEAF2FF), Color(0xFFF7FAFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                /// HEADER
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PatientHomeScreen())),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Reminders",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                if (isLoading)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ))
                else if (remindersList.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text("No reminders at the moment!", 
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  )
                else
                  ...remindersList.map((reminder) => _buildReminderCard(reminder)),
                
              ],
            ),
          ),
        ),

        /// NAV BAR
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.black54, // Dull color so it doesn't look "lit up"
          unselectedItemColor: Colors.black54,
          showUnselectedLabels: true,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PatientHomeScreen()));
            } else if (index == 1) {
              // Ignore or route to chats
            } else if (index == 2) {
              // Ignore or route to profile
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chats"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard(dynamic reminder) {
    String title = reminder['title'] ?? 'Reminder';
    String message = reminder['message'] ?? 'You have a new reminder.';
    String time = reminder['time'] ?? 'Today';
    bool completed = reminder['completed'] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _glassCard(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: completed ? Colors.green[100] : Colors.blue[100],
              child: Icon(
                completed ? Icons.check : Icons.notification_important,
                color: completed ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                _chip(completed ? "Done" : "Pending", completed ? Colors.green : Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🌟 GLASS UI
  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ),
    );
  }

  /// 🔴🟢🟡 DOT
  Widget _statusDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  /// CHIP
  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11)),
    );
  }

  /// SWIPE BG
  Widget _swipeBg(Color color, IconData icon) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: color.withValues(alpha: 0.2),
      child: Icon(icon, color: color),
    );
  }
}
