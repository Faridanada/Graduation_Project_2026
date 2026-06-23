import 'package:flutter/material.dart';
import 'dart:async';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/ui/exercises/session_summary_screen.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:rehabilitation_app/services/webrtc_service.dart';

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
  int _secondsElapsed = 0;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    _startTimer();
    _initWebRTC();
  }

  Future<void> _initWebRTC() async {
    await _localRenderer.initialize();
    final webrtc = WebRTCService();
    webrtc.onLocalStream = (stream) {
      if (mounted) {
        setState(() {
          _localRenderer.srcObject = stream;
        });
      }
    };
    
    // We use the exercise ID as the sessionId for WebRTC signaling
    final sessionId = widget.exercise['id']?.toString() ?? 'exercise_session_1';
    await webrtc.initConnection(sessionId, isPatient: true);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused && !isStopped && !isEmergencyStopped && mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _localRenderer.dispose();
    WebRTCService().dispose();
    super.dispose();
  }

  String get _formattedTime {
    final m = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  double get _progress {
    final totalSeconds = (widget.exercise['estimatedTimeMin'] ?? 10) * 60;
    return totalSeconds > 0 ? _secondsElapsed / totalSeconds : 0.0;
  }



  @override
  Widget build(BuildContext context) {
    final int totalReps = widget.exercise['numberOfReps'] ?? widget.exercise['repsTotal'] ?? 30;
    final int totalSets = widget.exercise['numberOfExercises'] ?? widget.exercise['setsTotal'] ?? 3;
    final int currentReps = (_progress * totalReps).toInt();
    final int currentSets = (_progress * totalSets).toInt();
    final int coloredDots = totalReps > 0 ? (currentReps / totalReps * 6).toInt() : 0;

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
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        }
                      },
                      child: const Icon(Icons.arrow_back),
                    ),
                    Text(widget.exercise['title'] ?? "Active Live Session",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Icon(Icons.settings),
                  ],
                ),

                const SizedBox(height: 32),                /// RING
                Stack(
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
                      children: [
                        Text(_formattedTime,
                            style: const TextStyle(
                                fontSize: 36, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("of ${widget.exercise['estimatedTimeMin']?.toString().padLeft(2, '0') ?? '10'}:00",
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
                
                // WebRTC Local Camera Preview
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _localRenderer.srcObject != null 
                        ? RTCVideoView(_localRenderer, mirror: true, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
                        : const Center(child: CircularProgressIndicator(color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 24),

                _buildEmergencyButton(),

                const SizedBox(height: 24),

                /// ===== STATS GRID (UNCHANGED) =====
                Row(
                  children: [
                    Expanded(
                        child: _statCard(
                      icon: Icons.refresh,
                      iconColor: primaryBlue,
                      title: "Reps",
                      value: "$currentReps / $totalReps",
                      bottom: Row(
                        children: List.generate(
                          6,
                          (i) => Container(
                            margin: const EdgeInsets.only(right: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  i < coloredDots ? primaryBlue : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _statCard(
                      icon: Icons.fitness_center,
                      iconColor: primaryBlue,
                      title: "Sets",
                      value: "$currentSets / $totalSets",
                      bottom: LinearProgressIndicator(
                        value: _progress,
                        color: primaryBlue,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    )),
                  ],
                ),



                const SizedBox(height: 48),

                /// MESSAGE
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: primaryBlue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                  text: "Good job! Keep ",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: "going",
                                  style: TextStyle(
                                      color: primaryBlue,
                                      fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: ".\n\nTry to lift a little higher."),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                /// ===== BUTTONS (UPDATED) =====
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
                        onTap: isEmergencyStopped ? null : () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(child: CircularProgressIndicator()),
                          );

                          await ApiService.completeExercise(widget.exercise['id'] ?? '', widget.exercise['repsTotal'] ?? 12);
                          await ApiService.saveSession({
                            "exerciseId": widget.exercise['id'] ?? '',
                            "durationMinutes": widget.exercise['estimatedTimeMin'] ?? 10,
                            "repsCompleted": widget.exercise['repsTotal'] ?? 12,
                            "accuracy": 88,
                            "date": DateTime.now().toIso8601String()
                          });

                          if (context.mounted) {
                            Navigator.pop(context); // close loading dialog
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SessionSummaryScreen(exercise: widget.exercise),
                              ),
                            );
                          }
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
}
