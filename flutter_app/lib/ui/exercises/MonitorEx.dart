import 'package:flutter/material.dart';
import 'package:rehabilitation_app/ui/app_theme.dart';
import 'package:rehabilitation_app/services/webrtc_service.dart';
import 'package:rehabilitation_app/ui/doctor/home/DoctorHome.dart';

class MonitorEx extends StatefulWidget {
  final String patientName;
  final String exerciseTitle;
  final int? initialMinDegree;
  final int? initialMaxDegree;
  final int? targetReps;

  const MonitorEx({
    Key? key,
    this.patientName = 'Select Patient',
    this.exerciseTitle = 'None',
    this.initialMinDegree,
    this.initialMaxDegree,
    this.targetReps,
  }) : super(key: key);

  @override
  State<MonitorEx> createState() => _MonitorExState();
}

class _MonitorExState extends State<MonitorEx> with SingleTickerProviderStateMixin {
  bool _isPaused = false;
  bool _isMonitoring = false;
  
  // Real data parameters (reps and accuracy simulation removed per request)
  int _targetReps = 0;
  int _minDegree = 0;
  int _maxDegree = 90;
  int _currentAngle = 0; // In a real scenario, this would update via WebSocket/WebRTC
  
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _minDegree = widget.initialMinDegree ?? 0;
    _maxDegree = widget.initialMaxDegree ?? 90;
    _targetReps = widget.targetReps ?? 0;
    _currentAngle = _minDegree; // Start at min
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
          'Live Monitoring',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
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
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isMonitoring ? Icons.videocam_outlined : Icons.videocam_off_outlined,
                              color: Colors.grey, 
                              size: 48
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _isMonitoring ? 'LIVE FEED' : 'READY TO START',
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

              // Emergency Stop Button (Under Live Feed)
              if (_isMonitoring)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _toggleMonitoring();
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
                  _buildCleanMetric('Target Reps', '$_targetReps', Icons.repeat),
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
