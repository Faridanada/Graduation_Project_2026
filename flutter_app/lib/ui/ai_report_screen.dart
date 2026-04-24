import 'dart:ui';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'NotificationsPage.dart';
import 'SettingsPage.dart';
import 'patientHome.dart';

class AiReportScreen extends StatefulWidget {
  const AiReportScreen({super.key});

  @override
  State<AiReportScreen> createState() => _AiReportScreenState();
}

class _AiReportScreenState extends State<AiReportScreen> {
  bool isLoading = true;
  double progressScore = 0.0;
  String trendMessage = "+ 0% improvement from last week";
  Color trendColor = Colors.grey;
  List<double> weeklyProgress = [0, 0, 0, 0, 0, 0];
  int unreadNotifs = 0;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final stats = await ApiService.getPatientDashboardStats();
      double score = 0.0;

      if (stats['exerciseStats'] != null) {
        int total = stats['exerciseStats']['total'] ?? 0;
        int completed = stats['exerciseStats']['completed'] ?? 0;
        if (total > 0) score = completed / total;
      }

      String tMsg = "";
      Color tCol = Colors.grey;
      if (score > 0.8) {
        tMsg = "+ 5% improvement from last week";
        tCol = Colors.green;
      } else if (score > 0.5) {
        tMsg = "Steady progress maintained";
        tCol = Colors.blue;
      } else {
        tMsg = "Requires more consistent sessions";
        tCol = Colors.orange;
      }

      List<double> wp = [0, 0, 0, 0, 0, 0];
      if (stats['weeklyProgress'] != null) {
        wp = List<double>.from(stats['weeklyProgress'].map((x) => x.toDouble()));
      }
      
      int unread = stats['unreadNotifications'] ?? 0;

      if (mounted) {
        setState(() {
          progressScore = score;
          trendMessage = tMsg;
          trendColor = tCol;
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
                        Navigator.pop(context);
                      },
                    ),
                    const Spacer(),
                    const Text(
                      "My AI Report",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
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
                                MaterialPageRoute(builder: (context) => const NotificationsPage()),
                              ).then((_) => _fetchStats());
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SettingsPage()),
                              );
                            },
                          ),
                        ],
                      ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                const Text(
                  "Last updated: Today at 4:30 PM",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 16),

                /// 🔵 RECOVERY SCORE
                _glassCard(
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
                              isLoading ? "..." : "${(progressScore * 100).toInt()}%",
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Recovery Score",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              trendMessage,
                              style: TextStyle(
                                color: trendColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// 📈 WEEKLY PROGRESS
                _glassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Weekly Progress",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 100,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(painter: _DynamicLinePainter(weeklyProgress)),
                            ),
                            Positioned(
                              right: 0,
                              top: 10,
                              child: Text(
                                isLoading ? "..." : "${(progressScore * 100).toInt()}%",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _getLast6Days().map((day) => Text(day, style: const TextStyle(fontSize: 12))).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// ⚠️ AI ALERTS
                _glassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "AI Alerts",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "No alerts at this time.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// 💡 AI RECOMMENDATIONS
                _glassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "AI Recommendations",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "No recommendations at this time.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔵 BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Sent successfully to your doctor ✅"),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text(
                    "Share with Doctor",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black54,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PatientHomeScreen()));
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

  /// GLASS
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

  /// ALERT
  Widget _alertCard(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4CC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  /// RECOMMENDATION
  Widget _recommendationCard(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE3ECFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
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

/// 📈 LINE CHART
class _DynamicLinePainter extends CustomPainter {
  final List<double> data;
  _DynamicLinePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final line = Paint()
      ..color = Colors.blue.shade200
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dot = Paint()..color = Colors.blue;

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

    canvas.drawPath(path, line);
    for (var p in points) {
      canvas.drawCircle(p, 4, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _DynamicLinePainter oldDelegate) => true;
}
