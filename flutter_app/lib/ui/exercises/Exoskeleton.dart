import 'package:flutter/material.dart';

class Exoskeleton extends StatefulWidget {
  final String patientName;
  final String exerciseTitle;
  final int? initialMinDegree;
  final int? initialMaxDegree;

  const Exoskeleton({
    Key? key,
    this.patientName = 'Selected Patient',
    this.exerciseTitle = 'Passive Exercise Monitoring',
    this.initialMinDegree,
    this.initialMaxDegree,
  }) : super(key: key);

  @override
  State<Exoskeleton> createState() => _ExoskeletonState();
}

class _ExoskeletonState extends State<Exoskeleton> {
  int? _minDegree;
  int? _maxDegree;
  int _currentReps = 8;
  int _targetReps = 15;
  String _elapsedTime = '03:24';
  double _progress = 0.53;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _minDegree = widget.initialMinDegree;
    _maxDegree = widget.initialMaxDegree;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Feed
              const Text(
                'Live Feed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[200],
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.asset(
                  'assets/images/Exercise.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.videocam,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Exercise: ${widget.exerciseTitle}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Set Min/Max Value with input
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDegreeInput(
                    label: 'Set Min Value',
                    value: _minDegree,
                    onTapManual: () => _showDegreeInputDialog(isMin: true),
                    onIncrement: () => _adjustDegree(isMin: true, delta: 1),
                    onDecrement: () => _adjustDegree(isMin: true, delta: -1),
                  ),
                  const SizedBox(width: 60),
                  _buildDegreeInput(
                    label: 'Set Max Value',
                    value: _maxDegree,
                    onTapManual: () => _showDegreeInputDialog(isMin: false),
                    onIncrement: () => _adjustDegree(isMin: false, delta: 1),
                    onDecrement: () => _adjustDegree(isMin: false, delta: -1),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Metrics Section
              _buildMetricsSection(),
              const SizedBox(height: 24),

              // Current Angle Display
              _buildCurrentAngleDisplay(),
              const SizedBox(height: 24),

              // Control Buttons
              _buildControlButtons(),
              const SizedBox(height: 16),
            ],
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
        'Assist Patient',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildMetricsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            label: 'Reps',
            value: '$_currentReps / $_targetReps',
            icon: Icons.repeat,
            color: const Color.fromRGBO(128, 155, 206, 1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            label: 'Time',
            value: _elapsedTime,
            icon: Icons.timer_outlined,
            color: const Color.fromRGBO(128, 155, 206, 1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            label: 'Progress',
            value: '${(_progress * 100).toInt()}%',
            icon: Icons.trending_up,
            color: const Color.fromRGBO(128, 155, 206, 1),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentAngleDisplay() {
    int? currentAngle;
    bool isExample = false;

    if (_minDegree == null || _maxDegree == null) {
      currentAngle = 45; // Example value
      isExample = true;
    } else {
      currentAngle = ((_minDegree! + _maxDegree!) / 2).round();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF95B8D1).withValues(alpha: 0.5),
            const Color(0xFF95B8D1).withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF95B8D1).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Angle',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '$currentAngle°',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: isExample ? FontWeight.w500 : FontWeight.bold,
                  color: isExample
                      ? const Color.fromRGBO(128, 155, 206, 1)
                      : const Color(0xFF95B8D1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(
                isExample
                    ? const Color.fromRGBO(128, 155, 206, 1)
                        .withValues(alpha: 0.6)
                    : const Color(0xFF95B8D1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDegreeInput({
    required String label,
    required int? value,
    required VoidCallback onTapManual,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    // Show example values: 0° for min, 90° for max
    final exampleValue = label.contains('Min') ? '0' : '90';
    final displayText = value == null ? '$exampleValue°' : '$value°';
    final isExample = value == null;

    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTapManual,
          child: Container(
            width: 110,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF95B8D1),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              displayText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: isExample ? FontWeight.w500 : FontWeight.bold,
                color: isExample
                    ? Colors.grey[400]!.withValues(alpha: 0.5)
                    : const Color(0xFF95B8D1),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAdjustButton(icon: Icons.remove, onPressed: onDecrement),
            const SizedBox(width: 8),
            _buildAdjustButton(icon: Icons.add, onPressed: onIncrement),
          ],
        ),
      ],
    );
  }

  Widget _buildAdjustButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 38,
      height: 38,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: Color(0xFF95B8D1)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF95B8D1)),
      ),
    );
  }

  void _adjustDegree({required bool isMin, required int delta}) {
    final current = (isMin ? _minDegree : _maxDegree) ?? (isMin ? 0 : 90);
    final next = (current + delta).clamp(0, 180);
    _setDegree(isMin: isMin, value: next);
  }

  void _setDegree({required bool isMin, required int value}) {
    final minCandidate = isMin ? value : (_minDegree ?? 0);
    final maxCandidate = isMin ? (_maxDegree ?? 180) : value;

    if (minCandidate > maxCandidate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isMin
                ? 'Minimum degree cannot be greater than maximum degree.'
                : 'Maximum degree cannot be less than minimum degree.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      if (isMin) {
        _minDegree = value;
      } else {
        _maxDegree = value;
      }
    });
  }

  void _showDegreeInputDialog({required bool isMin}) {
    final TextEditingController controller = TextEditingController();
    final currentValue = isMin ? _minDegree : _maxDegree;
    if (currentValue != null) {
      controller.text = currentValue.toString();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isMin ? 'Set Minimum Degree' : 'Set Maximum Degree',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Degree (0-180)',
              suffixText: '°',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: const Color.fromRGBO(128, 155, 206, 1),
                  width: 2,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value != null && value >= 0 && value <= 180) {
                  _setDegree(isMin: isMin, value: value);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid degree (0-180)'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF95B8D1),
              ),
              child: const Text(
                'Set',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlButtons() {
    return Column(
      children: [
        Row(
          children: [
            // Emergency Stop Button
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _showEmergencyStopDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Emergency Stop',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Pause/Resume Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isPaused = !_isPaused;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(128, 155, 206, 1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  _isPaused ? Icons.play_arrow : Icons.pause,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  _isPaused ? 'Resume' : 'Pause',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // End Session Button
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _showEndSessionDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8EFF5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'End Session',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showEmergencyStopDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red[400], size: 28),
              const SizedBox(width: 8),
              const Text(
                'Emergency Stop',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: const Text(
            'Emergency stop activated. The exoskeleton will stop immediately.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Exoskeleton stopped safely'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
              ),
              child: const Text(
                'Acknowledge',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEndSessionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'End Session',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to end this exoskeleton session?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Session ended successfully'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF95B8D1),
              ),
              child: const Text(
                'End Session',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF95B8D1),
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
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
