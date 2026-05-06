import 'package:flutter/material.dart';

import 'live_exercise_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ActiveExerciseScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ActiveExerciseScreen extends StatelessWidget {
  const ActiveExerciseScreen({super.key});

  static const Color primaryBlue = Color(0xFF4A90E2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 10),

                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Icon(Icons.arrow_back),
                    Text(
                      "Start Active Exercise",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text("FLEXIO",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryBlue))
                  ],
                ),

                const SizedBox(height: 8),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text("Monitored by Doctor",
                        style: TextStyle(color: Colors.green))
                  ],
                ),

                const SizedBox(height: 20),

                /// HERO
                _card(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Knee Flexion –\nActive Mode",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "You will move your leg on your own with guidance from your doctor.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 4,
                        child: Image.asset("assets/exercise.png"),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// DOCTOR
                _card(
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage("assets/doctor.jpg"),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Doctor Monitoring",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text(
                              "Dr. Sarah Smith is monitoring your session in real time.",
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.graphic_eq,
                                    color: Colors.green, size: 16),
                                SizedBox(width: 4),
                                Text("Live",
                                    style: TextStyle(color: Colors.green))
                              ],
                            )
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ChatScreen()),
                          );
                        },
                        child: const Text("Chat"),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// OVERVIEW
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.fitness_center,
                              color: primaryBlue, size: 18),
                          SizedBox(width: 8),
                          Text("Exercise Overview",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: const [
                          _OverviewItem(
                            icon: Icons.access_time,
                            title: "Duration",
                            value: "10 min",
                          ),
                          _Divider(),
                          _OverviewItem(
                            icon: Icons.sync,
                            title: "Reps",
                            value: "3 sets × 12",
                          ),
                          _Divider(),
                          _OverviewItem(
                            icon: Icons.timer,
                            title: "Rest Between Sets",
                            value: "30 sec",
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// BEFORE START
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.orange, size: 18),
                          SizedBox(width: 8),
                          Text("Before you start",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 10),
                      _CheckItem("Make sure you are on a flat surface"),
                      _CheckItem("Wear comfortable clothes"),
                      _CheckItem("Stop if you feel pain"),
                      _CheckItem("Keep breathing normally"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LiveSessionScreen()),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow),
                        SizedBox(width: 8),
                        Text("Start Active Session",
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

/// OVERVIEW ITEM (FIXED ICON STYLE)
class _OverviewItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _OverviewItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF4A90E2);

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryBlue, size: 18),
          ),
          const SizedBox(height: 6),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// DIVIDER
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.grey.shade300,
    );
  }
}

/// CHECK ITEM
class _CheckItem extends StatelessWidget {
  final String text;

  const _CheckItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

/// SCREENS


class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Chat Screen")),
    );
  }
}