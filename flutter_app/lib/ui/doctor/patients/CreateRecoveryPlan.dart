import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/ui/app_theme.dart';

class CreateRecoveryPlan extends StatefulWidget {
  final String patientId;
  final String patientName;
  final Map<String, dynamic>? existingPlan;

  const CreateRecoveryPlan({
    Key? key,
    required this.patientId,
    required this.patientName,
    this.existingPlan,
  }) : super(key: key);

  @override
  State<CreateRecoveryPlan> createState() => _CreateRecoveryPlanState();
}

class _CreateRecoveryPlanState extends State<CreateRecoveryPlan> {
  bool _isLoading = false;

  DateTime? _startDate;
  DateTime? _endDate;

  final List<Map<String, dynamic>> _phases = [];

  // Exoskeleton exercise defaults
  int _repsTotal = 15;
  int _estimatedTimeMin = 20;

  final TextEditingController _tipController = TextEditingController();

  final List<String> _autoTips = [
    "Consistency is key!",
    "Listen to your body, don't push through sharp pain.",
    "Small progress is still progress.",
    "Rest and recovery are just as important as the exercises.",
    "Stay hydrated and keep moving!",
    "Celebrate every small victory.",
    "Focus on your form, not just the reps.",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingPlan != null) {
      final plan = widget.existingPlan!;
      try {
        if (plan['startDate'] != null) _startDate = DateTime.tryParse(plan['startDate']);
        if (plan['endDate'] != null) _endDate = DateTime.tryParse(plan['endDate']);
      } catch (_) {}
      
      if (plan['phases'] != null) {
        _phases.addAll(List<Map<String, dynamic>>.from(plan['phases'].map((e) => Map<String, dynamic>.from(e))));
      }
      if (plan['todayTip'] != null) {
        _tipController.text = plan['todayTip'];
      }
      if (plan['exercisePlan'] != null) {
        _repsTotal = plan['exercisePlan']['repsTotal'] ?? 15;
        _estimatedTimeMin = plan['exercisePlan']['estimatedTimeMin'] ?? 20;
      }
    } else {
      _autoTips.shuffle();
      _tipController.text = _autoTips.first;
    }
  }

  void _generateRandomTip() {
    _autoTips.shuffle();
    setState(() {
      _tipController.text = _autoTips.first;
    });
  }

  Future<void> _selectDurationRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6BA5CF), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black87, // Body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _selectPhaseDateRange(int index) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6BA5CF), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black87, // Body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final startStr = DateFormat('MMM dd').format(picked.start);
        final endStr = DateFormat('MMM dd').format(picked.end);
        _phases[index]['date'] = '$startStr - $endStr';
        _phases[index]['startDate'] = picked.start.toIso8601String();
        _phases[index]['endDate'] = picked.end.toIso8601String();
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

  Future<void> _savePlan() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select both start and end dates.')),
      );
      return;
    }

    if (_phases.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one phase.')),
      );
      return;
    }

    for (int i = 0; i < _phases.length; i++) {
      final p = _phases[i];
      final title = (p['title'] ?? '').trim();
      final subtitle = (p['subtitle'] ?? '').trim();
      final date = p['date'] ?? 'TBD';

      if (title.isEmpty || subtitle.isEmpty || date == 'TBD' || date.isEmpty || date == 'Select Dates') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill out all fields (Title, Subtitle, Dates) for Phase ${i + 1}.')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    final planData = {
      if (widget.existingPlan != null && widget.existingPlan!['id'] != null)
        'id': widget.existingPlan!['id'],
      if (widget.existingPlan != null && widget.existingPlan!['createdAt'] != null)
        'createdAt': widget.existingPlan!['createdAt'],
      'patientId': widget.patientId,
      'startDate': DateFormat('yyyy-MM-dd').format(_startDate!),
      'endDate': DateFormat('yyyy-MM-dd').format(_endDate!),
      'overallProgress': widget.existingPlan?['overallProgress'] ?? 0,
      'phases': _phases.asMap().entries.map((e) {
        return {
          'index': e.key + 1,
          'title': e.value['title'],
          'subtitle': e.value['subtitle'],
          'status': e.value['status'],
          'date': e.value['date'],
          'active': e.value['active'],
          'completed': e.value['completed'],
          'startDate': e.value['startDate'],
          'endDate': e.value['endDate'],
        };
      }).toList(),
      'exercisePlan': {
        'title': 'Leg Extensions',
        'mode': 'Active Mode',
        'repsTotal': _repsTotal,
        'estimatedTimeMin': _estimatedTimeMin,
      },
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
                          child: _buildDatePickerBox(
                            label: 'Date Range',
                            date: (_startDate == null || _endDate == null) 
                                ? 'Select Dates' 
                                : '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd').format(_endDate!)}',
                            onTap: _selectDurationRange,
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
                                  child: _buildDatePickerBox(
                                    label: 'Date Range',
                                    date: _phases[i]['date'] == 'TBD' || _phases[i]['date'].isEmpty ? 'Select Dates' : _phases[i]['date'],
                                    onTap: () => _selectPhaseDateRange(i),
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
                    title: "Daily Motivation / Tip",
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tipController,
                            decoration: const InputDecoration(
                              labelText: 'Tip of the day',
                              border: OutlineInputBorder(),
                              hintText: "E.g. Consistency is key!",
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _generateRandomTip,
                          icon: const Icon(Icons.auto_awesome, color: Color(0xFF6BA5CF)),
                          tooltip: 'Auto-generate tip',
                        ),
                      ],
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

  Widget _buildDatePickerBox({
    required String label,
    required String date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey[300]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Color(0xFF6BA5CF),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    date,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
