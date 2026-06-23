import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/api_service.dart';
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

  Timer? _timer;
  int _repsCompleted = 0;
  int _repsTotal = 15;

  @override
  void initState() {
    super.initState();
    if (widget.exercise != null) {
      _repsTotal = widget.exercise!['repsTotal'] ?? 15;
    }
    _startSimulation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSimulation() {
    // Simulate reps incrementing every 3 seconds for demo purposes
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!isPaused && !isStopped && !isEmergencyStopped) {
        setState(() {
          if (_repsCompleted < _repsTotal) {
            _repsCompleted++;
          } else {
            timer.cancel();
            _endSession(); // Automatically end when reps are done
          }
        });
      }
    });
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

                /// RING
                Stack(
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
                ),

                const SizedBox(height: 18),

                Text(
                  isEmergencyStopped ? "EMERGENCY STOPPED" : (isStopped ? "Session Stopped" : (isPaused ? "Session Paused" : "Device moving your leg")),
                    style: TextStyle(
                        color: isEmergencyStopped ? Colors.red : (isStopped ? Colors.red : (isPaused ? Colors.orange : primaryBlue)),
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),

                const SizedBox(height: 6),

                Text(
                  isEmergencyStopped ? "Doctor has been alerted." : (isStopped ? "Press Restart to begin again." : (isPaused ? "Take your time." : "Please relax and breathe normally.")),
                    style: const TextStyle(color: Colors.grey)),

                const SizedBox(height: 16),

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
      
      await ApiService.saveSession({
        "exerciseId": exId,
        "durationMinutes": 10,
        "repsCompleted": _repsCompleted,
        "accuracy": 100,
        "date": DateTime.now().toIso8601String()
      });

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
    _showEmergencyDialog();
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