import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/api_service.dart';

class StabilizationExerciseScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const StabilizationExerciseScreen({super.key, required this.exercise});

  @override
  State<StabilizationExerciseScreen> createState() => _StabilizationExerciseScreenState();
}

class _StabilizationExerciseScreenState extends State<StabilizationExerciseScreen> {
  int targetAngle = 0;
  int currentAngle = 0;
  bool isTargetReached = false;
  Timer? _timer;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    targetAngle = widget.exercise['holdAngle'] as int? ?? 90; // Default to 90 if not set
    _startSimulatedHardware();
  }

  void _startSimulatedHardware() {
    // Simulate receiving data from hardware, incrementing the angle every 200ms
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (currentAngle < targetAngle) {
        setState(() {
          currentAngle++;
        });
      } else {
        // Target reached!
        setState(() {
          isTargetReached = true;
        });
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _completeSession() async {
    setState(() => _isSaving = true);
    final String exId = widget.exercise['id'] ?? '';
    if (exId.isNotEmpty) {
      final plan = await ApiService.getRecoveryPlan();
      if (plan != null && plan['id'] != null) {
        await ApiService.markExerciseComplete(planId: plan['id'], exerciseId: exId, done: true);
      }
    }
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context); // Go back
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.exercise['title'] ?? 'Stabilization Session';

    // Calculate progress (0.0 to 1.0)
    double progress = (currentAngle / targetAngle).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            /// GAUGE OR VISUAL FEEDBACK
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 20,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF4A90E2),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$currentAngle°',
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: isTargetReached ? const Color(0xFF4A90E2) : Colors.black87,
                        ),
                      ),
                      Text(
                        'Target: $targetAngle°',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            /// STATUS MESSAGE
            if (isTargetReached)
              Column(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF4A90E2), size: 80),
                  const SizedBox(height: 16),
                  const Text(
                    "TARGET REACHED!\nSTOP EXERCISE",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: GestureDetector(
                      onTap: _isSaving ? null : _completeSession,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90E2),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4A90E2).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 3),
                                )
                              : const Text(
                                  "Finish Session",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Connecting to Exoskeleton...\nPlease move slowly until you reach the target angle.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
