import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/ui/shared/NotificationsPage.dart';
import 'package:rehabilitation_app/ui/settings/SettingsPage.dart';
import 'package:rehabilitation_app/ui/patient/home/patient_bottom_nav.dart';

class AiReportScreen extends StatefulWidget {
  const AiReportScreen({super.key});

  @override
  State<AiReportScreen> createState() => _AiReportScreenState();
}

class _AiReportScreenState extends State<AiReportScreen> {
  bool isLoading = true;
  int unreadNotifs = 0;
  String aiReportContent = "Waiting for AI model response...";

  @override
  void initState() {
    super.initState();
    // We will fetch real AI data here later
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final stats = await ApiService.getPatientDashboardStats();
      
      int unread = stats['unreadNotifications'] ?? 0;
      
      if (mounted) {
        setState(() {
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
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
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
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const NotificationsPage()),
                                ).then((_) => _fetchStats());
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SettingsPage()),
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

                const SizedBox(height: 16),

                /// AI CONTENT PLACEHOLDER
                _glassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "AI Analysis",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      if (isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        Text(
                          aiReportContent,
                          style: const TextStyle(color: Colors.black87, fontSize: 16, height: 1.5),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

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
        bottomNavigationBar: const PatientBottomNavBar(currentIndex: 0),
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
