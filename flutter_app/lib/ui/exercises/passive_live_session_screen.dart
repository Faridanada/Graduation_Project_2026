import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/services/sensor_data_service.dart';
import 'package:rehabilitation_app/services/webrtc_service.dart';
import 'package:rehabilitation_app/ui/exercises/session_summary_screen.dart';

class PassiveLiveSessionScreen extends StatefulWidget {
  final Map<String, dynamic>? exercise;
  const PassiveLiveSessionScreen({super.key, this.exercise});

  @override
  State<PassiveLiveSessionScreen> createState() =>
      _PassiveLiveSessionScreenState();
}

class _PassiveLiveSessionScreenState
    extends State<PassiveLiveSessionScreen> {
  static const Color primaryBlue = Color(0xFF4A90E2);

  bool isPaused = false;
  bool isStopped = false;
  bool isEmergencyStopped = false;
  bool isCalibrated = false;
  bool hasStartedMotor = false;

  Timer? _timer;
  Timer? _waitingTimer;
  bool _showWaitingError = false;
  String? _connectError;
  int _repsCompleted = 0;
  int _repsTotal = 15;

  @override
  void initState() {
    super.initState();
    if (widget.exercise != null) {
      _repsTotal = widget.exercise!['repsTotal'] ?? 15;
      _initSocket();
    }
    SensorDataService().repCount.addListener(_onRepCountChanged);

    _waitingTimer = Timer(const Duration(seconds: 10), () {
      if (!SensorDataService().hasData.value && mounted) {
        setState(() {
          _showWaitingError = true;
        });
      }
    });
  }

  Future<void> _initSocket() async {
    final sessionId = widget.exercise!['sessionId'];
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

  void _onRepCountChanged() {
    if (!isPaused && !isStopped && !isEmergencyStopped && mounted) {
      setState(() {
        _repsCompleted = SensorDataService().repCount.value;
        if (_repsCompleted >= _repsTotal && _repsTotal > 0) {
          _repsCompleted = _repsTotal;
          _endSession(); // Automatically end when reps are done
        }
      });
    }
  }

  @override
  void dispose() {
    _waitingTimer?.cancel();
    SensorDataService().repCount.removeListener(_onRepCountChanged);
    SensorDataService().reset();
    WebRTCService().dispose();
    super.dispose();
  }

  double get progress => _repsTotal > 0 ? _repsCompleted / _repsTotal : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 10),

                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text("Passive Live Session",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Icon(Icons.settings),
                  ],
                ),

                const SizedBox(height: 10),

                /// TAGS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _chip("PASSIVE MODE", primaryBlue),
                    _chip("Device Connected", Colors.green,
                        icon: Icons.wifi),
                  ],
                ),

                const SizedBox(height: 20),

                /// WAITING STATE & RING
                ValueListenableBuilder<bool>(
                  valueListenable: SensorDataService().hasData,
                  builder: (context, hasData, _) {
                    if (!hasData) {
                      if (_connectError != null) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 12),
                            Text(_connectError!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        );
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_showWaitingError) const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            _showWaitingError 
                                ? "No sensor data received.\nPlease ensure the hardware simulator is running and you have logged in again." 
                                : "Waiting for sensor data...", 
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _showWaitingError ? Colors.red : Colors.grey, 
                              fontSize: 16,
                              fontWeight: _showWaitingError ? FontWeight.bold : FontWeight.normal
                            )
                          ),
                        ],
                      );
                    }
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 180,
                          width: 180,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 14,
                            strokeCap: StrokeCap.round,
                            color: primaryBlue,
                            backgroundColor: Colors.grey.shade300,
                          ),
                        ),
                        Column(
                          children: [
                            Text("$_repsCompleted",
                                style: const TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("of $_repsTotal Reps",
                                style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 6),
                            Icon(
                              isPaused ? Icons.play_arrow : Icons.pause,
                              size: 18,
                            ),
                          ],
                        )
                      ],
                    );
                  }
                ),

                const SizedBox(height: 18),

                Text(
                  isEmergencyStopped ? "EMERGENCY STOPPED" : (isStopped ? "Session Stopped" : (!hasStartedMotor ? (!isCalibrated ? "Waiting for Calibration" : "Ready to Start") : (isPaused ? "Session Paused" : "Device moving your leg"))),
                    style: TextStyle(
                        color: isEmergencyStopped ? Colors.red : (isStopped ? Colors.red : (!hasStartedMotor ? Colors.orange : (isPaused ? Colors.orange : primaryBlue))),
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),

                const SizedBox(height: 6),

                Text(
                  isEmergencyStopped ? "Doctor has been alerted." : (isStopped ? "Press Restart to begin again." : (!hasStartedMotor ? (!isCalibrated ? "Please fully extend your leg and calibrate." : "Press Start Passive Motion to begin.") : (isPaused ? "Take your time." : "Please relax and breathe normally."))),
                    style: const TextStyle(color: Colors.grey)),

                const SizedBox(height: 16),
                
                ValueListenableBuilder<double>(
                  valueListenable: SensorDataService().emg1,
                  builder: (context, emgValue, _) {
                    if (emgValue > 20) { // Arbitrary threshold for active muscle
                      return Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: const [
                            Icon(Icons.warning, color: Colors.orange),
                            SizedBox(width: 8),
                            Expanded(child: Text("Muscle activity detected! Relax your leg for passive motion.", style: TextStyle(color: Colors.orange))),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }
                ),

                _buildCalibrateButton(),

                const SizedBox(height: 12),

                _buildEmergencyButton(),

                const SizedBox(height: 14),

                /// GRID
                Row(
                  children: [
                    Expanded(
                        child: _progressCard(
                            Icons.show_chart, "Session Progress", progress)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _statCard(
                            Icons.loop, "Reps", "$_repsCompleted / $_repsTotal", "Completed")),
                  ],
                ),

                const SizedBox(height: 14),

                /// BUTTONS
                if (!hasStartedMotor)
                  _button(
                      "Start Passive Motion",
                      Icons.play_circle_fill,
                      isCalibrated ? Colors.green : Colors.grey,
                      () {
                        if (!isCalibrated) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please calibrate sensors first.')));
                          return;
                        }
                        if (widget.exercise != null && widget.exercise!['sessionId'] != null) {
                          ApiService.sendSessionCommand(widget.exercise!['sessionId'], {'type': 'start_motor', 'mode': 'passive'});
                        }
                        setState(() {
                          hasStartedMotor = true;
                          isPaused = false;
                        });
                      })
                else
                  Row(
                    children: [
                      Expanded(
                          child: _button(
                              isPaused ? "Resume" : "Pause", 
                              isPaused ? Icons.play_arrow : Icons.pause, 
                              isPaused ? primaryBlue : primaryBlue, 
                              _togglePause)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _button(
                              "Stop", Icons.stop, Colors.red, _showStopDialog)),
                    ],
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// CHIP
  Widget _chip(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(text,
              style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  /// CARD
  Widget _statCard(
      IconData icon, String title, String value, String sub,
      {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryBlue, size: 18),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Colors.black)),
          Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  /// PROGRESS
  Widget _progressCard(IconData icon, String title, double progress) {
    return _statCard(icon, title, "${(progress * 100).toInt()}%", "",
        valueColor: Colors.black);
  }

  /// BUTTON
  Widget _button(
      String text, IconData icon, Color color, VoidCallback onTap) {
    final disabled = isEmergencyStopped;

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Opacity(
        opacity: disabled ? 0.4 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(text,
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  /// PAUSE (Deprecated)
  void _pause() {
    setState(() => isPaused = true);
  }

  /// END SESSION (API Calls)
  Future<void> _endSession() async {
    setState(() {
      isStopped = true;
      isPaused = false;
    });
    
    if (widget.exercise != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final planId = widget.exercise!['planId'];
      final exId = widget.exercise!['id'] ?? widget.exercise!['_id'] ?? '';
      
      if (planId != null) {
        await ApiService.markExerciseComplete(planId: planId, exerciseId: exId, done: true);
      } else {
        await ApiService.completeExercise(exId, 1);
      }
      
      final summaryData = {
        "exerciseId": exId,
        "durationMinutes": 10,
        "repsCompleted": _repsCompleted,
        "accuracy": 100,
        "date": DateTime.now().toIso8601String()
      };

      if (widget.exercise!['sessionId'] != null) {
        await ApiService.endSession(widget.exercise!['sessionId'], summary: summaryData);
      } else {
        await ApiService.saveSession(summaryData);
      }

      if (mounted) {
        Navigator.pop(context); // close loading
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SessionSummaryScreen(exercise: widget.exercise!),
          ),
        );
      }
    }
  }

  /// EMERGENCY
  void _emergencyStop() {
    setState(() {
      isEmergencyStopped = true;
      isPaused = false;
    });
    if (widget.exercise != null && widget.exercise!['sessionId'] != null) {
      ApiService.sendSessionCommand(widget.exercise!['sessionId'], {'type': 'stop', 'reason': 'patient_emergency'});
    }
    _showEmergencyDialog();
  }

  /// CALIBRATE BUTTON
  Widget _buildCalibrateButton() {
    return Column(
      children: [
        const Text("Fully extend your leg before tapping Calibrate.", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () async {
            if (widget.exercise != null && widget.exercise!['sessionId'] != null) {
              await ApiService.calibrateSession(widget.exercise!['sessionId']);
              if (mounted) {
                setState(() {
                  isCalibrated = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sensors calibrated to 0 degrees.')));
              }
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: primaryBlue,
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

  /// TOGGLE PAUSE
  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  /// STOP DIALOG
  void _showStopDialog() {
    setState(() {
      isPaused = true;
    });
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pause, size: 40, color: primaryBlue),
              const SizedBox(height: 10),
              const Text("Session Paused",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    isStopped = false;
                    isPaused = false;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text("Resume Session",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _endSession(); // End session and navigate to summary
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text("End Session",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// EMERGENCY DIALOG
  void _showEmergencyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.warning, color: Colors.red, size: 36),
              ),
              const SizedBox(height: 14),
              const Text("Emergency Stop Activated",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              const Text(
                "The session has been stopped immediately.\n\nYour doctor has been alerted.\nPlease wait for instructions.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Dismiss dialog
                  Navigator.of(context).popUntil((route) => route.isFirst); // Go back to Home
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text("Understood",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// EMERGENCY BUTTON
  Widget _buildEmergencyButton() {
    return GestureDetector(
      onTap: isEmergencyStopped ? null : _emergencyStop,
      child: Opacity(
        opacity: isEmergencyStopped ? 0.4 : 1.0,
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
      ),
    );
  }

  /// SHARED DIALOG
  Widget _dialog(String title, String buttonText, VoidCallback onTap) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pause, size: 40, color: primaryBlue),
            const SizedBox(height: 10),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            const Text("Take your time."),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(buttonText,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}