import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/api_service.dart';

class AvailabilityPage extends StatefulWidget {
  const AvailabilityPage({Key? key}) : super(key: key);

  @override
  State<AvailabilityPage> createState() => _AvailabilityPageState();
}

class _AvailabilityPageState extends State<AvailabilityPage> {
  bool _isLoading = true;
  bool _isSaving = false;

  List<dynamic> _availabilityList = [];

  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _fetchAvailability();
  }

  Future<void> _fetchAvailability() async {
    try {
      final data = await ApiService.getMyAvailability();
      setState(() {
        if (data.isNotEmpty) {
          _availabilityList = data;
        } else {
          // Default init if blank
          _availabilityList = _daysOfWeek.map((day) {
            bool isWeekend = (day == 'Saturday' || day == 'Sunday');
            return {
              'day': day,
              'isAvailable': !isWeekend,
              'startTime': !isWeekend ? '09:00 AM' : '',
              'endTime': !isWeekend ? '05:00 PM' : ''
            };
          }).toList();
        }
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load availability: $e')),
        );
      }
    }
  }

  Future<void> _saveAvailability() async {
    setState(() => _isSaving = true);
    final success = await ApiService.setMyAvailability(_availabilityList);
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Schedule updated successfully' : 'Failed to update schedule'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        if (Navigator.canPop(context)) Navigator.pop(context);
      }
    }
  }

  Future<void> _selectTime(int index, bool isStart) async {
    final currentStr = isStart
        ? _availabilityList[index]['startTime']
        : _availabilityList[index]['endTime'];

    TimeOfDay initialTime = const TimeOfDay(hour: 9, minute: 0);
    if (currentStr.toString().isNotEmpty) {
      try {
        // Parse "09:00 AM" roughly
        final parts = currentStr.toString().split(' ');
        final timeParts = parts[0].split(':');
        int h = int.parse(timeParts[0]);
        final int m = int.parse(timeParts[1]);
        if (parts.length > 1 && parts[1] == 'PM' && h != 12) h += 12;
        if (parts.length > 1 && parts[1] == 'AM' && h == 12) h = 0;
        initialTime = TimeOfDay(hour: h, minute: m);
      } catch (_) {}
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null && mounted) {
      final localizations = MaterialLocalizations.of(context);
      final formattedTime = localizations.formatTimeOfDay(picked, alwaysUse24HourFormat: false);
      setState(() {
        if (isStart) {
          _availabilityList[index]['startTime'] = formattedTime;
        } else {
          _availabilityList[index]['endTime'] = formattedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF6BA5CF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () { if (Navigator.canPop(context)) Navigator.pop(context); },
        ),
        title: const Text(
          'Availability & Schedule',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Schedule',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(_availabilityList.length, (index) {
                        return _buildScheduleCard(index);
                      }),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveAvailability,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6BA5CF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white))
                              : const Text(
                                  'Update Schedule',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildScheduleCard(int index) {
    final dayData = _availabilityList[index];
    final String day = dayData['day'];
    final bool isActive = dayData['isAvailable'] == true;
    final String start = dayData['startTime'] ?? '';
    final String end = dayData['endTime'] ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFF6BA5CF) : Colors.grey[300]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                day,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Switch(
                value: isActive,
                activeThumbColor: const Color(0xFF6BA5CF),
                onChanged: (val) {
                  setState(() {
                    _availabilityList[index]['isAvailable'] = val;
                    if (val && start.isEmpty && end.isEmpty) {
                      _availabilityList[index]['startTime'] = '09:00 AM';
                      _availabilityList[index]['endTime'] = '05:00 PM';
                    }
                  });
                },
              ),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(index, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(start.isEmpty ? 'Select' : start),
                        ],
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('to', style: TextStyle(color: Colors.grey)),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(index, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(end.isEmpty ? 'Select' : end),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }
}


