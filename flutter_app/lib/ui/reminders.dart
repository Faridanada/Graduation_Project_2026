import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'patientHome.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool medicationTaken = false;

  int remainingMinutes = 20;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    /// ⏱ REAL-TIME COUNTDOWN
    timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (remainingMinutes > 0) {
        setState(() {
          remainingMinutes--;
        });
      }
    });
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
                      "Notifications",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Stack(
                      children: [
                        const Icon(Icons.notifications_none),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              "1",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.settings),
                  ],
                ),

                const SizedBox(height: 20),

                /// 🔔 NEXT REMINDER (UPDATED)
                _glassCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.notifications, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Next Reminder in $remainingMinutes min",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "💊 Medication at 09:00 AM",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "TODAY",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                /// 💊 MEDICATION
                Dismissible(
                  key: const Key("medication"),
                  background: _swipeBg(Colors.green, Icons.check),
                  secondaryBackground: _swipeBg(Colors.red, Icons.delete),
                  onDismissed: (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Notification dismissed")),
                    );
                  },
                  child: _glassCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Color(0xFFFFF3C4),
                              child: Icon(
                                Icons.medication,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Medication Reminder",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Take your morning medication",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const Text("09:00 AM"),
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: [
                            _statusDot(Colors.orange),
                            const SizedBox(width: 6),
                            _chip("Pending", Colors.orange),
                            const Spacer(),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  medicationTaken = true;
                                });
                              },
                              child: Text(
                                medicationTaken ? "Taken" : "Mark as Taken",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// 🏋️ EXERCISE (UPDATED)
                _glassCard(
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          CircleAvatar(
                            backgroundColor: Color(0xFFE6D8FF),
                            child: Icon(Icons.fitness_center),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Exercise Session",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Knee Flexion — Passive Mode",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text("09:00 AM"),
                        ],
                      ),

                      const Divider(),

                      /// ✅ FIXED LAYOUT
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// LEFT SIDE
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.access_time, size: 16),
                                  SizedBox(width: 5),
                                  Text("15 min | Due Today"),
                                ],
                              ),
                              const SizedBox(height: 6),

                              /// 👇 PASSIVE MODE
                              Row(
                                children: [
                                  _statusDot(Color.fromARGB(255, 28, 230, 71)),
                                  const SizedBox(width: 6),
                                  _chip(
                                    "Passive",
                                    const Color.fromARGB(255, 28, 230, 71),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const Spacer(),

                          /// BUTTON
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              "Start Now",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// UPCOMING
                const Text(
                  "UPCOMING",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                _glassCard(
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFFDCE8FF),
                        child: Icon(Icons.directions_walk),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Activity Reminder",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Walk for 20 minutes",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          const Text("15 min"),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _statusDot(Colors.orange),
                              const SizedBox(width: 4),
                              _chip("Upcoming", Colors.orange),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// COMPLETED
                const Text(
                  "COMPLETED",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                _glassCard(
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFFFFF3C4),
                        child: Icon(Icons.medication),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Medication Reminder",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Take your morning medication",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          const Text("09:00 AM"),
                          Row(
                            children: [
                              _statusDot(Colors.green),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.check,
                                color: Colors.green,
                                size: 18,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        /// NAV BAR
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chats"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
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
