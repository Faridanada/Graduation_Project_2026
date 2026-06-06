import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/api_service.dart';

class DoctorAvailabilityPage extends StatefulWidget {
  const DoctorAvailabilityPage({Key? key}) : super(key: key);

  @override
  State<DoctorAvailabilityPage> createState() => _DoctorAvailabilityPageState();
}

class _DoctorAvailabilityPageState extends State<DoctorAvailabilityPage> {
  bool isLoading = true;
  bool isEditing = false;
  bool isSaving = false;
  Map<String, dynamic> userProfile = {};

  final List<Map<String, dynamic>> _defaultSchedule = [
    {'day': 'Monday', 'enabled': false, 'startTime': '09:00 AM', 'endTime': '05:00 PM'},
    {'day': 'Tuesday', 'enabled': false, 'startTime': '09:00 AM', 'endTime': '05:00 PM'},
    {'day': 'Wednesday', 'enabled': false, 'startTime': '09:00 AM', 'endTime': '05:00 PM'},
    {'day': 'Thursday', 'enabled': false, 'startTime': '09:00 AM', 'endTime': '05:00 PM'},
    {'day': 'Friday', 'enabled': false, 'startTime': '09:00 AM', 'endTime': '05:00 PM'},
    {'day': 'Saturday', 'enabled': false, 'startTime': '09:00 AM', 'endTime': '05:00 PM'},
    {'day': 'Sunday', 'enabled': false, 'startTime': '09:00 AM', 'endTime': '05:00 PM'},
  ];

  late List<Map<String, dynamic>> _availabilitySchedule;

  @override
  void initState() {
    super.initState();
    _availabilitySchedule = List.from(_defaultSchedule.map((e) => Map<String, dynamic>.from(e)));
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profile = await ApiService.getUserProfile() ?? {};
      final availabilityData = await ApiService.getMyAvailability();

      if (mounted) {
        setState(() {
          userProfile = profile;

          // Merge fetched data into our 7-day schedule format
          for (var item in availabilityData) {
            if (item is Map) {
              int index = _availabilitySchedule.indexWhere((s) => s['day'] == item['day']);
              if (index != -1) {
                _availabilitySchedule[index] = {
                  'day': item['day'],
                  'enabled': item['enabled'] == true || item['enabled'] == 'true',
                  'startTime': item['startTime'] ?? '09:00 AM',
                  'endTime': item['endTime'] ?? '05:00 PM',
                };
              }
            }
          }
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _saveData() async {
    setState(() => isSaving = true);

    // Save availability (We save the entire array of 7 days)
    final availSuccess = await ApiService.setMyAvailability(_availabilitySchedule);

    setState(() => isSaving = false);
    if (availSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Availability updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() => isEditing = false);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update details'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  TimeOfDay _parseTime(String timeString) {
    try {
      final parts = timeString.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      if (parts.length > 1) {
        if (parts[1].toUpperCase() == 'PM' && hour < 12) hour += 12;
        if (parts[1].toUpperCase() == 'AM' && hour == 12) hour = 0;
      }
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  Future<void> _pickTime(int index, bool isStart) async {
    if (!isEditing) return;

    final currentStr = isStart
        ? _availabilitySchedule[index]['startTime']
        : _availabilitySchedule[index]['endTime'];

    final initialTime = _parseTime(currentStr);

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
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

    if (pickedTime != null && mounted) {
      setState(() {
        if (isStart) {
          _availabilitySchedule[index]['startTime'] = pickedTime.format(context);
        } else {
          _availabilitySchedule[index]['endTime'] = pickedTime.format(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: const Text(
          'Manage Availability',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!isLoading && !isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black87),
              onPressed: () => setState(() => isEditing = true),
            ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF6BA5CF)))
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weekly Schedule',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 7-Day Schedule Builder
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _availabilitySchedule.length,
                        itemBuilder: (context, index) {
                          final slot = _availabilitySchedule[index];
                          final isEnabled = slot['enabled'] == true;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: isEnabled 
                                    ? const Color(0xFF6BA5CF).withOpacity(0.3)
                                    : Colors.transparent,
                                width: 1.5,
                              )
                            ),
                            child: Column(
                              children: [
                                // Day Header
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        slot['day'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isEnabled
                                              ? Colors.black87
                                              : Colors.grey[500],
                                        ),
                                      ),
                                      Switch(
                                        value: isEnabled,
                                        activeColor: const Color(0xFF6BA5CF),
                                        onChanged: isEditing
                                            ? (val) {
                                                setState(() {
                                                  _availabilitySchedule[index]
                                                      ['enabled'] = val;
                                                });
                                              }
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Time Pickers
                                if (isEnabled)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 0, 16, 16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _buildTimePickerBox(
                                            label: 'From',
                                            time: slot['startTime'],
                                            onTap: () => _pickTime(index, true),
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Text(
                                            '-',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildTimePickerBox(
                                            label: 'To',
                                            time: slot['endTime'],
                                            onTap: () => _pickTime(index, false),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 30),
                      if (isEditing)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isSaving ? null : _saveData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6BA5CF),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Save Schedule',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTimePickerBox({
    required String label,
    required String time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isEditing ? Colors.grey[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isEditing ? Colors.grey[300]! : Colors.transparent,
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
                  Icons.access_time,
                  size: 14,
                  color: Color(0xFF6BA5CF),
                ),
                const SizedBox(width: 6),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 14,
                    color: isEditing ? Colors.black87 : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    String? value,
    TextEditingController? controller,
  ) {
    final displayValue = (value == null || value.isEmpty) ? 'Not set' : value;

    if (isEditing && controller != null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF6BA5CF), width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayValue,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
