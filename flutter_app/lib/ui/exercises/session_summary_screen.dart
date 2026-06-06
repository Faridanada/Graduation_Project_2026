import 'package:flutter/material.dart';
import 'package:rehabilitation_app/ui/shared/ai_report_screen.dart';

class SessionSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> exercise;
  const SessionSummaryScreen({super.key, required this.exercise});

  static const Color primaryBlue = Color(0xFF4A90E2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Text(
                    "Session Summary",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.settings),
                ],
              ),

              const SizedBox(height: 20),

              /// TROPHY
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events,
                    color: primaryBlue, size: 40),
              ),

              const SizedBox(height: 12),

              const Text(
                "Great Job!",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue),
              ),

              const SizedBox(height: 6),

              const Text(
                "You completed your active exercise session.",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              /// STATS GRID
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _stat(Icons.access_time, "Total Duration",
                                "${exercise['estimatedTimeMin']?.toString().padLeft(2, '0') ?? '10'}:00", "min")),
                        Expanded(
                            child: _stat(Icons.fitness_center, "Reps Completed",
                                "${exercise['repsTotal'] ?? 12} / ${exercise['repsTotal'] ?? 12}", "100%")),
                        Expanded(
                            child: _stat(Icons.refresh, "Sets Completed",
                                "1 / 1", "100%")),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                            child: _stat(
                                Icons.track_changes, "Accuracy", "88%", "")),
                        Expanded(
                            child: _stat(Icons.favorite, "Average Heart Rate",
                                "128", "bpm",
                                valueColor: Colors.red)),
                        Expanded(
                            child: _stat(
                                Icons.autorenew, "Recovery Score", "86%", "",
                                valueColor: Colors.green)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// MESSAGE
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.green),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Excellent performance!\nConsistency like this leads to faster recovery.",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.medical_services, color: Colors.green, size: 20),
                    )
                  ],
                ),
              ),

              const Spacer(),

              /// BACK TO HOME
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text("Back to Home"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// VIEW REPORT
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AiReportScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryBlue),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, color: primaryBlue),
                      SizedBox(width: 8),
                      Text(
                        "View Detailed Report",
                        style: TextStyle(
                            color: primaryBlue, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ===== STAT ITEM =====
  Widget _stat(IconData icon, String title, String value, String sub,
      {Color? valueColor}) {
    return Column(
      children: [
        Icon(icon, color: primaryBlue, size: 20),
        const SizedBox(height: 6),
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: valueColor ?? Colors.black)),
        if (sub.isNotEmpty)
          Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
