import 'package:flutter/material.dart';
import 'dart:async';
import 'SettingsPage.dart';
import 'NotificationsPage.dart';
import 'Chats.dart';
import 'DoctorProfile.dart';
import 'DoctorHome.dart';

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
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live Patient Feed Section
                _buildLivePatientFeed(),
                const SizedBox(height: 24),

                // Emergency stop first
                _buildEmergencyStopButton(),
                const SizedBox(height: 16),

                // Metrics Cards
                _buildMetricsSection(),
                const SizedBox(height: 24),

                // Pause/Resume + End Session controls
                _buildSessionControls(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF95B8D1),
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
              MaterialPageRoute(
                  builder: (context) => const NotificationsPage()),
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

  Widget _buildLivePatientFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live Badge and Timer Row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: _isMonitoring
                    ? const Color.fromARGB(255, 239, 68, 68) // RED when LIVE
                    : const Color.fromARGB(
                        255, 99, 197, 150), // GREEN when READY
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  if (_isMonitoring)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _pulseController.value,
                          child: const Icon(Icons.circle,
                              size: 8, color: Colors.white),
                        );
                      },
                    )
                  else
                    const Icon(Icons.circle, size: 8, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    _isMonitoring ? 'LIVE' : 'READY',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Timer: ${_formatTime(_secondsElapsed)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[900],
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          clipBehavior: Clip.hardEdge,
          child: _isMonitoring
              ? Container(
                  color: Colors.black,
                  child: const Center(
                    child: Text(
                      'LIVE VIDEO FEED',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: Colors.black.withOpacity(0.05)),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + (_pulseController.value * 0.1),
                                child: Opacity(
                                  opacity: 0.5 + (_pulseController.value * 0.5),
                                  child: Icon(
                                    Icons.videocam_off_outlined,
                                    size: 60,
                                    color: Colors.blue[300],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'WAITING FOR SIGNAL',
                            style: TextStyle(
                              color: Colors.blue[300],
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _toggleMonitoring,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 87, 152, 198)
                                      .withOpacity(0.8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24)),
                            ),
                            child: const Text(
                              'START MONITORING',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patient: ${widget.patientName}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Exercise: ${widget.exerciseTitle}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 170,
                child: _buildMetricCard(
                  label: 'Remaining Reps',
                  value: '$_repsRemaining',
                  valueColor: const Color.fromARGB(255, 87, 152, 198),
                  showCircle: true,
                  textColor: Colors.white,
                  progress: _repsTotal > 0 ? _repsCompleted / _repsTotal : 0.0,
                  status: _repsCompleted >= _repsTotal
                      ? 'Goal reached'
                      : 'Remaining',
                  statusColor: _repsCompleted >= _repsTotal
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFF3F51B5),
                  hasWarning: false,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 170,
                child: _buildMetricCard(
                  label: 'Real-time Data',
                  value: '${_accuracy.toStringAsFixed(0)}%',
                  valueColor: const Color.fromARGB(255, 87, 152, 198),
                  showCircle: false,
                  textColor: Colors.black,
                  fontSize: 21,
                  progress: _accuracy / 100,
                  status: _isMonitoring ? 'Live data' : 'Standby',
                  statusColor: _isMonitoring
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFF546E7A),
                  hasWarning: false,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 170,
                child: _buildMetricCard(
                  label: 'Current Angle',
                  value: '$_currentAngle°',
                  valueColor: const Color.fromARGB(255, 99, 197, 150),
                  showCircle: false,
                  textColor: const Color.fromARGB(255, 99, 197, 150),
                  fontSize: 21,
                  progress: _angleProgress,
                  status: 'Reached',
                  statusColor: const Color(0xFF00796B),
                  hasWarning: false,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required Color valueColor,
    bool showCircle = true,
    Color? textColor,
    double fontSize = 17,
    required double progress,
    required String status,
    required Color statusColor,
    required bool hasWarning,
    double statusFontSize = 12,
  }) {
    final displayTextColor = textColor ?? valueColor;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 36,
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: Align(
              alignment: Alignment.centerLeft,
              child: showCircle
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: valueColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: displayTextColor,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    )
                  : Text(
                      value,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: displayTextColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(valueColor),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 30,
            child: Row(
              children: [
                Icon(
                  hasWarning ? Icons.warning : Icons.check_circle,
                  size: 14,
                  color: statusColor,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    status,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: statusFontSize,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          backgroundColor: const Color(0xFFC62828),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.report_problem, color: Colors.white, size: 22),
        label: const Text(
          'EMERGENCY STOP',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _buildSessionControls() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isMonitoring
                ? () {
                    _toggleMonitoring();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Session ended successfully')),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8EFF5),
              disabledBackgroundColor: const Color(0xFFE8EFF5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            icon: const Icon(Icons.stop_circle, color: Colors.black, size: 20),
            label: const Text(
              'End Session',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isMonitoring
                ? () {
                    setState(() {
                      _isPaused = !_isPaused;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            _isPaused ? 'Session paused' : 'Session resumed'),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color.fromARGB(255, 87, 152, 198).withOpacity(0.8),
              disabledBackgroundColor:
                  const Color.fromARGB(255, 87, 152, 198).withOpacity(0.35),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            icon: Icon(
              _isPaused ? Icons.play_circle_filled : Icons.pause_circle_filled,
              color: Colors.white,
              size: 20,
            ),
            label: Text(
              _isPaused ? 'Resume' : 'Pause',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
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
      selectedItemColor: const Color(0xFF95B8D1),
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
