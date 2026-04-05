import 'package:flutter/material.dart';
import 'SettingsPage.dart';
import 'NotificationsPage.dart';
import 'package:intl/intl.dart';
import 'newAppointment.dart';
import '../services/api_service.dart';

class BookAppoint extends StatefulWidget {
  const BookAppoint({Key? key}) : super(key: key);

  @override
  State<BookAppoint> createState() => _BookAppointState();
}

class _BookAppointState extends State<BookAppoint> {
  String selectedFilter = 'Today';

  List<Map<String, dynamic>> allAppointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final data = await ApiService.getAllAppointments();
      if (mounted) {
        setState(() {
          allAppointments = data.map((apt) {
            String statusValue = apt['status'] ?? 'pending';
            String uiStatus = (statusValue == 'completed' || statusValue == 'upcoming' || statusValue == 'Confirmed') ? 'Confirmed' : 'Pending';
            
            return {
              'time': apt['time'] ?? '12:00 PM',
              'name': apt['patientName'] ?? apt['doctorName'] ?? 'Unknown',
              'service': apt['type'] ?? 'Consultation',
              'date': DateTime.tryParse(apt['date'] ?? '') ?? DateTime.now(),
              'status': uiStatus,
            };
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> get filteredAppointments {
    final now = DateTime(2026, 2, 12);
    final weekEnd = now.add(const Duration(days: 6));

    if (selectedFilter == 'Today') {
      return allAppointments
          .where((apt) =>
              apt['date'].year == now.year &&
              apt['date'].month == now.month &&
              apt['date'].day == now.day)
          .toList();
    } else if (selectedFilter == 'Week') {
      return allAppointments
          .where((apt) =>
              apt['date'].isAfter(now.subtract(const Duration(days: 1))) &&
              apt['date'].isBefore(weekEnd.add(const Duration(days: 1))))
          .toList();
    } else {
      // Calendar view - all future appointments
      return allAppointments
          .where((apt) => apt['date'].isAfter(weekEnd))
          .toList();
    }
  }

  String getFormattedDate() {
    final now = DateTime(2026, 2, 12);
    return DateFormat('d MMM yyyy').format(now);
  }

  String _getHeaderText() {
    if (selectedFilter == 'Today') {
      return 'Today, ${getFormattedDate()}';
    } else if (selectedFilter == 'Week') {
      final now = DateTime(2026, 2, 12);
      final weekEnd = now.add(const Duration(days: 6));
      return 'Week of ${DateFormat('d MMM').format(now)} - ${DateFormat('d MMM yyyy').format(weekEnd)}';
    } else {
      return 'Upcoming Appointments';
    }
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
                // Filter Tabs
                _buildFilterTabs(),
                const SizedBox(height: 16),

                // Date Header
                Text(
                  _getHeaderText(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 20),

                // Appointments List
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (filteredAppointments.isEmpty)
                  const Center(child: Text("No appointments found", style: TextStyle(color: Colors.grey)))
                else
                  ...filteredAppointments.map((appointment) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildAppointmentCard(appointment),
                      )),

                const SizedBox(height: 24),

                // Book New Appointment Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewAppointment(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 87, 152, 198),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      '+ Book New Appointment',
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
        'Appointments',
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NotificationsPage()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      children: [
        _buildFilterButton('Today', selectedFilter == 'Today'),
        const SizedBox(width: 12),
        _buildFilterButton('Week', selectedFilter == 'Week'),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Calendar View',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                ),
              ),
              const Spacer(),
              Text(
                '2',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: Colors.grey[600], size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5798C6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final now = DateTime(2026, 2, 12);
    final isToday = appointment['date'].year == now.year &&
        appointment['date'].month == now.month &&
        appointment['date'].day == now.day;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date label if not today
          if (!isToday)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                DateFormat('EEEE, d MMM').format(appointment['date']),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          // Time, Name, Service Row
          Row(
            children: [
              // Time Chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 87, 152, 198),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  appointment['time'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Patient Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['name'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment['service'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
}
