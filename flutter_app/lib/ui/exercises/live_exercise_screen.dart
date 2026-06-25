import 'package:flutter/material.dart';
import 'dart:async';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/services/sensor_data_service.dart';
import 'package:rehabilitation_app/ui/exercises/session_summary_screen.dart';

class LiveSessionScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;
  const LiveSessionScreen({super.key, required this.exercise});

  @override
  State<LiveSessionScreen> createState() => _LiveSessionScreenState();
}

class _LiveSessionScreenState extends State<LiveSessionScreen> {
  static const Color primaryBlue = Color(0xFF4A90E2);

  bool isPaused = false;
  bool isStopped = false;
  bool isEmergencyStopped = false;
  Timer? _timer;
  
  int _currentRep = 0;
  int _repsPerSet = 10;
  int _currentSet = 1;
  int _totalSets = 3;

  @override
  void initState() {
    super.initState();
    _repsPerSet = widget.exercise['numberOfReps'] ?? widget.exercise['repsTotal'] ?? 10;
    _totalSets = widget.exercise['numberOfExercises'] ?? widget.exercise['setsTotal'] ?? 3;
    SensorDataService().repCount.addListener(_onRepCountChanged);
  }

  void _onRepCountChanged() {
    if (!isPaused && !isStopped && !isEmergencyStopped && mounted) {
      setState(() {
        int newTotalReps = SensorDataService().repCount.value;
        if (newTotalReps > 0) {
          // Calculate current set and rep within set based on total continuous reps
          int completedSets = newTotalReps ~/ _repsPerSet;
          _currentSet = (completedSets < _totalSets) ? completedSets + 1 : _totalSets;
          
          if (_currentSet >= _totalSets && newTotalReps >= _repsPerSet * _totalSets) {
             _currentRep = _repsPerSet; // Max out at final rep
          } else {
             _currentRep = newTotalReps % _repsPerSet;
             if (_currentRep == 0 && newTotalReps > 0) _currentRep = _repsPerSet; // end of a set
          }
        }
      });
    }
  }

  @override
  void dispose() {
    SensorDataService().repCount.removeListener(_onRepCountChanged);
    super.dispose();
  }

  double get _progress {
    final int totalRepsOverall = _repsPerSet * _totalSets;
    final int currentTotalReps = ((_currentSet - 1) * _repsPerSet) + _currentRep;
    return totalRepsOverall > 0 ? currentTotalReps / totalRepsOverall : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final dynamic minAngleRaw = widget.exercise['minAngle'];
    final dynamic maxAngleRaw = widget.exercise['maxAngle'];
    final int? minAngle = minAngleRaw != null ? int.tryParse(minAngleRaw.toString()) : null;
    final int? maxAngle = maxAngleRaw != null ? int.tryParse(maxAngleRaw.toString()) : null;

    final int coloredDots = _repsPerSet > 0 ? ((_currentRep / _repsPerSet) * 6).toInt() : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),

                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        }
                      },
                      child: const Icon(Icons.arrow_back),
                    ),
                    Text(widget.exercise['title'] ?? "Active Live Session",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Icon(Icons.settings),
                  ],
                ),

                const SizedBox(height: 32),

                /// WAITING STATE & DATA
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
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 240,
                          width: 240,
                          child: CircularProgressIndicator(
                            value: _progress,
                            strokeWidth: 18,
                            strokeCap: StrokeCap.round,
                            color: primaryBlue,
                            backgroundColor: Colors.grey.shade300,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("$_currentRep",
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("of $_repsPerSet Reps",
                                style: const TextStyle(color: Colors.grey, fontSize: 16)),
                            const SizedBox(height: 8),
                            Icon(
                              isPaused ? Icons.play_arrow : Icons.pause,
                              size: 24,
                              color: Colors.grey,
                            ),
                          ],
                        )
                      ],
                    );
                  }
                ),

                const SizedBox(height: 48),

                Text(
                  isEmergencyStopped ? "EMERGENCY STOPPED" : (isStopped ? "Session Stopped" : (isPaused ? "Session Paused" : "Proceed with ${widget.exercise['title'] ?? 'the exercise'}")),
                    style: TextStyle(
                        color: isEmergencyStopped ? Colors.red : (isStopped ? Colors.red : (isPaused ? Colors.orange : primaryBlue)),
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),

                const SizedBox(height: 6),

                Text(
                  isEmergencyStopped ? "Doctor has been alerted." : (isStopped ? "Press Restart to begin again." : (isPaused ? "Take your time." : "Follow the guidance and move slowly.")),
                    style: const TextStyle(color: Colors.grey)),

                const SizedBox(height: 24),

                _buildCalibrateButton(),

                const SizedBox(height: 12),

                _buildEmergencyButton(),

                const SizedBox(height: 24),

                /// ===== STATS GRID =====
                Row(
                  children: [
                    Expanded(
                        child: _statCard(
                      icon: Icons.fitness_center,
                      iconColor: primaryBlue,
                      title: "Sets",
                      value: "$_currentSet / $_totalSets",
                      bottom: Row(
                        children: List.generate(
                          6,
                          (i) => Container(
                            margin: const EdgeInsets.only(right: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i < coloredDots ? primaryBlue : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: ValueListenableBuilder<double>(
                          valueListenable: SensorDataService().kneeAngle,
                          builder: (context, angle, _) {
                            return _statCard(
                              icon: Icons.straighten,
                              iconColor: primaryBlue,
                              title: "Live Knee Angle",
                              value: "${angle.toStringAsFixed(1)}°",
                              bottom: LinearProgressIndicator(
                                value: (angle + 90) / 180.0, // rough normalized progress for UI
                                color: primaryBlue,
                                backgroundColor: Colors.grey.shade300,
                              ),
                            );
                          }
                        )
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                /// ===== BUTTONS =====
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: isEmergencyStopped ? null : () {
                          setState(() => isPaused = !isPaused);
                        },
                        child: _button(
                          isPaused ? "Resume" : "Pause",
                          isPaused ? Icons.play_arrow : Icons.pause,
                          isPaused ? Colors.green : primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: isEmergencyStopped ? null : () {
                          _showStopDialog();
                        },
                        child: _button("End Session", Icons.stop, Colors.red),
                      ),
                    ),
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

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    Widget? bottom,
    Color? valueColor,
  }) {
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Colors.black)),
          if (bottom != null) ...[
            const SizedBox(height: 8),
            bottom,
          ]
        ],
      ),
    );
  }

  Widget _button(String text, IconData icon, Color color) {
    final disabled = isEmergencyStopped;
    return Opacity(
      opacity: disabled ? 0.4 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(text,
                style: TextStyle(color: color, fontWeight: FontWeight.w500)),
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

  void _emergencyStop() {
    setState(() {
      isEmergencyStopped = true;
      isPaused = false;
    });
    if (widget.exercise['sessionId'] != null) {
      ApiService.sendSessionCommand(widget.exercise['sessionId'], {'type': 'stop', 'reason': 'patient_emergency'});
    }
    _showEmergencyDialog();
  }

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
                  Navigator.pop(context); // Exit session screen
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

  Future<void> _endSessionAPI() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final planId = widget.exercise['planId'];
    final exId = widget.exercise['id'] ?? widget.exercise['_id'] ?? '';
    final int totalRepsCompleted = ((_currentSet - 1) * _repsPerSet) + _currentRep;
    
    if (planId != null) {
      await ApiService.markExerciseComplete(planId: planId, exerciseId: exId, done: true);
    } else {
      await ApiService.completeExercise(exId, totalRepsCompleted);
    }

    final summaryData = {
      "exerciseId": exId,
      "durationMinutes": widget.exercise['estimatedTimeMin'] ?? 10,
      "repsCompleted": totalRepsCompleted,
      "accuracy": 88,
      "date": DateTime.now().toIso8601String()
    };

    if (widget.exercise['sessionId'] != null) {
      await ApiService.endSession(widget.exercise['sessionId'], summary: summaryData);
    } else {
      await ApiService.saveSession(summaryData);
    }

    if (context.mounted) {
      Navigator.pop(context); // close loading dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SessionSummaryScreen(exercise: widget.exercise),
        ),
      );
    }
  }

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
              const Icon(Icons.warning, size: 40, color: Colors.orange),
              const SizedBox(height: 10),
              const Text("End Session?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              const Text("Are you sure you want to end this exercise early?", textAlign: TextAlign.center),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
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
                  _endSessionAPI(); // End session and navigate to summary
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
}
