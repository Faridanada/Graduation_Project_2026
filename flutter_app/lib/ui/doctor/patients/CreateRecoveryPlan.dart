import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/ui/app_theme.dart';

class CreateRecoveryPlan extends StatefulWidget {
  final String patientId;
  final String patientName;

  const CreateRecoveryPlan({
    Key? key,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  State<CreateRecoveryPlan> createState() => _CreateRecoveryPlanState();
}

class _CreateRecoveryPlanState extends State<CreateRecoveryPlan> {
  bool _isLoading = false;

  DateTime? _startDate;
  DateTime? _endDate;

  final List<Map<String, dynamic>> _phases = [];
  final List<Map<String, dynamic>> _medications = [];
  final List<String> _guidelines = [];

  // Exoskeleton exercise defaults
  int _repsTotal = 15;
  int _estimatedTimeMin = 20;

  final TextEditingController _tipController = TextEditingController();

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _addPhase() {
    setState(() {
      _phases.add({
        'title': 'Phase ${_phases.length + 1}',
        'subtitle': '',
        'status': 'Upcoming',
        'date': 'TBD',
        'active': false,
        'completed': false,
      });
    });
  }

  void _addMedication() {
    setState(() {
      _medications.add({
        'title': '',
        'time': '09:00 AM',
        'taken': false,
      });
    });
  }

  void _addGuideline() {
    setState(() {
      _guidelines.add('');
    });
  }

  Future<void> _savePlan() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select both start and end dates.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final planData = {
      'patientId': widget.patientId,
      'startDate': DateFormat('yyyy-MM-dd').format(_startDate!),
      'endDate': DateFormat('yyyy-MM-dd').format(_endDate!),
      'overallProgress': 0, // Starts at 0
      'phases': _phases.asMap().entries.map((e) {
        return {
          'index': e.key + 1,
          'title': e.value['title'],
          'subtitle': e.value['subtitle'],
          'status': e.value['status'],
          'date': e.value['date'],
          'active': e.value['active'],
          'completed': e.value['completed'],
        };
      }).toList(),
      'exercisePlan': {
        'title': 'Leg Extensions',
        'mode': 'Active Mode',
        'repsTotal': _repsTotal,
        'estimatedTimeMin': _estimatedTimeMin,
      },
      'medications': _medications,
      'guidelines': _guidelines,
      'todayTip': _tipController.text,
    };

    final success = await ApiService.createRecoveryPlan(planData);
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recovery plan created successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to create recovery plan.'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text('Plan for ${widget.patientName}'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCard(
                    title: "Duration",
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, true),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                  labelText: 'Start Date',
                                  border: OutlineInputBorder()),
                              child: Text(_startDate == null
                                  ? 'Select Date'
                                  : DateFormat('MMM dd, yyyy')
                                      .format(_startDate!)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, false),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                  labelText: 'End Date',
                                  border: OutlineInputBorder()),
                              child: Text(_endDate == null
                                  ? 'Select Date'
                                  : DateFormat('MMM dd, yyyy')
                                      .format(_endDate!)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    title: "Exoskeleton Exercise (Leg Extensions)",
                    child: Column(
                      children: [
                        const Text(
                            "The exoskeleton currently supports Leg Extensions.",
                            style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: _repsTotal.toString(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: 'Target Reps',
                                    border: OutlineInputBorder()),
                                onChanged: (val) =>
                                    _repsTotal = int.tryParse(val) ?? 15,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                initialValue: _estimatedTimeMin.toString(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: 'Duration (Min)',
                                    border: OutlineInputBorder()),
                                onChanged: (val) =>
                                    _estimatedTimeMin = int.tryParse(val) ?? 20,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    title: "Phases",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = 0; i < _phases.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    decoration: InputDecoration(
                                        labelText: 'Title',
                                        border: const OutlineInputBorder()),
                                    onChanged: (v) => _phases[i]['title'] = v,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    decoration: InputDecoration(
                                        labelText: 'Subtitle',
                                        border: const OutlineInputBorder()),
                                    onChanged: (v) =>
                                        _phases[i]['subtitle'] = v,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    decoration: InputDecoration(
                                        labelText: 'Date (e.g. Apr 15-30)',
                                        border: const OutlineInputBorder()),
                                    onChanged: (v) => _phases[i]['date'] = v,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle,
                                      color: Colors.red),
                                  onPressed: () =>
                                      setState(() => _phases.removeAt(i)),
                                )
                              ],
                            ),
                          ),
                        _buildOutlinedActionButton(
                          onPressed: _addPhase,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Phase'),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    title: "Medications",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = 0; i < _medications.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    decoration: InputDecoration(
                                        labelText: 'Medication Name',
                                        border: const OutlineInputBorder()),
                                    onChanged: (v) =>
                                        _medications[i]['title'] = v,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    decoration: InputDecoration(
                                        labelText: 'Time (e.g. 09:00 AM)',
                                        border: const OutlineInputBorder()),
                                    onChanged: (v) =>
                                        _medications[i]['time'] = v,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle,
                                      color: Colors.red),
                                  onPressed: () =>
                                      setState(() => _medications.removeAt(i)),
                                )
                              ],
                            ),
                          ),
                        _buildOutlinedActionButton(
                          onPressed: _addMedication,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Medication'),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    title: "Rehab Guidelines",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = 0; i < _guidelines.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                        labelText: 'Guideline ${i + 1}',
                                        border: const OutlineInputBorder()),
                                    onChanged: (v) => _guidelines[i] = v,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle,
                                      color: Colors.red),
                                  onPressed: () =>
                                      setState(() => _guidelines.removeAt(i)),
                                )
                              ],
                            ),
                          ),
                        _buildOutlinedActionButton(
                          onPressed: _addGuideline,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Guideline'),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    title: "Daily Motivation / Tip",
                    child: TextField(
                      controller: _tipController,
                      decoration: const InputDecoration(
                        labelText: 'Tip of the day',
                        border: OutlineInputBorder(),
                        hintText: "E.g. Consistency is key!",
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _savePlan,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              side: const BorderSide(color: AppColors.primary, width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save Plan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF6BA5CF))),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildOutlinedActionButton({
    required VoidCallback onPressed,
    required Icon icon,
    required Text label,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon.icon, color: AppColors.primary),
      label: DefaultTextStyle.merge(
        style: const TextStyle(color: AppColors.primary),
        child: label,
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.2),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
