import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewAppointment extends StatefulWidget {
  const NewAppointment({Key? key}) : super(key: key);

  @override
  State<NewAppointment> createState() => _NewAppointmentState();
}

class _NewAppointmentState extends State<NewAppointment> {
  String? selectedPatient;
  DateTime? selectedDate;
  String? selectedTime;
  String? selectedSessionType;
  final TextEditingController notesController = TextEditingController();

  final List<Map<String, String>> patients = [
    {
      'name': 'John Doe',
      'avatar': 'J',
    },
    {
      'name': 'Alice Smith',
      'avatar': 'A',
    },
    {
      'name': 'Mark Lee',
      'avatar': 'M',
    },
    {
      'name': 'Emma Brown',
      'avatar': 'E',
    },
  ];

  final List<String> sessionTypes = [
    'Physiotherapy',
    'Wound Check',
    'Rehabilitation',
    'Consultation',
    'Progress Review',
  ];

  final List<Map<String, dynamic>> timeSlots = [
    {
      'time': '10:30 AM',
      'available': true,
      'status': 'Available',
    },
    {
      'time': '11:00 AM',
      'available': false,
      'status': 'Conflict with another session',
    },
    {
      'time': '02:00 PM',
      'available': true,
      'status': 'Available',
    },
    {
      'time': '03:30 PM',
      'available': false,
      'status': 'Conflict with another session',
    },
    {
      'time': '04:00 PM',
      'available': true,
      'status': 'Available',
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedPatient = patients[0]['name'];
    selectedDate = DateTime(2026, 2, 12);
    selectedSessionType = sessionTypes[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Book Appointment',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Today, 12 Feb 2026',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 24),

                // Form Container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Select Patient
                      _buildFormLabel('Select Patient'),
                      const SizedBox(height: 12),
                      _buildPatientDropdown(),
                      const SizedBox(height: 24),

                      // Appointment Date
                      _buildFormLabel('Appointment Date'),
                      const SizedBox(height: 12),
                      _buildDateField(),
                      const SizedBox(height: 24),

                      // Appointment Time
                      _buildFormLabel('Appointment Time'),
                      const SizedBox(height: 12),
                      _buildTimeSlots(),
                      const SizedBox(height: 24),

                      // Session Type
                      _buildFormLabel('Session Type'),
                      const SizedBox(height: 12),
                      _buildSessionTypeDropdown(),
                      const SizedBox(height: 24),

                      // Notes
                      _buildFormLabel('Notes (optional)'),
                      const SizedBox(height: 12),
                      _buildNotesField(),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      _confirmAppointment();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5798C6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Confirm Appointment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Poppins',
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
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF95B8D1),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: const Text(
        'Book Appointment',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildFormLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildPatientDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPatient,
          isExpanded: true,
          icon: const Icon(Icons.expand_more, color: Colors.grey),
          items: patients.map((patient) {
            return DropdownMenuItem<String>(
              value: patient['name'],
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5798C6).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        patient['avatar']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5798C6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    patient['name']!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedPatient = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
        onTap: () async {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(2026, 2, 12),
            lastDate: DateTime(2026, 12, 31),
          );
          if (pickedDate != null) {
            setState(() {
              selectedDate = pickedDate;
            });
          }
        },
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedDate != null
                    ? DateFormat('d MMM yyyy').format(selectedDate!)
                    : '12 Feb 2026',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    return Column(
      children: timeSlots.map((slot) {
        final isAvailable = slot['available'];
        final isSelected = selectedTime == slot['time'];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: isAvailable
                ? () {
                    setState(() {
                      selectedTime = slot['time'];
                    });
                  }
                : null,
            child: Container(
              decoration: BoxDecoration(
                color: isAvailable
                    ? (isSelected
                        ? const Color(0xFF5798C6).withOpacity(0.1)
                        : Colors.white)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFF5798C6) : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slot['time'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isAvailable ? Colors.black : Colors.grey[400],
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              isAvailable ? Icons.check_circle : Icons.error,
                              size: 14,
                              color: isAvailable
                                  ? const Color.fromARGB(255, 99, 197, 150)
                                  : const Color.fromARGB(255, 239, 68, 68),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              slot['status'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isAvailable
                                    ? const Color.fromARGB(255, 99, 197, 150)
                                    : const Color.fromARGB(255, 239, 68, 68),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.expand_more,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSessionTypeDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedSessionType,
          isExpanded: true,
          icon: const Icon(Icons.expand_more, color: Colors.grey),
          items: sessionTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(
                type,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedSessionType = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: TextField(
        controller: notesController,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: 'Add session details...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
            fontFamily: 'Poppins',
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  void _confirmAppointment() {
    if (selectedPatient == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Appointment confirmed for $selectedPatient at $selectedTime',
        ),
        backgroundColor: const Color.fromARGB(255, 99, 197, 150),
      ),
    );

    // Reset form after confirmation
    setState(() {
      selectedTime = null;
    });
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF95B8D1),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }
}
