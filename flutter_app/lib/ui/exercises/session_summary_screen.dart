import 'package:flutter/material.dart';
import 'package:rehabilitation_app/ui/shared/ai_report_screen.dart';
import 'package:rehabilitation_app/services/api_service.dart';

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


              /// SUMMARY STATS
              _card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _stat(
                      Icons.repeat,
                      "Sets",
                      "${exercise['numberOfExercises'] ?? exercise['setsTotal'] ?? 3}",
                      "Total",
                    ),
                    _stat(
                      Icons.fitness_center,
                      "Reps",
                      "${exercise['numberOfReps'] ?? exercise['repsTotal'] ?? 10}",
                      "Per Set",
                    ),
                    _stat(
                      Icons.straighten,
                      "Range",
                      (exercise['minAngle'] != null && exercise['maxAngle'] != null) 
                          ? "${exercise['minAngle']}°-${exercise['maxAngle']}°"
                          : "Not Set",
                      "Target",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

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
            ],
          ),
        ),
      ),
    );
  }

  /// CARD
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
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
