import 'dart:ui';
import 'package:flutter/material.dart';
import 'ai_report_screen.dart';
import 'history_screen.dart';
import 'real_time_data_page.dart';
import 'NotificationsPage.dart';
import 'SettingsPage.dart';
import 'patient_bottom_nav.dart';

import '../services/api_service.dart';

class ImprovementScreen extends StatefulWidget {
  const ImprovementScreen({super.key});

  @override
  State<ImprovementScreen> createState() => _ImprovementScreenState();
}

class _ImprovementScreenState extends State<ImprovementScreen> {
  bool isLoading = true;
  double progressScore = 0.0;
  String latestExerciseTitle = "No History Yet";
  String latestExerciseTime = "";
  List<double> weeklyProgress = [0, 0, 0, 0, 0, 0];
  int unreadNotifs = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final stats = await ApiService.getPatientDashboardStats();
      final exercises = await ApiService.getPatientExercises();

      double score = 0.0;
      if (stats['exerciseStats'] != null) {
        int total = stats['exerciseStats']['total'] ?? 0;
        int completed = stats['exerciseStats']['completed'] ?? 0;
        if (total > 0) {
          score = completed / total;
        }
      }

      String exTitle = "No History Yet";
      String exTime = "";
      if (exercises.isNotEmpty) {
        final latest = exercises[0];
        exTitle = latest['title'] ?? 'Exercise';
        exTime = '${latest['estimatedTimeMin'] ?? 10} min';
      }

      List<double> wp = [0, 0, 0, 0, 0, 0];
      if (stats['weeklyProgress'] != null) {
        wp =
            List<double>.from(stats['weeklyProgress'].map((x) => x.toDouble()));
      }

      int unread = stats['unreadNotifications'] ?? 0;

      if (mounted) {
        setState(() {
          progressScore = score;
          latestExerciseTitle = exTitle;
          latestExerciseTime = exTime;
          weeklyProgress = wp;
          unreadNotifs = unread;
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
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
                      onPressed: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      },
                    ),
                    const Spacer(),
                    const Text(
                      "Progress",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
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
                                  builder: (context) =>
                                      const NotificationsPage()),
                            ).then((_) => _fetchData());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SettingsPage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// 🧠 AI REPORT
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AiReportScreen()),
                    );
                  },
                  child: _glassCard(
                    child: Row(
                      children: [
                        /// CIRCLE
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: progressScore,
                                strokeWidth: 8,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: const AlwaysStoppedAnimation(
                                  Colors.blue,
                                ),
                              ),
                              Text(
                                isLoading
                                    ? "..."
                                    : "${(progressScore * 100).toInt()}%",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        /// TEXT
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "My AI Report",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text("Recovery Score"),
                            ],
                          ),
                        ),

                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// HISTORY
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryScreen(),
                      ),
                    );
                  },
                  child: _glassCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "History",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(latestExerciseTitle,
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(latestExerciseTime,
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// REAL-TIME
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RealTimeDataScreen())),
                  child: _glassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text(
                              "Real-Time Data",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Spacer(),
                            Icon(Icons.chevron_right),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// 📈 WEEKLY SUMMARY (FIXED)
                _glassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Weekly Summary",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 100,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                  painter: _DynamicLinePainter(weeklyProgress)),
                            ),
                            Positioned(
                              right: 0,
                              top: 10,
                              child: Text(
                                isLoading
                                    ? "..."
                                    : "${(progressScore * 100).toInt()}%",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _getLast6Days()
                            .map((day) =>
                                Text(day, style: const TextStyle(fontSize: 12)))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const PatientBottomNavBar(currentIndex: 0),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ),
    );
  }

  List<String> _getLast6Days() {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final d = now.subtract(Duration(days: 5 - i));
      const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
      return days[d.weekday - 1];
    });
  }
}

class _DynamicLinePainter extends CustomPainter {
  final List<double> data;
  _DynamicLinePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final linePaint = Paint()
      ..color = Colors.blue.shade200
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()..color = Colors.blue;

    List<Offset> points = [];
    double stepX = size.width / (data.length - 1);
    for (int i = 0; i < data.length; i++) {
      double padding = size.height * 0.2;
      double h = size.height - (padding * 2);
      double y = (size.height - padding) - (data[i] * h);
      points.add(Offset(stepX * i, y));
    }

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, linePaint);
    for (var p in points) {
      canvas.drawCircle(p, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_DynamicLinePainter oldDelegate) => true;
}
