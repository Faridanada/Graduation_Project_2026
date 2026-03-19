import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TodaysSessionsPage extends StatefulWidget {
  const TodaysSessionsPage({Key? key}) : super(key: key);

  @override
  State<TodaysSessionsPage> createState() => _TodaysSessionsPageState();
}

class _TodaysSessionsPageState extends State<TodaysSessionsPage> {
  List<Map<String, dynamic>> todaysSessions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      final fetched = await ApiService.getDoctorTodayAppointments();
      if (mounted) {
        setState(() {
          todaysSessions = fetched.map((s) => {
            'name': s['patientName'] ?? s['doctorName'] ?? 'Unknown',
            'age': s['age']?.toString() ?? 'N/A',
            'phone': s['phone'] ?? 'N/A',
            'injuryType': s['type'] ?? 'Consultation',
            'time': s['time'] ?? '12:00 PM',
            'status': s['status'] == 'completed' ? 'Completed' : (s['status'] == 'in_progress' ? 'In Progress' : 'Scheduled'),
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF95B8D1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Today\'s Sessions',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Total Sessions: ${todaysSessions.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: todaysSessions.length,
                itemBuilder: (context, index) {
                  return _buildSessionCard(todaysSessions[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    Color statusColor = _getStatusColor(session['status']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFF95B8D1).withOpacity(0.6),
                  child: Text(
                    session['name'].substring(0, 1),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 14, color: Color(0xFF95B8D1)),
                          const SizedBox(width: 4),
                          Text(
                            session['time'],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF95B8D1),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    session['status'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    'Age:',
                    session['age'],
                    Icons.person,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Phone:',
                    session['phone'],
                    Icons.phone,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Injury Type:',
                    session['injuryType'],
                    Icons.medical_services,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF95B8D1)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      case 'Scheduled':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
