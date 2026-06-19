import 'package:flutter/material.dart';
import 'dart:async';
import 'package:rehabilitation_app/ui/settings/SettingsPage.dart';
import 'package:rehabilitation_app/ui/shared/NotificationsPage.dart';
import 'package:rehabilitation_app/ui/chats/Chats.dart';
import 'package:rehabilitation_app/ui/doctor/profile/DoctorProfile.dart';
import 'package:rehabilitation_app/ui/doctor/home/DoctorHome.dart';
import 'package:rehabilitation_app/ui/app_theme.dart';

class MonitorEx extends StatefulWidget {
  final String patientName;
  final String exerciseTitle;
  final int? initialMinDegree;
  final int? initialMaxDegree;

  const MonitorEx({
    Key? key,
    this.patientName = 'Select Patient',
    this.exerciseTitle = 'None',
    this.initialMinDegree,
    this.initialMaxDegree,
  }) : super(key: key);

  @override
  State<MonitorEx> createState() => _MonitorExState();
}

class _MonitorExState extends State<MonitorEx>
    with SingleTickerProviderStateMixin {
  bool _isPaused = false;
  bool _isMonitoring = false;
  int _selectedNavIndex = 0;
  int _repsCompleted = 0;
  int _repsTotal = 20;
  double _accuracy = 0.0;
  int _secondsElapsed = 0;
  int _minDegree = 0;
  int _maxDegree = 90;
  Timer? _sessionTimer;
  late AnimationController _pulseController;

  int get _repsRemaining => (_repsTotal - _repsCompleted).clamp(0, _repsTotal);
  int get _currentAngle {
    if (_repsTotal <= 0) return _minDegree;
    final ratio = (_repsCompleted / _repsTotal).clamp(0.0, 1.0);
    return (_minDegree + ((_maxDegree - _minDegree) * ratio)).round();
  }

  double get _angleProgress {
    final span = (_maxDegree - _minDegree).abs();
    if (span == 0) return 1.0;
    return ((_currentAngle - _minDegree).abs() / span).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _minDegree = widget.initialMinDegree ?? 0;
    _maxDegree = widget.initialMaxDegree ?? 90;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleMonitoring() {
    setState(() {
      _isMonitoring = !_isMonitoring;
      if (_isMonitoring) {
        _isPaused = false;
        _startSimulation();
      } else {
        _stopSimulation();
      }
    });
  }

  void _startSimulation() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _secondsElapsed++;
          // Simulated rep increment every 5-8 seconds
          if (_secondsElapsed % 6 == 0 && _repsCompleted < _repsTotal) {
            _repsCompleted++;
            _accuracy = 85.0 +
                (5.0 * (1.0 - (1.0 / _repsCompleted))); // Fluctuating accuracy
          }
        });
      }
    });
  }

  void _stopSimulation() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Patient info strip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primarySoft,
                    child: Text(widget.patientName[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins')),
                        Text(widget.exerciseTitle, style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Poppins')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            
            // Video Feed takes flexible space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildVideoFeed(),
              ),
            ),
            const SizedBox(height: 20),
            
            // Emergency Stop
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildEmergencyStopButton(),
            ),
            const SizedBox(height: 20),
            
            // Metrics in a compact row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildCompactMetrics(),
            ),
            const SizedBox(height: 24),
            
            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSessionControls(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        },
      ),
      title: const Text(
        'Monitor Exercise',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsPage()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVideoFeed() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!_isMonitoring)
            Container(
              color: AppColors.surface,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam_off_outlined, size: 48, color: AppColors.primary.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text('READY TO START', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontFamily: 'Poppins')),
                  ],
                ),
              ),
            ),
          if (_isMonitoring)
            const Center(
              child: Text('LIVE VIDEO FEED', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w600, letterSpacing: 2, fontFamily: 'Poppins')),
            ),
            
          // Top Overlay (Status & Timer)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isMonitoring ? Colors.red : AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      if (_isMonitoring)
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) => Opacity(opacity: _pulseController.value, child: const Icon(Icons.circle, size: 8, color: Colors.white)),
                        )
                      else
                        const Icon(Icons.circle, size: 8, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(_isMonitoring ? 'LIVE' : 'READY', style: TextStyle(color: _isMonitoring ? Colors.white : AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  child: Text(_formatTime(_secondsElapsed), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                ),
              ],
            ),
          ),
          
          // Big Start Button Overlay if not monitoring
          if (!_isMonitoring)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _toggleMonitoring,
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: const Text('START MONITORING', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompactMetrics() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCompactMetricItem(Icons.repeat, 'Reps', '$_repsRemaining', AppColors.primary),
          Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
          _buildCompactMetricItem(Icons.analytics_outlined, 'Accuracy', '${_accuracy.toStringAsFixed(0)}%', AppColors.primary),
          Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
          _buildCompactMetricItem(Icons.rotate_right, 'Angle', '$_currentAngle°', Colors.teal),
        ],
      ),
    );
  }

  Widget _buildCompactMetricItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Poppins')),
          ],
        ),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color, fontFamily: 'Poppins')),
      ],
    );
  }

  Widget _buildEmergencyStopButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          if (_isMonitoring) {
            _toggleMonitoring();
            setState(() {
              _secondsElapsed = 0;
              _repsCompleted = 0;
              _accuracy = 0.0;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Emergency stop activated! Session terminated.'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No active monitoring session to stop.'),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade400,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.report_problem, color: Colors.white, size: 22),
        label: const Text(
          'EMERGENCY STOP',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Poppins'),
        ),
      ),
    );
  }

  Widget _buildSessionControls() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isMonitoring ? () {
              _toggleMonitoring();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session ended successfully')));
            } : null,
            icon: const Icon(Icons.stop_circle_outlined),
            label: const Text('End Session', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isMonitoring ? () {
              setState(() => _isPaused = !_isPaused);
            } : null,
            icon: Icon(_isPaused ? Icons.play_circle_fill : Icons.pause_circle_filled, color: Colors.white),
            label: Text(_isPaused ? 'Resume' : 'Pause', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Poppins')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      currentIndex: _selectedNavIndex,
      onTap: (index) {
        setState(() {
          _selectedNavIndex = index;
        });
        if (index == 0) {
          // Home - Navigate back home or pop
          if (Navigator.canPop(context)) {
            if (Navigator.canPop(context)) Navigator.pop(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DoctorHome()),
            );
          }
        } else if (index == 1) {
          // Chats
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Chats()),
          );
        } else if (index == 2) {
          // Profile
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DoctorProfile()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
