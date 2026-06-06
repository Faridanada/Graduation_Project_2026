import 'package:flutter/material.dart';
import 'package:rehabilitation_app/ui/exercises/MonitorEx.dart';
import 'package:rehabilitation_app/ui/app_theme.dart';

class ExoskeletonDegreeSetupPage extends StatefulWidget {
  final String patientName;
  final String exerciseTitle;

  const ExoskeletonDegreeSetupPage({
    Key? key,
    required this.patientName,
    this.exerciseTitle = 'Passive Exercise Monitoring',
  }) : super(key: key);

  @override
  State<ExoskeletonDegreeSetupPage> createState() =>
      _ExoskeletonDegreeSetupPageState();
}

class _ExoskeletonDegreeSetupPageState
    extends State<ExoskeletonDegreeSetupPage> {
  int? _minDegree;
  int? _maxDegree;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: const Text(
          'Set Exoskeleton Degrees',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ],
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
              const Spacer(flex: 1),
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Set Min and Max Degree',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 32),
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
                        const SizedBox(width: 44),
                        _buildDegreeInput(
                          label: 'Set Max Value',
                          value: _maxDegree,
                          onTapManual: () => _showDegreeInputDialog(isMin: false),
                          onIncrement: () => _adjustDegree(isMin: false, delta: 1),
                          onDecrement: () => _adjustDegree(isMin: false, delta: -1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_minDegree == null || _maxDegree == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please set both min and max degrees.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MonitorEx(
                          patientName: widget.patientName,
                          exerciseTitle: widget.exerciseTitle,
                          initialMinDegree: _minDegree,
                          initialMaxDegree: _maxDegree,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    elevation: 0,
                    side:
                        const BorderSide(color: AppColors.primary, width: 1.2),
                  ),
                  child: const Text(
                    'Continue to Monitor Exercise',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
              ),
            ),
          ],
        ),
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
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(
                color: AppColors.accent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)
              ],
            ),
            child: Text(
              displayText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: isExample ? FontWeight.w500 : FontWeight.bold,
                color: isExample ? Colors.grey[400] : AppColors.accent,
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
          side: const BorderSide(color: AppColors.accent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Icon(icon, size: 18, color: AppColors.accent),
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
