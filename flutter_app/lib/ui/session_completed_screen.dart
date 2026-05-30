import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'history_screen.dart'; // <-- make sure this exists
import 'patient_bottom_nav.dart';

class SessionCompletedScreen extends StatelessWidget {
  const SessionCompletedScreen({super.key});

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
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      }
                    },
                  ),
                  const Spacer(),
                  const Text(
                    "Real-Time Data",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const Icon(Icons.notifications_none),
                  const SizedBox(width: 12),
                  const Icon(Icons.settings),
                ],
              ),

              const SizedBox(height: 20),

              /// SUCCESS BANNER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F6ED),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.check, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Session Completed!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text("Great job! Keep up the progress."),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// SESSION SUMMARY (FIXED)
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text(
                          "Session Summary",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.calendar_today, size: 14),
                        SizedBox(width: 6),
                        Text(
                          "Today, 20 May 2025",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// GRID EXACT STRUCTURE
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _miniCard(
                                Icons.timer,
                                "Duration",
                                "18:42",
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _miniCard(
                                Icons.fitness_center,
                                "Total Reps",
                                "20 / 20",
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _miniCard(
                                Icons.favorite,
                                "Avg Heart Rate",
                                "96 BPM",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _miniCard(
                                Icons.local_fire_department,
                                "Calories Burned",
                                "62 kcal",
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _miniCard(
                                Icons.health_and_safety,
                                "Recovery Score",
                                "85%",
                                subtitle: "On Track",
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _miniCard(
                                Icons.track_changes,
                                "Accuracy",
                                "89%",
                                subtitle: "Great Form",
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _miniCard(
                                Icons.sentiment_satisfied,
                                "Pain Level (Avg)",
                                "2 / 10",
                                subtitle: "Low",
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _miniCard(
                                Icons.speed,
                                "Range of Motion (Avg)",
                                "82°",
                                subtitle: "Good",
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// HEART GRAPH (FIXED STYLE)
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Heart Rate Over Time",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(height: 200, child: _chart()),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// ACHIEVEMENTS TITLE (FIXED)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  "Achievements",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 8),

              /// ACHIEVEMENT CARD
              _card(
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.emoji_events, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "New Personal Best!",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text("You completed 20 reps with great form."),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// BUTTONS (FIXED DESIGN)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistoryScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.bar_chart),
                      label: const Text("View History"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                        ),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                        icon: const Icon(Icons.home),
                        label: const Text("Back to Home"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white, // ✅ THIS LINE
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
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

  /// MINI CARD
  Widget _miniCard(
    IconData icon,
    String title,
    String value, {
    String? subtitle,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: color ?? Colors.green),
            ),
          ],
        ],
      ),
    );
  }

  /// CHART (FIXED LIKE FIGMA)
  Widget _chart() {
    return LineChart(
      LineChartData(
        minY: 60,
        maxY: 120,
        gridData: FlGridData(
          show: true,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.shade300, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: 20),
          ),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 65),
              FlSpot(2, 80),
              FlSpot(4, 95),
              FlSpot(6, 85),
              FlSpot(8, 105),
              FlSpot(10, 110),
              FlSpot(12, 95),
              FlSpot(14, 100),
              FlSpot(16, 90),
              FlSpot(18, 98),
            ],
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.withValues(alpha: 0.2),
            ),
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  /// CARD
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
