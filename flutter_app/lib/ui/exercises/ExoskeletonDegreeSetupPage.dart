import 'package:flutter/material.dart';
import 'package:rehabilitation_app/ui/exercises/MonitorEx.dart';
import 'package:rehabilitation_app/ui/app_theme.dart';
import 'package:rehabilitation_app/services/webrtc_service.dart';

class ExoskeletonDegreeSetupPage extends StatefulWidget {
  final String patientName;
  final String exerciseTitle;
  final String? sessionChannel;

  const ExoskeletonDegreeSetupPage({
    Key? key,
    required this.patientName,
    this.exerciseTitle = 'Passive Exercise Monitoring',
    this.sessionChannel,
  }) : super(key: key);

  @override
  State<ExoskeletonDegreeSetupPage> createState() =>
      _ExoskeletonDegreeSetupPageState();
}

class _ExoskeletonDegreeSetupPageState
    extends State<ExoskeletonDegreeSetupPage> {
  int? _minDegree;
  int? _maxDegree;
  int? _targetReps;

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
          'Degree Setup',
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
              // 1. Patient Info (Minimal Text)
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
              const SizedBox(height: 16),

              // 3. Clean Degree Inputs
              _buildCleanDegreeRow(
                label: 'Minimum Degree',
                value: _minDegree,
                isMin: true,
                isReps: false,
                onTapManual: () => _showDegreeInputDialog(isMin: true, isReps: false),
                onIncrement: () => _adjustDegree(isMin: true, isReps: false, delta: 1),
                onDecrement: () => _adjustDegree(isMin: true, isReps: false, delta: -1),
              ),
              
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: Color(0xFFEEEEEE)),
              ),

              _buildCleanDegreeRow(
                label: 'Maximum Degree',
                value: _maxDegree,
                isMin: false,
                isReps: false,
                onTapManual: () => _showDegreeInputDialog(isMin: false, isReps: false),
                onIncrement: () => _adjustDegree(isMin: false, isReps: false, delta: 1),
                onDecrement: () => _adjustDegree(isMin: false, isReps: false, delta: -1),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: Color(0xFFEEEEEE)),
              ),

              _buildCleanDegreeRow(
                label: 'Target Repetitions',
                value: _targetReps,
                isMin: false,
                isReps: true,
                onTapManual: () => _showDegreeInputDialog(isMin: false, isReps: true),
                onIncrement: () => _adjustDegree(isMin: false, isReps: true, delta: 1),
                onDecrement: () => _adjustDegree(isMin: false, isReps: true, delta: -1),
              ),

              const Spacer(),

              // 4. Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_minDegree == null || _maxDegree == null || _targetReps == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please set min/max degrees and target reps.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (widget.sessionChannel != null) {
                      WebRTCService().sendCustomSignaling(
                        targetSessionId: widget.sessionChannel!,
                        data: {
                          'webrtc_type': 'angles_set',
                          'min': _minDegree,
                          'max': _maxDegree,
                        },
                      );
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MonitorEx(
                          patientName: widget.patientName,
                          exerciseTitle: widget.exerciseTitle,
                          initialMinDegree: _minDegree,
                          initialMaxDegree: _maxDegree,
                          targetReps: _targetReps,
                          sessionId: widget.sessionChannel,
                        ),
                      ),
                    );
                  },
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
                    'Start Monitoring',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCleanDegreeRow({
    required String label,
    required int? value,
    required bool isMin,
    required bool isReps,
    required VoidCallback onTapManual,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    final exampleValue = isReps ? '10' : (isMin ? '0' : '90');
    final symbol = isReps ? '' : '°';
    final displayText = value == null ? '$exampleValue$symbol' : '$value$symbol';
    final isExample = value == null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              color: Colors.grey[400],
              iconSize: 28,
              onPressed: onDecrement,
            ),
            GestureDetector(
              onTap: onTapManual,
              child: Container(
                width: 70,
                alignment: Alignment.center,
                child: Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: isExample ? FontWeight.w500 : FontWeight.bold,
                    color: isExample ? Colors.grey[400] : AppColors.primary,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle),
              color: AppColors.primary,
              iconSize: 28,
              onPressed: onIncrement,
            ),
          ],
        ),
      ],
    );
  }

  void _adjustDegree({required bool isMin, required bool isReps, required int delta}) {
    if (isReps) {
      final current = _targetReps ?? 10;
      final next = (current + delta).clamp(1, 100);
      setState(() => _targetReps = next);
      return;
    }
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

  void _showDegreeInputDialog({required bool isMin, required bool isReps}) {
    final TextEditingController controller = TextEditingController();
    final currentValue = isReps ? _targetReps : (isMin ? _minDegree : _maxDegree);
    if (currentValue != null) {
      controller.text = currentValue.toString();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isReps ? 'Set Target Reps' : (isMin ? 'Set Minimum Degree' : 'Set Maximum Degree'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: isReps ? 'Reps' : 'Degree (0-180)',
              suffixText: isReps ? '' : '°',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: const BorderSide(
                  color: AppColors.primary,
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
                if (isReps) {
                  if (value != null && value > 0) {
                    setState(() => _targetReps = value);
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter valid reps'), backgroundColor: Colors.red),
                    );
                  }
                } else {
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
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
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
}
