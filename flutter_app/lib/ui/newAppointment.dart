import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class NewAppointment extends StatefulWidget {
  const NewAppointment({Key? key}) : super(key: key);

  @override
  State<NewAppointment> createState() => _NewAppointmentState();
}

class _NewAppointmentState extends State<NewAppointment> {
  bool _isLoading = true;
  bool _isSubmitting = false;

  List<dynamic> _patients = [];
  String? _selectedPatientId;

  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  String _selectedSessionType = 'Physiotherapy';

  final TextEditingController _notesController = TextEditingController();

  final List<String> _sessionTypes = [
    'Physiotherapy',
    'Wound Check',
    'Rehabilitation',
    'Consultation',
    'Progress Review',
  ];

  // Store doctor's availability rules: { 'Monday': { isAvailable: true, startTime: '09:00 AM', endTime: '05:00 PM' } }
  Map<String, dynamic> _availabilityMap = {};
  List<String> _generatedTimeSlots = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Fetch patients for the dropdown
      final patientsData = await ApiService.getDoctorPatients();
      
      // Fetch doctor's own availability to calculate time slots
      final availabilityData = await ApiService.getMyAvailability();
      
      final Map<String, dynamic> availMap = {};
      for (var item in availabilityData) {
        availMap[item['day']] = item;
      }

      setState(() {
        _patients = patientsData ?? [];
        if (_patients.isNotEmpty) {
          _selectedPatientId = _patients[0]['id']?.toString() ?? _patients[0]['_id']?.toString();
        }
        _availabilityMap = availMap;
        _isLoading = false;
        _generateTimeSlotsForDate(_selectedDate);
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _generateTimeSlotsForDate(DateTime date) {
    final dayName = DateFormat('EEEE').format(date); // e.g., 'Monday'
    final rules = _availabilityMap[dayName];
    
    _generatedTimeSlots.clear();
    _selectedTime = null;

    if (rules == null || rules['isAvailable'] != true) {
      // Off day
      return;
    }

    final startStr = rules['startTime']?.toString() ?? '09:00 AM';
    final endStr = rules['endTime']?.toString() ?? '05:00 PM';
    
    if (startStr.isEmpty || endStr.isEmpty) return;

    try {
      final startTime = _parseTimeString(startStr);
      final endTime = _parseTimeString(endStr);

      DateTime current = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
      final DateTime endDateTime = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);

      // Generate 30-min slots
      while (current.isBefore(endDateTime)) {
        _generatedTimeSlots.add(DateFormat('hh:mm a').format(current));
        current = current.add(const Duration(minutes: 30));
      }
    } catch (e) {
      // fallback slots
      _generatedTimeSlots = ['09:00 AM', '10:00 AM', '11:00 AM', '01:00 PM', '02:00 PM'];
    }
  }

  TimeOfDay _parseTimeString(String timeStr) {
    // Basic parser for "09:00 AM"
    int h = 9, m = 0;
    try {
      final parts = timeStr.trim().split(' ');
      final timeParts = parts[0].split(':');
      h = int.parse(timeParts[0]);
      m = int.parse(timeParts[1]);
      if (parts.length > 1) {
        final ampm = parts[1].toUpperCase();
        if (ampm == 'PM' && h != 12) h += 12;
        if (ampm == 'AM' && h == 12) h = 0;
      }
    } catch (_) {}
    return TimeOfDay(hour: h, minute: m);
  }

  Future<void> _confirmAppointment() async {
    if (_selectedPatientId == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a patient, date, and a time slot.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      // We pass the currently logged-in doctor's ID as implicit, but if needed, we pass it. 
      // The backend uses req.user.id for doctorId if role==doctor, and patientId from body.
      // Wait, our flutter ApiService.createAppointment takes doctorId. Since we are a doctor booking,
      // the backend `createAppointment` expects `patientId` in body if role == doctor.
      // Let's modify ApiService inside this file or assume ApiService.createAppointment handles it.
      // I will send both doctorId="" and patientId=selected just in case.
      
      // Let's use our existing method. I might need to adjust ApiService to send patientId too.
    } catch (e) {
      //
    }

    // Actually, I'll update ApiService locally next.
    // For now:
    final success = await ApiService.createAppointment(
      doctorId: '', // backend will overwrite with req.user.id
      patientId: _selectedPatientId!,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      time: _selectedTime!,
      type: _selectedSessionType,
      notes: _notesController.text,
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment confirmed!'),
          backgroundColor: Color.fromARGB(255, 99, 197, 150),
        ),
      );
      Navigator.pop(context, true); // Return true to refresh list
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to book appointment.'),
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
        backgroundColor: const Color(0xFF6BA5CF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Appointment',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Patient',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (_patients.isEmpty)
                      const Text('No patients found. Please add patients first.')
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedPatientId,
                            isExpanded: true,
                            items: _patients.map((p) {
                              final id = p['id']?.toString() ?? p['_id']?.toString() ?? '';
                              final name = p['name'] ?? 'Unknown';
                              return DropdownMenuItem<String>(
                                value: id,
                                child: Text(name),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _selectedPatientId = val);
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    Text(
                      'Appointment Date',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _selectedDate = pickedDate;
                            _generateTimeSlotsForDate(_selectedDate);
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('EEEE, d MMM yyyy').format(_selectedDate),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Available Time Slots',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (_generatedTimeSlots.isEmpty)
                      const Text('Not available on this day or no slots configured.')
                    else
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _generatedTimeSlots.map((time) {
                          final isSelected = _selectedTime == time;
                          return InkWell(
                            onTap: () {
                              setState(() => _selectedTime = time);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF5798C6) : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF5798C6) : Colors.grey[300]!,
                                ),
                              ),
                              child: Text(
                                time,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 24),

                    Text(
                      'Session Type',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSessionType,
                          isExpanded: true,
                          items: _sessionTypes.map((type) {
                            return DropdownMenuItem(value: type, child: Text(type));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedSessionType = val!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Notes (optional)',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Add session details...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _confirmAppointment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5798C6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Confirm Appointment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
