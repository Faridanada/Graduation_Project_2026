import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';

import 'session_completed_screen.dart';

class RealTimeDataScreen extends StatefulWidget {
  const RealTimeDataScreen({super.key});

  @override
  State<RealTimeDataScreen> createState() => _RealTimeDataScreenState();
}

class _RealTimeDataScreenState extends State<RealTimeDataScreen> {
  bool isPaused = false;

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
                  const Icon(Icons.arrow_back),
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
                  Expanded(child: _heartCard()),
                  const SizedBox(width: 12),
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
                      "12 / 20",
                      Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoCard(
                      Icons.track_changes,
                      "Accuracy",
                      "87%",
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
                      "2 / 10",
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoCard(
                      Icons.speed,
                      "Range of Motion",
                      "78°",
                      Colors.teal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _caloriesCard(),

              const SizedBox(height: 20),

              /// BUTTONS
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chats"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
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
                  isPaused ? Icons.pause : Icons.circle,
                  size: 10,
                  color: isPaused ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 6),
                Text(
                  isPaused ? "SESSION PAUSED" : "LIVE SESSION",
                  style: TextStyle(
                    color: isPaused ? Colors.orange : Colors.green,
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
              Text("05:32", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 16),
          _divider(),
          const SizedBox(width: 16),
          Column(
            children: const [
              Icon(Icons.show_chart, size: 16),
              SizedBox(height: 4),
              Text("09:15 AM", style: TextStyle(fontWeight: FontWeight.bold)),
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
          const Text(
            "Knee Flexion – Active Mode",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: 0.6,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 10),
              const Text("60%"),
            ],
          ),
          const SizedBox(height: 6),
          const Text("Reps 12 / 20"),
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

  Widget _heartCard() {
    return _card(
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.favorite, color: Colors.red),
              SizedBox(width: 6),
              Text("Heart Rate"),
            ],
          ),
          const SizedBox(height: 10),
          CircularPercentIndicator(
            radius: 50,
            lineWidth: 10,
            percent: 0.75,
            animation: true,
            progressColor: Colors.red,
            backgroundColor: Colors.red.shade100,
            center: const Text("98\nBPM", textAlign: TextAlign.center),
          ),
          const SizedBox(height: 10),
          SizedBox(height: 40, child: _heartGraph()),
        ],
      ),
    );
  }

  Widget _heartGraph() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 1),
              FlSpot(1, 2),
              FlSpot(2, 1.5),
              FlSpot(3, 2.5),
              FlSpot(4, 2),
            ],
            isCurved: true,
            color: Colors.red,
            dotData: FlDotData(show: false),
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
            percent: 0.82,
            animation: true,
            progressColor: Colors.green,
            backgroundColor: Colors.green.shade100,
            center: const Text("82%"),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "On Track",
              style: TextStyle(color: Colors.green),
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

  Widget _caloriesCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Calories Burned"),
          const SizedBox(height: 6),
          const Text(
            "45 kcal",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: 0.15,
            color: Colors.orange,
            backgroundColor: Colors.orange.shade100,
            minHeight: 8,
          ),
          const SizedBox(height: 6),
          const Text("Daily Goal: 300 kcal"),
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
