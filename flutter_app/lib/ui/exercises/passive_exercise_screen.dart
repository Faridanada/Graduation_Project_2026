import 'package:flutter/material.dart';

import 'package:rehabilitation_app/ui/exercises/passive_live_session_screen.dart';

class PassiveExerciseScreen extends StatefulWidget {
  final Map<String, dynamic>? exercise;
  const PassiveExerciseScreen({super.key, this.exercise});

  @override
  State<PassiveExerciseScreen> createState() =>
      _PassiveExerciseScreenState();
}

class _PassiveExerciseScreenState
    extends State<PassiveExerciseScreen> {
  static const Color primaryBlue = Color(0xFF4A90E2);

  double rangeValue = 60;
  String speed = "Normal";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text("Start Passive Exercise",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const Text("FLEXIO",
                      style: TextStyle(
                          color: primaryBlue,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              
              const SizedBox(height: 16),

              /// ABOUT
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _card(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.info, color: primaryBlue, size: 24),
                        SizedBox(width: 8),
                        Text("About Passive Mode",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _check("The device will guide your leg movement."),
                    _check("Relax your muscles and let the device work."),
                    _check("Stop if you feel discomfort."),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              /// BUTTON
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PassiveLiveSessionScreen(exercise: widget.exercise),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: primaryBlue, 
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ]
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        "Start Passive Session",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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

  /// UI HELPERS
  BoxDecoration _card() => BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      );

  Widget _check(String text) => Padding(
        padding:
            const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            const Icon(Icons.check,
                color: Colors.green, size: 18),
            const SizedBox(width: 6),
            Expanded(child: Text(text)),
          ],
        ),
      );

  Widget _speed(String label) {
    final selected = speed == label;
    return GestureDetector(
      onTap: () =>
          setState(() => speed = label),
      child: Container(
        margin:
            const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? primaryBlue
              : primaryBlue.withOpacity(0.1),
          borderRadius:
              BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected
                    ? Colors.white
                    : primaryBlue,
                fontSize: 12)),
      ),
    );
  }
}