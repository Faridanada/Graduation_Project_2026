import 'package:flutter/material.dart';
import 'dart:math';
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
  bool _hasUnsavedChanges = false;

  Future<bool> _confirmDiscard() async {
    if (!_hasUnsavedChanges) return true;
    final bool? discard = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text("Your changes haven't been saved. Are you sure you want to discard them?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep editing'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Discard'),
            ),
          ],
        );
      },
    );
    return discard ?? false;
  }

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
        _phases.addAll(List<Map<String, dynamic>>.from(plan['phases'].map((e) {
          final p = Map<String, dynamic>.from(e);
          if (p['exercises'] == null) {
            // Migration for old plans
            p['exercises'] = [{
              'exerciseType': p['exerciseType'] ?? 'Active',
              'minAngle': p['minAngle'] ?? 0,
              'maxAngle': p['maxAngle'] ?? 90,
              'numberOfExercises': p['numberOfExercises'] ?? 3,
              'numberOfReps': p['numberOfReps'] ?? 10,
              'stabilizationDays': p['stabilizationDays'],
            }];
          } else {
             p['exercises'] = List<Map<String, dynamic>>.from(p['exercises'].map((ex) => Map<String, dynamic>.from(ex)));
          }
          return p;
        })));
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
    _hasUnsavedChanges = true;
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
      _hasUnsavedChanges = true;
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _selectPhaseDateRange(int index) async {
    DateTimeRange? initialRange;
    if (_phases[index]['startDate'] != null && _phases[index]['endDate'] != null) {
      final s = DateTime.tryParse(_phases[index]['startDate']);
      final e = DateTime.tryParse(_phases[index]['endDate']);
      if (s != null && e != null) initialRange = DateTimeRange(start: s, end: e);
    } else if (index > 0 && _phases[index - 1]['endDate'] != null) {
      final prevEnd = DateTime.tryParse(_phases[index - 1]['endDate']);
      if (prevEnd != null) {
        final nextStart = prevEnd.add(const Duration(days: 1));
        initialRange = DateTimeRange(start: nextStart, end: nextStart.add(const Duration(days: 7)));
      }
    }

    if (initialRange != null && _startDate != null && _endDate != null) {
      DateTime start = initialRange.start;
      DateTime end = initialRange.end;
      if (start.isBefore(_startDate!)) start = _startDate!;
      if (start.isAfter(_endDate!)) start = _endDate!;
      if (end.isAfter(_endDate!)) end = _endDate!;
      if (end.isBefore(start)) end = start;
      initialRange = DateTimeRange(start: start, end: end);
    }

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      lastDate: _endDate ?? DateTime.now().add(const Duration(days: 365)),
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
      _hasUnsavedChanges = true;
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
    _hasUnsavedChanges = true;
    setState(() {
      _phases.add({
        'subtitle': '',
        'status': 'Upcoming',
        'date': 'TBD',
        'active': false,
        'completed': false,
        'exercises': [
          {
            'id': 'ex_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(999999)}',
            'exerciseType': 'Active',
            'minAngle': 0,
            'maxAngle': 90,
            'numberOfExercises': 3,
            'numberOfReps': 10,
            'stabilizationDays': null,
            'scheduledDays': [1, 2, 3, 4, 5, 6, 7],
          }
        ],
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
      final subtitle = (p['subtitle'] ?? '').trim();
      final date = p['date'] ?? 'TBD';

      if (date == 'TBD' || date.isEmpty || date == 'Select Dates') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select dates for Phase ${i + 1}.')),
        );
        return;
      }

      int phaseDays = 0;
      if (p['startDate'] != null && p['endDate'] != null) {
        final start = DateTime.tryParse(p['startDate']);
        final end = DateTime.tryParse(p['endDate']);
        if (start != null && end != null) {
          phaseDays = end.difference(start).inDays + 1;

          if (start.isBefore(_startDate!) || end.isAfter(_endDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Phase ${i + 1} dates (${DateFormat('MMM dd').format(start)} - ${DateFormat('MMM dd').format(end)}) must be within the overall plan range (${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd').format(_endDate!)}).'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
      }

      int totalStabDays = 0;
      final exercises = p['exercises'] as List<dynamic>? ?? [];
      for (int eIdx = 0; eIdx < exercises.length; eIdx++) {
        var ex = exercises[eIdx];
        if (ex['exerciseType'] == 'Stabilization') {
          totalStabDays += (ex['stabilizationDays'] as int? ?? 0);
          final hold = ex['holdAngle'] as int?;
          if (hold == null || hold < 0 || hold > 135) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Hold angle for Phase ${i + 1} Exercise ${eIdx + 1} must be between 0° and 135°.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
      }

      if (phaseDays > 0 && totalStabDays > phaseDays) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Phase ${i + 1} has $totalStabDays stabilization days, but the phase is only $phaseDays days long!'),
            backgroundColor: Colors.red,
          ),
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
          'active': e.value['active'],
          'completed': e.value['completed'],
          'startDate': e.value['startDate'],
          'endDate': e.value['endDate'],
          'subtitle': (e.value['subtitle'] == null || e.value['subtitle'].toString().isEmpty) ? null : e.value['subtitle'],
          'date': (e.value['date'] == null || e.value['date'].toString().isEmpty) ? null : e.value['date'],
          'status': e.value['status'] ?? 'Upcoming',
          'exercises': e.value['exercises'],
        };
      }).toList(),
      'todayTip': _tipController.text.isEmpty ? null : _tipController.text,
    };

    try {
      final success = await ApiService.createRecoveryPlan(planData);
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          _hasUnsavedChanges = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recovery plan created successfully!')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 8)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final bool shouldPop = await _confirmDiscard();
        if (shouldPop && context.mounted) {
          Navigator.pop(context, result);
        }
      },
      child: Scaffold(
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
                  const SizedBox(height: 16),
                  _buildCard(
                    title: "Phases",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = 0; i < _phases.length; i++)
                          _buildPhaseEditor(i),
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
                            onChanged: (_) {
                              if (!_hasUnsavedChanges) setState(() => _hasUnsavedChanges = true);
                            },
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
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () async {
                    if (await _confirmDiscard()) {
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade400, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
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
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildPhaseEditor(int i) {
    List<dynamic> exercises = _phases[i]['exercises'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Phase ${i + 1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () {
                  _hasUnsavedChanges = true;
                  setState(() => _phases.removeAt(i));
                },
              )
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: _phases[i]['subtitle'],
            decoration: const InputDecoration(labelText: 'Subtitle (Optional)', border: OutlineInputBorder()),
            onChanged: (v) => _phases[i]['subtitle'] = v,
          ),
          const SizedBox(height: 12),
          _buildDatePickerBox(
            label: 'Date Range',
            date: (_phases[i]['date'] == null || _phases[i]['date'] == 'TBD' || _phases[i]['date'].isEmpty) ? 'Select Dates' : _phases[i]['date'],
            onTap: () => _selectPhaseDateRange(i),
          ),
          const SizedBox(height: 20),
          
          for (int eIdx = 0; eIdx < exercises.length; eIdx++)
            _buildExerciseEditor(i, eIdx),

          const SizedBox(height: 8),

          Builder(
            builder: (context) {
              int phaseDays = 0;
              if (_phases[i]['startDate'] != null && _phases[i]['endDate'] != null) {
                final start = DateTime.tryParse(_phases[i]['startDate']);
                final end = DateTime.tryParse(_phases[i]['endDate']);
                if (start != null && end != null) phaseDays = end.difference(start).inDays + 1;
              }

              int totalStabDays = 0;
              for (var ex in exercises) {
                if (ex['exerciseType'] == 'Stabilization') {
                  totalStabDays += (ex['stabilizationDays'] as int? ?? 0);
                }
              }

              bool canAddExercise = phaseDays == 0 || totalStabDays < phaseDays;

              return Column(
                children: [
                  if (!canAddExercise)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0, left: 16, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2.0),
                            child: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              "Cannot add more exercises because Stabilization completely fills the phase duration.",
                              style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.normal),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Center(
                    child: TextButton.icon(
                      onPressed: canAddExercise
                          ? () {
                              _hasUnsavedChanges = true;
                              setState(() {
                                if (_phases[i]['exercises'] == null) {
                                  _phases[i]['exercises'] = [];
                                }
                                _phases[i]['exercises'].add({
                                  'id': 'ex_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(999999)}',
                                  'exerciseType': 'Active',
                                  'minAngle': 0,
                                  'maxAngle': 90,
                                  'holdAngle': null,
                                  'numberOfExercises': 3,
                                  'numberOfReps': 10,
                                  'stabilizationDays': null,
                                  'scheduledDays': [1, 2, 3, 4, 5, 6, 7],
                                });
                              });
                            }
                          : null,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Exercise'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseEditor(int phaseIdx, int eIdx) {
    final exercises = _phases[phaseIdx]['exercises'];
    final type = exercises[eIdx]['exerciseType'] ?? 'Active';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Exercise Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              if (exercises.length > 1)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red, size: 20),
                  onPressed: () {
                    _hasUnsavedChanges = true;
                    setState(() => exercises.removeAt(eIdx));
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _showExerciseTypePicker(phaseIdx, eIdx),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      type,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (type == 'Stabilization')
            Column(
              children: [
                TextFormField(
                  initialValue: exercises[eIdx]['stabilizationDays']?.toString() ?? '',
                  decoration: const InputDecoration(labelText: 'Stabilization Days', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    if (!_hasUnsavedChanges) setState(() => _hasUnsavedChanges = true);
                    exercises[eIdx]['stabilizationDays'] = int.tryParse(v) ?? 7;
                  },
                ),
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final holdValue = exercises[eIdx]['holdAngle'];
                    String? errorMsg;
                    if (holdValue == null) {
                      errorMsg = 'Required';
                    } else if (holdValue < 0 || holdValue > 135) {
                      errorMsg = 'Must be 0–135°';
                    }
                    return TextFormField(
                      initialValue: holdValue?.toString() ?? '',
                      decoration: InputDecoration(
                        labelText: 'Hold Angle (°)',
                        border: const OutlineInputBorder(),
                        errorText: errorMsg,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        if (!_hasUnsavedChanges) setState(() => _hasUnsavedChanges = true);
                        exercises[eIdx]['holdAngle'] = int.tryParse(v);
                        (context as Element).markNeedsBuild();
                      },
                    );
                  }
                ),
              ],
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: exercises[eIdx]['numberOfExercises'].toString(),
                        decoration: const InputDecoration(labelText: 'Sets', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          if (!_hasUnsavedChanges) setState(() => _hasUnsavedChanges = true);
                          exercises[eIdx]['numberOfExercises'] = int.tryParse(v) ?? 3;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: exercises[eIdx]['numberOfReps'].toString(),
                        decoration: const InputDecoration(labelText: 'No. of Reps', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          if (!_hasUnsavedChanges) setState(() => _hasUnsavedChanges = true);
                          exercises[eIdx]['numberOfReps'] = int.tryParse(v) ?? 10;
                        },
                      ),
                    ),
                  ],
                ),
                if (type != 'Passive-Monitored') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: exercises[eIdx]['minAngle'].toString(),
                          decoration: const InputDecoration(labelText: 'Min Angle (°)', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                            if (!_hasUnsavedChanges) setState(() => _hasUnsavedChanges = true);
                            exercises[eIdx]['minAngle'] = int.tryParse(v) ?? 0;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: exercises[eIdx]['maxAngle'].toString(),
                          decoration: const InputDecoration(labelText: 'Max Angle (°)', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                            if (!_hasUnsavedChanges) setState(() => _hasUnsavedChanges = true);
                            exercises[eIdx]['maxAngle'] = int.tryParse(v) ?? 90;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                Builder(builder: (context) {
                  List<dynamic> rawDays = exercises[eIdx]['scheduledDays'] as List<dynamic>? ?? [1, 2, 3, 4, 5, 6, 7];
                  List<int> scheduledDays = rawDays.map((e) => int.tryParse(e.toString()) ?? 1).toList();
                  
                  int daysCount = 0;
                  if (_phases[phaseIdx]['startDate'] != null && _phases[phaseIdx]['endDate'] != null) {
                    final start = DateTime.tryParse(_phases[phaseIdx]['startDate']);
                    final end = DateTime.tryParse(_phases[phaseIdx]['endDate']);
                    if (start != null && end != null) {
                      for (DateTime d = start; d.isBefore(end.add(const Duration(days: 1))); d = d.add(const Duration(days: 1))) {
                        if (scheduledDays.contains(d.weekday)) {
                          daysCount++;
                        }
                      }
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Frequency", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      const Text("Which days the patient performs this exercise", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (int d = 1; d <= 7; d++)
                              FilterChip(
                                label: Text(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1]),
                                selected: scheduledDays.contains(d),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      scheduledDays.add(d);
                                      scheduledDays.sort();
                                    } else {
                                      scheduledDays.remove(d);
                                    }
                                    exercises[eIdx]['scheduledDays'] = List<int>.from(scheduledDays);
                                    _hasUnsavedChanges = true;
                                  });
                                },
                                backgroundColor: Colors.transparent,
                                selectedColor: const Color(0xFF6BA5CF).withOpacity(0.2),
                                checkmarkColor: const Color(0xFF6BA5CF),
                                side: BorderSide(
                                  color: scheduledDays.contains(d) ? Colors.transparent : Colors.grey.shade400,
                                ),
                                labelStyle: TextStyle(
                                  color: scheduledDays.contains(d) ? const Color(0xFF6BA5CF) : Colors.grey.shade700,
                                  fontSize: 12,
                                ),
                              ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        daysCount == 0 
                            ? "Appears on 0 days in this phase — patient will never see this exercise."
                            : "Appears on $daysCount days in this phase.",
                        style: TextStyle(
                          fontSize: 12,
                          color: daysCount == 0 ? Colors.red : Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }

  void _showExerciseTypePicker(int phaseIndex, int exerciseIndex) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Select Exercise Type", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTypeTile(
                  phaseIndex, 
                  exerciseIndex,
                  'Stabilization', 
                  'Completely immobile phase designed to allow the area to heal properly without any strain or movement.', 
                  Icons.lock_outline, 
                  Colors.orange
                ),
                const Divider(height: 1, thickness: 0.5),
                _buildTypeTile(
                  phaseIndex, 
                  exerciseIndex,
                  'Passive-Monitored', 
                  'The motor performs the movement, but it is actively monitored via live stream so the angle ranges can be adjusted in real-time.', 
                  Icons.videocam_outlined, 
                  Colors.red
                ),
                const Divider(height: 1, thickness: 0.5),
                _buildTypeTile(
                  phaseIndex, 
                  exerciseIndex,
                  'Passive', 
                  'The exoskeleton motor performs the entire movement according to the preset angles, requiring no effort from the patient.', 
                  Icons.autorenew, 
                  Colors.purple
                ),
                const Divider(height: 1, thickness: 0.5),
                _buildTypeTile(
                  phaseIndex, 
                  exerciseIndex,
                  'Active', 
                  'The patient performs the movement actively using their own strength, with the device tracking their range of motion and repetitions.', 
                  Icons.accessibility_new_outlined, 
                  Colors.green
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeTile(int phaseIndex, int exerciseIndex, String type, String desc, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.3)),
      isThreeLine: true,
      onTap: () {
        _hasUnsavedChanges = true;
        setState(() => _phases[phaseIndex]['exercises'][exerciseIndex]['exerciseType'] = type);
        Navigator.pop(context);
      },
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
