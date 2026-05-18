import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class Appointments extends StatefulWidget {
  const Appointments({Key? key}) : super(key: key);

  @override
  State<Appointments> createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> {
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
      final data = await ApiService.getAppointments();
      if (mounted) {
        setState(() {
          allAppointments = data.map((apt) {
            String statusValue = apt['status'] ?? 'pending';
            String uiStatus = (statusValue == 'completed' ||
                    statusValue == 'upcoming' ||
                    statusValue == 'Confirmed')
                ? 'Confirmed'
                : 'Pending';

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
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get filteredAppointments {
    final now = DateTime.now();
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

  String _getHeaderText() {
    final now = DateTime.now();
    if (selectedFilter == 'Today') {
      return 'Today, ${DateFormat('d MMM yyyy').format(now)}';
    } else if (selectedFilter == 'Week') {
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter tabs
              _buildFilterTabs(),
              const SizedBox(height: 20),

              // Date header
              Text(
                _getHeaderText(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),

              // Appointments count
              Text(
                '${filteredAppointments.length} appointments',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),

              // Appointments list
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: filteredAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment = filteredAppointments[index];
                          bool showDateLabel = false;

                          // Show date label for non-today appointments
                          if (selectedFilter != 'Today') {
                            if (index == 0 ||
                                filteredAppointments[index - 1]['date'].day !=
                                    appointment['date'].day) {
                              showDateLabel = true;
                            }
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showDateLabel) ...[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 8, top: 8),
                                  child: Text(
                                    DateFormat('EEEE, d MMMM')
                                        .format(appointment['date']),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ],
                              _buildAppointmentCard(appointment),
                              const SizedBox(height: 12),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black),
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
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      children: [
        _buildFilterButton('Today'),
        const SizedBox(width: 12),
        _buildFilterButton('Week'),
        const SizedBox(width: 12),
        _buildFilterButton('Calendar View'),
      ],
    );
  }

  Widget _buildFilterButton(String label) {
    final isSelected = selectedFilter == label;
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
            color: isSelected ? const Color(0xFF5798C6) : Colors.grey[300]!,
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
    final isConfirmed = appointment['status'] == 'Confirmed';

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Time chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF5798C6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              appointment['time'],
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Patient info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment['name'],
                  style: const TextStyle(
                    fontSize: 16,
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
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isConfirmed
                  ? const Color.fromARGB(255, 99, 197, 150)
                      .withValues(alpha: 0.2)
                  : Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isConfirmed ? Icons.check_circle : Icons.schedule,
                  size: 14,
                  color: isConfirmed
                      ? const Color.fromARGB(255, 99, 197, 150)
                      : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  appointment['status'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isConfirmed
                        ? const Color.fromARGB(255, 99, 197, 150)
                        : Colors.orange,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

