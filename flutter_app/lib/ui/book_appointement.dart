import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'appointment_confirmed_screen.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic>? doctor;

  const BookAppointmentScreen({super.key, this.doctor});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime currentMonth = DateTime.now();
  DateTime selectedDate = DateTime.now();
  String? selectedTime;
  
  bool _isLoadingAvailability = true;
  bool _isSubmitting = false;
  Map<String, dynamic> _availabilityMap = {};
  List<String> _availableSlots = [];

  final ScrollController _timeScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchDoctorAvailability();
  }

  Future<void> _fetchDoctorAvailability() async {
    if (widget.doctor == null) {
      if (mounted) setState(() => _isLoadingAvailability = false);
      return;
    }

    final doctorId = widget.doctor!['id'] ?? widget.doctor!['_id'];
    if (doctorId == null) {
      if (mounted) setState(() => _isLoadingAvailability = false);
      return;
    }

    try {
      final availabilityData = await ApiService.getDoctorAvailability(doctorId.toString());
      final Map<String, dynamic> availMap = {};
      for (var item in availabilityData) {
        availMap[item['day']] = item;
      }

      if (mounted) {
        setState(() {
          _availabilityMap = availMap;
          _isLoadingAvailability = false;
          _generateSlotsForSelectedDate();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingAvailability = false);
    }
  }

  void _generateSlotsForSelectedDate() {
    final dayName = DateFormat('EEEE').format(selectedDate);
    final rules = _availabilityMap[dayName];
    
    setState(() {
      _availableSlots = [];
      selectedTime = null;

      if (rules != null && rules['isAvailable'] == true) {
        final startStr = rules['startTime']?.toString() ?? '09:00 AM';
        final endStr = rules['endTime']?.toString() ?? '05:00 PM';
        
        try {
          final startTime = _parseTimeString(startStr);
          final endTime = _parseTimeString(endStr);

          DateTime current = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, startTime.hour, startTime.minute);
          final DateTime endDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, endTime.hour, endTime.minute);

          // Generate 30-min slots
          while (current.isBefore(endDateTime)) {
            _availableSlots.add(DateFormat('hh:mm a').format(current));
            current = current.add(const Duration(minutes: 30));
          }
        } catch (_) {}
      }
    });
  }

  TimeOfDay _parseTimeString(String timeStr) {
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

  Future<void> _handleConfirm() async {
    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a time slot")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final doctorId = widget.doctor!['id'] ?? widget.doctor!['_id'];
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    final success = await ApiService.createAppointment(
      doctorId: doctorId.toString(),
      date: formattedDate,
      time: selectedTime!,
      type: 'Consultation',
      notes: 'Booked via mobile app',
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AppointmentConfirmedScreen(
              date: DateFormat('EEEE, MMMM d').format(selectedDate),
              time: selectedTime!,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to book appointment. Please try again.")),
        );
      }
    }
  }

  /// 🔹 Generate calendar days
  List<int> getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final weekday = firstDay.weekday % 7;
    final totalDays = DateTime(month.year, month.month + 1, 0).day;

    return [
      ...List.filled(weekday, 0),
      ...List.generate(totalDays, (i) => i + 1),
    ];
  }

  /// 🔹 Glass container
  Widget glassBox(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = getDaysInMonth(currentMonth);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Appointment',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoadingAvailability
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔹 DOCTOR INFO
                    if (widget.doctor != null)
                      glassBox(
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                widget.doctor!['name']?[0] ?? 'D',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.doctor!['name'] ?? 'Doctor',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  widget.doctor!['profileData']?['specialty'] ?? 'Physiotherapist',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    /// 🔹 TIME SLOTS
                    glassBox(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Available times for this date",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          if (_availableSlots.isEmpty)
                            const Text("No slots available for this day", style: TextStyle(color: Colors.grey))
                          else
                            SingleChildScrollView(
                              controller: _timeScroll,
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _availableSlots.map((slot) {
                                  final isSelected = slot == selectedTime;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedTime = slot;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      margin: const EdgeInsets.only(right: 10),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.blue : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        slot,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : Colors.black,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🔹 CALENDAR
                    glassBox(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// HEADER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    "Choose a date",
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed: () {
                                      setState(() {
                                        currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
                                      });
                                    },
                                  ),
                                  Text(DateFormat('MMM yyyy').format(currentMonth)),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: () {
                                      setState(() {
                                        currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          /// WEEK DAYS
                          Row(
                            children: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                                .map((e) => Expanded(
                                      child: Center(
                                        child: Text(
                                          e,
                                          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 12),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),

                          const SizedBox(height: 10),

                          /// GRID
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: days.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 1,
                            ),
                            itemBuilder: (_, i) {
                              final day = days[i];
                              if (day == 0) return const SizedBox();

                              final date = DateTime(currentMonth.year, currentMonth.month, day);
                              final isSelected = day == selectedDate.day && currentMonth.month == selectedDate.month && currentMonth.year == selectedDate.year;
                              final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
                              final dayName = DateFormat('EEEE').format(date);
                              final hasAvailability = _availabilityMap[dayName]?['isAvailable'] == true;

                              return GestureDetector(
                                onTap: isPast
                                    ? null
                                    : () {
                                        setState(() {
                                          selectedDate = date;
                                          _generateSlotsForSelectedDate();
                                        });
                                      },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.blue : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isSelected ? null : Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "$day",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isPast
                                              ? Colors.grey.shade300
                                              : isSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                        ),
                                      ),
                                      if (!isPast && hasAvailability)
                                        Container(
                                          margin: const EdgeInsets.only(top: 2),
                                          height: 4,
                                          width: 4,
                                          decoration: BoxDecoration(
                                            color: isSelected ? Colors.white : Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// 🔹 BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                        onPressed: (_isSubmitting || selectedTime == null) ? null : _handleConfirm,
                        child: _isSubmitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text(
                                "Confirm Appointment",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
