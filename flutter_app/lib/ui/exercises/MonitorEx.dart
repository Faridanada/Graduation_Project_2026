import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rehabilitation_app/ui/app_theme.dart';
import 'package:rehabilitation_app/services/webrtc_service.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/services/sensor_data_service.dart';
import 'package:rehabilitation_app/ui/doctor/home/DoctorHome.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class MonitorEx extends StatefulWidget {
  final String patientName;
  final String exerciseTitle;
  final int? initialMinDegree;
  final int? initialMaxDegree;
  final int? targetReps;
  final String? sessionId;

  const MonitorEx({
    Key? key,
    this.patientName = 'Select Patient',
    this.exerciseTitle = 'None',
    this.initialMinDegree,
    this.initialMaxDegree,
    this.targetReps,
    this.sessionId,
  }) : super(key: key);

  @override
  State<MonitorEx> createState() => _MonitorExState();
}

class _MonitorExState extends State<MonitorEx> with SingleTickerProviderStateMixin {
  bool _isPaused = false;
  bool _isMonitoring = false;
  bool _patientInSession = false;
  Timer? _pollTimer;
  
  // Real data parameters (reps and accuracy simulation removed per request)
  int _targetReps = 0;
  int _minDegree = 0;
  int _maxDegree = 90;
  int _currentAngle = 0;
  int _currentReps = 0;
  
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _minDegree = widget.initialMinDegree ?? 0;
    _maxDegree = widget.initialMaxDegree ?? 90;
    _targetReps = widget.targetReps ?? 0;
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    SensorDataService().kneeAngle.addListener(_onKneeAngleChanged);
    SensorDataService().repCount.addListener(_onRepCountChanged);
    
    _startPollingForSession();
  }

  void _startPollingForSession() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      // Prototype: fetch the first patient for the doctor to monitor
      final patients = await ApiService.getDoctorPatients();
      if (patients.isEmpty) return;
      final patientId = patients[0]['id']?.toString() ?? patients[0]['_id']?.toString();
      if (patientId == null) return;

      final s = await ApiService.getActivePatientSession(patientId);
      if (s != null && mounted) {
        _pollTimer?.cancel();
        final sessionId = s['sessionId'] as String;
        await WebRTCService().initConnection(sessionId, isPatient: false);
        setState(() => _patientInSession = true);
      }
    });
  }

  void _onKneeAngleChanged() {
    if (mounted && _isMonitoring) {
      setState(() {
        _currentAngle = SensorDataService().kneeAngle.value.round();
      });
    }
  }

  void _onRepCountChanged() {
    if (mounted && _isMonitoring) {
      setState(() {
        _currentReps = SensorDataService().repCount.value;
      });
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pulseController.dispose();
    SensorDataService().kneeAngle.removeListener(_onKneeAngleChanged);
    SensorDataService().repCount.removeListener(_onRepCountChanged);
    SensorDataService().reset();
    WebRTCService().dispose();
    super.dispose();
  }

  void _toggleMonitoring() {
    setState(() {
      _isMonitoring = !_isMonitoring;
      if (_isMonitoring) {
        _isPaused = false;
        // Connect to real-time streams here instead of dumb simulation
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: const Text(
          "Monitor Session",
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: !_patientInSession
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "Patient is not currently in a session.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      _startPollingForSession();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Refresh"),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Clean Patient Info
              const Text(
                'PATIENT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.patientName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.exerciseTitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // 2. Video Feed
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // We ensure the RTCVideoView replaces the placeholder when active
                      Center(
                        child: WebRTCService().isConnected && _isMonitoring
                            ? ValueListenableBuilder<bool>(
                                valueListenable: SensorDataService().hasData,
                                builder: (context, hasData, _) {
                                  if (!hasData) {
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        CircularProgressIndicator(),
                                        SizedBox(height: 16),
                                        Text("Waiting for sensor data...", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                      ],
                                    );
                                  }
                                  // Fallback text since actual video stream builder is typically handled elsewhere or passed in
                                  return const Text("Sensor Data Streaming Active", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold));
                                }
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isMonitoring ? Icons.videocam_outlined : Icons.videocam_off_outlined,
                                    color: Colors.grey, 
                                    size: 48
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _isMonitoring ? 'CONNECTING...' : 'READY TO START',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      
                      // Status Indicator
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isMonitoring ? Colors.red.shade50 : AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isMonitoring ? Colors.red.shade200 : AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              if (_isMonitoring)
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) => Opacity(
                                    opacity: _pulseController.value,
                                    child: const Icon(Icons.circle, size: 8, color: Colors.red),
                                  ),
                                )
                              else
                                const Icon(Icons.circle, size: 8, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                _isMonitoring ? 'LIVE' : 'READY',
                                style: TextStyle(
                                  color: _isMonitoring ? Colors.red : AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12
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

              const SizedBox(height: 16),

              // Calibrate Button
              if (_isMonitoring)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (widget.sessionId != null) {
                        await ApiService.calibrateSession(widget.sessionId!);
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Calibration command sent.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.settings_overscan, color: Colors.white, size: 22),
                    label: const Text(
                      'CALIBRATE SENSORS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // Emergency Stop Button (Under Live Feed)
              if (_isMonitoring)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      _toggleMonitoring();
                      if (widget.sessionId != null) {
                        await ApiService.sendSessionCommand(widget.sessionId!, {'type': 'stop', 'reason': 'doctor_emergency'});
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Emergency stop activated! Session terminated.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => DoctorHome()),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.warning_rounded, color: Colors.white, size: 22),
                    label: const Text(
                      'EMERGENCY STOP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // 3. Clean Metrics Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCleanMetric('Target Reps', '$_currentReps/$_targetReps', Icons.repeat),
                  Container(width: 1, height: 40, color: Colors.grey[200]),
                  _buildCleanMetric('Set Bounds', '$_minDegree°-$_maxDegree°', Icons.settings_ethernet),
                  Container(width: 1, height: 40, color: Colors.grey[200]),
                  _buildCleanMetric('Current Angle', '$_currentAngle°', Icons.rotate_right),
                ],
              ),

              const SizedBox(height: 32),

              // 4. Action Buttons
              if (!_isMonitoring)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _toggleMonitoring,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'START MONITORING',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _isPaused = !_isPaused),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _isPaused ? Colors.green : AppColors.primary,
                          side: BorderSide(color: _isPaused ? Colors.green : AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause, size: 18),
                        label: Text(
                          _isPaused ? 'Resume' : 'Pause',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _toggleMonitoring();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session Ended')));
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => DoctorHome()),
                            (route) => false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.stop, size: 18),
                        label: const Text('End Session', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCleanMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[400], size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
