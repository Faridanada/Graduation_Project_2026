import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class AssignExerciseScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const AssignExerciseScreen({Key? key, required this.patient}) : super(key: key);

  @override
  State<AssignExerciseScreen> createState() => _AssignExerciseScreenState();
}

class _AssignExerciseScreenState extends State<AssignExerciseScreen> {
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  final _repsController = TextEditingController();
  
  bool _isSubmitting = false;

  Future<void> _assignExercise() async {
    final title = _titleController.text.trim();
    final timeStr = _timeController.text.trim();
    final repsStr = _repsController.text.trim();

    if (title.isEmpty || timeStr.isEmpty || repsStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final estimatedTime = int.tryParse(timeStr) ?? 15;
    final reps = int.tryParse(repsStr) ?? 10;
    final patientId = widget.patient['id']?.toString() ?? widget.patient['_id']?.toString() ?? '';

    setState(() => _isSubmitting = true);

    final success = await ApiService.assignExercise(
      patientId: patientId,
      title: title,
      estimatedTimeMin: estimatedTime,
      repsTotal: reps,
      dateAssigned: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exercise assigned successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      if (Navigator.canPop(context)) Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to assign exercise.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF95B8D1),
        title: Text('Assign to ${widget.patient['name']}'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Exercise Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Exercise Title (e.g. Leg Extensions)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _timeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Time (mins)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _repsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Total Reps',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _assignExercise,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF95B8D1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Assign Exercise',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
