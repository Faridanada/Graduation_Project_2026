import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:rehabilitation_app/ui/exercises/session_completed_screen.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/ui/shared/NotificationsPage.dart';
import 'package:rehabilitation_app/ui/settings/SettingsPage.dart';
import 'package:rehabilitation_app/ui/patient/home/patient_bottom_nav.dart';

class RealTimeDataScreen extends StatefulWidget {
  const RealTimeDataScreen({super.key});

  @override
  State<RealTimeDataScreen> createState() => _RealTimeDataScreenState();
}

class _RealTimeDataScreenState extends State<RealTimeDataScreen> {
  bool isPaused = false;
  bool isLoading = true;

  double recoveryScore = 0.0;

  String exerciseTitle = "No Active Session";
  int repsTotal = 0;
  int repsCompleted = 0;
  int unreadNotifs = 0;

  @override
  void initState() {
    super.initState();
    _fetchSessionData();
  }

  Future<void> _fetchSessionData() async {
    try {
      final stats = await ApiService.getPatientDashboardStats();
      final exercises = await ApiService.getPatientExercises();

      if (mounted) {
        setState(() {
          if (stats['exerciseStats'] != null) {
            int total = stats['exerciseStats']['total'] ?? 0;
            int comp = stats['exerciseStats']['completed'] ?? 0;
            if (total > 0) recoveryScore = comp / total;
          }

          if (exercises.isNotEmpty) {
            final latest = exercises[0];
            exerciseTitle = latest['title'] ?? 'Exercise';
            repsTotal = latest['repsTotal'] ?? 20;
            repsCompleted = latest['repsCompleted'] ?? 0;
          }

          unreadNotifs = stats['unreadNotifications'] ?? 0;
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              const SizedBox(height: 10),

              /// HEADER
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      }
                    },
                    child: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  const Text(
                    "Real-Time Data",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Badge(
                      isLabelVisible: unreadNotifs > 0,
                      label: Text('$unreadNotifs'),
                      child: const Icon(Icons.notifications_outlined),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationsPage()),
                      ).then((_) => _fetchSessionData());
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// STATUS BAR
              _statusBar(),

              const SizedBox(height: 16),

              /// EXERCISE CARD
              _exerciseCard(),

              if (isPaused) _pausedBanner(),

              const SizedBox(height: 12),

              /// MAIN GRID
              Row(
                children: [
                  Expanded(child: _recoveryCard()),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      Icons.fitness_center,
                      "Reps Completed",
                      isLoading ? "..." : "$repsCompleted / $repsTotal",
                      Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoCard(
                      Icons.track_changes,
                      "Accuracy",
                      "--%",
                      Colors.blue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      Icons.sentiment_satisfied,
                      "Pain Level",
                      "-- / 10",
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoCard(
                      Icons.speed,
                      "Range of Motion",
                      "--°",
                      Colors.teal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  "More metrics will be available once sensors are connected.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),

              const SizedBox(height: 20),

              if (!isLoading && repsTotal > 0)
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        isPaused ? "Resume Session" : "Pause Session",
                        isPaused ? Colors.green : Colors.blue,
                        isPaused ? Icons.play_arrow : Icons.pause,
                        () {
                          setState(() => isPaused = !isPaused);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _actionButton(
                        "End Session",
                        Colors.red,
                        Icons.stop,
                        () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SessionCompletedScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const PatientBottomNavBar(currentIndex: 0),
    );
  }

  /// ================= COMPONENTS =================

  Widget _statusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isPaused
                  ? Colors.orange.withValues(alpha: 0.2)
                  : Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  (repsTotal == 0)
                      ? Icons.stop_circle_outlined
                      : (isPaused ? Icons.pause : Icons.circle),
                  size: 10,
                  color: (repsTotal == 0)
                      ? Colors.grey
                      : (isPaused ? Colors.orange : Colors.green),
                ),
                const SizedBox(width: 6),
                Text(
                  (repsTotal == 0)
                      ? "NO ACTIVE SESSION"
                      : (isPaused ? "SESSION PAUSED" : "LIVE SESSION"),
                  style: TextStyle(
                    color: (repsTotal == 0)
                        ? Colors.grey
                        : (isPaused ? Colors.orange : Colors.green),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _divider(),
          const SizedBox(width: 16),
          Column(
            children: const [
              Icon(Icons.timer, size: 16),
              SizedBox(height: 4),
              Text("--:--", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 16),
          _divider(),
          const SizedBox(width: 16),
          Column(
            children: const [
              Icon(Icons.show_chart, size: 16),
              SizedBox(height: 4),
              Text("Started", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 24, color: Colors.grey.shade300);

  Widget _exerciseCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Exercise"),
          const SizedBox(height: 6),
          isLoading
              ? const Text("...")
              : Text(
                  exerciseTitle,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: repsTotal > 0 ? (repsCompleted / repsTotal) : 0,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 10),
              Text(repsTotal > 0
                  ? "${((repsCompleted / repsTotal) * 100).toInt()}%"
                  : "0%"),
            ],
          ),
          const SizedBox(height: 6),
          Text("Reps $repsCompleted / $repsTotal"),
        ],
      ),
    );
  }

  Widget _pausedBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          Icon(Icons.pause, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text("Session is paused.\nTake your time before resuming."),
          ),
        ],
      ),
    );
  }

  Widget _recoveryCard() {
    return _card(
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.health_and_safety, color: Colors.green),
              SizedBox(width: 6),
              Text("Recovery Score"),
            ],
          ),
          const SizedBox(height: 10),
          CircularPercentIndicator(
            radius: 50,
            lineWidth: 10,
            percent: recoveryScore,
            animation: true,
            progressColor: Colors.green,
            backgroundColor: Colors.green.shade100,
            center: Text("${(recoveryScore * 100).toInt()}%"),
          ),
          const SizedBox(height: 8),
          if (repsTotal > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                recoveryScore > 0.7 ? "On Track" : "Needs Practice",
                style: const TextStyle(color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String value, Color color) {
    return _card(
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(title),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    String text,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient:
              LinearGradient(colors: [color.withValues(alpha: 0.7), color]),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
