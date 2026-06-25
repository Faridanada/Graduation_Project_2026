import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/services/sensor_data_service.dart';
import 'package:rehabilitation_app/services/webrtc_service.dart';

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
  String? _connectError;

  @override
  void initState() {
    super.initState();
    targetAngle = widget.exercise['holdAngle'] as int? ?? 90; // Default to 90 if not set
    SensorDataService().kneeAngle.addListener(_onKneeAngleChanged);
    _initSocket();
  }

  Future<void> _initSocket() async {
    final sessionId = widget.exercise['sessionId'];
    if (sessionId != null) {
      try {
        await WebRTCService().initConnection(sessionId, isPatient: true, initMedia: false);
      } catch (e) {
        if (mounted) {
          setState(() => _connectError = 'Connection failed: $e');
        }
      }
    }
  }

  void _onKneeAngleChanged() {
    if (mounted) {
      setState(() {
        currentAngle = SensorDataService().kneeAngle.value.round();
        if ((currentAngle - targetAngle).abs() <= 5) {
          isTargetReached = true;
        } else {
          isTargetReached = false;
        }
      });
    }
  }

  @override
  void dispose() {
    SensorDataService().kneeAngle.removeListener(_onKneeAngleChanged);
    SensorDataService().reset();
    WebRTCService().dispose();
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
            ValueListenableBuilder<bool>(
              valueListenable: SensorDataService().hasData,
              builder: (context, hasData, _) {
                if (!hasData) {
                  return Column(
                    children: [
                      const SizedBox(height: 50),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text("Waiting for sensor data...", style: TextStyle(color: Colors.grey, fontSize: 16)),
                      const SizedBox(height: 50),
                    ],
                  );
                }
                return Center(
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
                );
              }
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
            else if (_connectError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      _connectError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
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

            const SizedBox(height: 20),

            ValueListenableBuilder<double>(
              valueListenable: SensorDataService().emg1,
              builder: (context, emgValue, _) {
                if (emgValue > 20) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: const [
                          Icon(Icons.warning, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(child: Text("Muscle activity detected! Keep your leg still.", style: TextStyle(color: Colors.orange))),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildCalibrateButton(),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildEmergencyButton(),
            ),

          ],
        ),
      ),
    );
  }

  /// CALIBRATE BUTTON
  Widget _buildCalibrateButton() {
    return Column(
      children: [
        const Text("Fully extend your leg before tapping Calibrate.", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () async {
            if (widget.exercise['sessionId'] != null) {
              await ApiService.calibrateSession(widget.exercise['sessionId']);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sensors calibrated to 0 degrees.')));
              }
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                "CALIBRATE SENSORS",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// EMERGENCY BUTTON
  Widget _buildEmergencyButton() {
    return GestureDetector(
      onTap: () async {
        if (widget.exercise['sessionId'] != null) {
          await ApiService.sendSessionCommand(widget.exercise['sessionId'], {'type': 'stop', 'reason': 'patient_emergency'});
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Emergency Stop Activated!')));
          Navigator.pop(context);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              "EMERGENCY STOP",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
