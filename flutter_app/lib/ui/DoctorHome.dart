import 'package:flutter/material.dart';
import 'MonitorEx.dart';
import 'patientRequest.dart';
import 'AiReports.dart';
import 'ManageWounds.dart';
import 'Appointments.dart';
import 'Chats.dart';
import 'SettingsPage.dart';
import 'ActivePatientsPage.dart';
import 'TodaysSessionsPage.dart';
import 'AlertsPage.dart';
import 'NotificationsPage.dart';
import 'DoctorProfile.dart';
import 'AddNewPatient.dart';

/// Doctor home page - Main dashboard for healthcare professionals
class DoctorHome extends StatefulWidget {
  const DoctorHome({Key? key}) : super(key: key);

  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
  // UI State Management
  final Set<String> selectedAppointments = {};
  final Set<String> selectedExercises = {};
  int _selectedNavIndex = 0;
  final ScrollController _patientsScrollController = ScrollController();

  @override
  void dispose() {
    _patientsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildStatusOverview(),
              const SizedBox(height: 28),
              _buildRemindersSection(),
              const SizedBox(height: 28),
              _buildPatientsSection(),
              const SizedBox(height: 28),
              _buildActivitiesSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  /// Builds the professional app bar with branding
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      shadowColor: Colors.grey.withOpacity(0.1),
      title: const Text(
        'FLEXIO',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      actions: [
        // Notifications button with badge
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsPage(),
                  ),
                );
              },
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '2',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
        // Settings button
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.grey),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ActivePatientsPage()),
                );
              },
              child: _buildStatusCard(
                'Active Patients',
                '24',
                const Color.fromRGBO(128, 155, 206, 1).withOpacity(0.6),
                Icons.people_outline,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TodaysSessionsPage()),
                );
              },
              child: _buildStatusCard(
                'Today\'s Sessions',
                '6',
                const Color.fromRGBO(149, 184, 209, 1).withOpacity(0.6),
                Icons.check_circle_outline,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AlertsPage()),
                );
              },
              child: _buildStatusCard(
                'Alerts',
                '3',
                const Color.fromRGBO(184, 224, 210, 1).withOpacity(0.6),
                Icons.warning_outlined,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    String title,
    String value,
    Color backgroundColor,
    IconData icon,
  ) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black54, size: 24),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13.5,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reminders',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RemindersDetailsPage(),
                    ),
                  );
                },
                child: const Text(
                  'See All >',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2196F3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Appointments:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildReminderItem('11:00 · John Doe', 'apt1', false),
                      _buildReminderItem('12:00 · Harry Black', 'apt2', false),
                      _buildReminderItem('13:00 · Jack Doe', 'apt3', false),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Exercises:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildReminderItem('Fred Nerk', 'ex1', false),
                      _buildReminderItem('Alice Smith', 'ex2', false),
                      _buildReminderItem('Jane Doe', 'ex3', false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderItem(String text, String id, bool isSelected) {
    bool isAppointment = text.contains(':');
    bool currentlySelected = isAppointment
        ? selectedAppointments.contains(id)
        : selectedExercises.contains(id);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (isAppointment) {
                  if (currentlySelected) {
                    selectedAppointments.remove(id);
                  } else {
                    selectedAppointments.add(id);
                  }
                } else {
                  if (currentlySelected) {
                    selectedExercises.remove(id);
                  } else {
                    selectedExercises.add(id);
                  }
                }
              });
            },
            child: SizedBox(
              width: 20,
              height: 20,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: currentlySelected
                        ? const Color(0xFF2196F3)
                        : Colors.grey[300]!,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  color: currentlySelected
                      ? const Color(0xFF2196F3)
                      : Colors.transparent,
                ),
                child: currentlySelected
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: currentlySelected ? Colors.grey : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsSection() {
    final patients = [
      {
        'name': 'John Doe',
        'age': '21',
        'progress': '65',
        'status': 'On Track',
        'statusColor': const Color.fromRGBO(128, 155, 206, 1).withOpacity(0.6),
      },
      {
        'name': 'Harry Black',
        'age': '25',
        'progress': '80',
        'status': 'On Track',
        'statusColor': const Color.fromRGBO(128, 155, 206, 1).withOpacity(0.6),
      },
      {
        'name': 'Jack Doe',
        'age': '43',
        'progress': '30',
        'status': 'Needs Attention',
        'statusColor': const Color.fromRGBO(149, 184, 209, 1),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Patients',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllPatientsPage(),
                    ),
                  );
                },
                child: const Text(
                  'See All >',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2196F3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Row(
              children: [
                const SizedBox(width: 16),
                ...patients.map((patient) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _buildPatientCard(patient),
                    )),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Profile section with avatar and checkmark
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor:
                    const Color.fromRGBO(128, 155, 206, 1).withOpacity(0.6),
                child: Text(
                  patient['name'].substring(0, 1),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color:
                      const Color.fromRGBO(184, 224, 210, 1).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.teal[500],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Name
          Text(
            patient['name'],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),

          // Age
          Text(
            'Age ${patient['age']}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),

          // Progress percentage
          Text(
            '${patient['progress']}%',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          // Progress bar
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: int.parse(patient['progress']) / 100,
              minHeight: 6,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                patient['statusColor'],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Status
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 14,
                color: patient['statusColor'],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  patient['status'],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: patient['statusColor'],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _buildActivityTile(
                label: 'Monitor Exercise',
                icon: Icons.favorite,
                color: Colors.blue[200],
                route: const MonitorEx(),
              ),
              _buildActivityTile(
                label: 'Appointments',
                icon: Icons.calendar_today,
                color: Colors.purple[200],
                route: const Appointments(),
              ),
              _buildActivityTile(
                label: 'AI Reports',
                icon: Icons.trending_up,
                color: Colors.blue[200],
                route: const AiReports(),
              ),
              _buildActivityTile(
                label: 'Wounds',
                icon: Icons.medical_services,
                color: Colors.blue[200],
                route: const ManageWounds(),
              ),
              _buildActivityTile(
                label: 'Patient Request',
                icon: Icons.assignment,
                color: Colors.purple[200],
                route: const PatientRequest(),
              ),
              _buildActivityTile(
                label: 'Add New Patient',
                icon: Icons.person_add,
                color: Colors.green[200],
                route: const AddNewPatient(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile({
    required String label,
    required IconData icon,
    required Color? color,
    required Widget? route,
  }) {
    return GestureDetector(
      onTap: () {
        if (route != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => route),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color?.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedNavIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF2196F3),
      unselectedItemColor: Colors.grey[400],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
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
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Chats()),
          );
          return;
        }
        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DoctorProfile(source: 'home'),
            ),
          );
          return;
        }

        setState(() {
          _selectedNavIndex = index;
        });
      },
    );
  }
}

class RemindersDetailsPage extends StatelessWidget {
  const RemindersDetailsPage({Key? key}) : super(key: key);

  static const Color _primary = Color.fromRGBO(128, 155, 206, 1);
  static const Color _secondary = Color.fromRGBO(149, 184, 209, 1);
  static const Color _teal = Color.fromRGBO(184, 224, 210, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Reminders',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Today',
                    value: '14',
                    icon: Icons.today_outlined,
                    color: _primary,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _SummaryCard(
                    label: 'Pending',
                    value: '8',
                    icon: Icons.pending_actions_outlined,
                    color: _secondary,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _SummaryCard(
                    label: 'Done',
                    value: '6',
                    icon: Icons.task_alt_outlined,
                    color: _teal,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _SectionHeader(title: 'Today\'s Appointments'),
            SizedBox(height: 10),
            _InfoCard(
              children: [
                _ReminderRow(
                  time: '09:00',
                  title: 'John Doe',
                  subtitle: 'Knee rehab follow-up · Room 2',
                  status: 'High',
                ),
                _ReminderRow(
                  time: '10:30',
                  title: 'Harry Black',
                  subtitle: 'Post-surgery check · Room 1',
                  status: 'Normal',
                ),
                _ReminderRow(
                  time: '11:00',
                  title: 'John Doe',
                  subtitle: 'Mobility assessment · Video call',
                  status: 'Normal',
                ),
                _ReminderRow(
                  time: '12:00',
                  title: 'Harry Black',
                  subtitle: 'Pain management review · Room 4',
                  status: 'Normal',
                ),
                _ReminderRow(
                  time: '13:00',
                  title: 'Jack Doe',
                  subtitle: 'Wound care session · Room 3',
                  status: 'High',
                ),
                _ReminderRow(
                  time: '15:30',
                  title: 'Sarah White',
                  subtitle: 'Discharge readiness check · Room 5',
                  status: 'Normal',
                ),
              ],
            ),
            SizedBox(height: 18),
            _SectionHeader(title: 'Exercise Follow-ups'),
            SizedBox(height: 10),
            _InfoCard(
              children: [
                _ReminderRow(
                  time: '08:00',
                  title: 'Fred Nerk',
                  subtitle: 'Ankle flexion set · 3 x 12 reps',
                  status: 'Pending',
                ),
                _ReminderRow(
                  time: '09:45',
                  title: 'Alice Smith',
                  subtitle: 'Shoulder ROM exercise · 20 min',
                  status: 'Pending',
                ),
                _ReminderRow(
                  time: '11:15',
                  title: 'Jane Doe',
                  subtitle: 'Balance training · 2 rounds',
                  status: 'Done',
                ),
                _ReminderRow(
                  time: '14:00',
                  title: 'Michael Hill',
                  subtitle: 'Resistance band protocol · Level 2',
                  status: 'Pending',
                ),
                _ReminderRow(
                  time: '16:00',
                  title: 'Emma Cole',
                  subtitle: 'Core activation routine · 15 min',
                  status: 'Done',
                ),
              ],
            ),
            SizedBox(height: 18),
            _SectionHeader(title: 'Upcoming This Week'),
            SizedBox(height: 10),
            _InfoCard(
              children: [
                _UpcomingRow(day: 'Tue', item: '7 new patient assessments'),
                _UpcomingRow(day: 'Wed', item: '4 wound photo reviews pending'),
                _UpcomingRow(day: 'Thu', item: '6 telehealth rehab check-ins'),
                _UpcomingRow(day: 'Fri', item: '2 discharge planning meetings'),
                _UpcomingRow(
                    day: 'Sat', item: 'Monthly progress reports submission'),
              ],
            ),
            SizedBox(height: 18),
            _SectionHeader(title: 'Notes & Alerts'),
            SizedBox(height: 10),
            _InfoCard(
              children: [
                _NoteRow(text: 'Jack Doe missed morning medication reminder.'),
                _NoteRow(
                    text: 'Alice Smith uploaded new exercise video evidence.'),
                _NoteRow(
                    text: '2 critical alerts require response before 5:00 PM.'),
                _NoteRow(
                    text: 'Review AI recommendations for chronic pain group.'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black54, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final String time;
  final String title;
  final String subtitle;
  final String status;

  @override
  Widget build(BuildContext context) {
    final bool isHigh = status == 'High';
    final bool isDone = status == 'Done';
    final Color badgeColor = isHigh
        ? Colors.orange
        : isDone
            ? Colors.teal
            : const Color(0xFF2196F3);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 54,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({required this.day, required this.item});

  final String day;
  final String item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(149, 184, 209, 1).withOpacity(0.45),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.circle, size: 7, color: Color(0xFF2196F3)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AllPatientsPage extends StatefulWidget {
  const AllPatientsPage({Key? key}) : super(key: key);

  @override
  State<AllPatientsPage> createState() => _AllPatientsPageState();
}

class _AllPatientsPageState extends State<AllPatientsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _patients = [
    {
      'name': 'John Doe',
      'age': 21,
      'progress': 65,
      'status': 'On Track',
      'statusColor': const Color.fromRGBO(128, 155, 206, 1).withOpacity(0.6),
    },
    {
      'name': 'Harry Black',
      'age': 25,
      'progress': 80,
      'status': 'On Track',
      'statusColor': const Color.fromRGBO(128, 155, 206, 1).withOpacity(0.6),
    },
    {
      'name': 'Jack Doe',
      'age': 43,
      'progress': 30,
      'status': 'Needs Attention',
      'statusColor': const Color.fromRGBO(149, 184, 209, 1),
    },
    {
      'name': 'Alice Smith',
      'age': 19,
      'progress': 55,
      'status': 'On Track',
      'statusColor': const Color.fromRGBO(128, 155, 206, 1).withOpacity(0.6),
    },
    {
      'name': 'Fred Nerk',
      'age': 31,
      'progress': 42,
      'status': 'Needs Attention',
      'statusColor': const Color.fromRGBO(149, 184, 209, 1),
    },
    {
      'name': 'Maya Green',
      'age': 28,
      'progress': 74,
      'status': 'On Track',
      'statusColor': const Color.fromRGBO(128, 155, 206, 1).withOpacity(0.6),
    },
    {
      'name': 'Noah Brown',
      'age': 37,
      'progress': 61,
      'status': 'On Track',
      'statusColor': const Color.fromRGBO(128, 155, 206, 1).withOpacity(0.6),
    },
    {
      'name': 'Lina White',
      'age': 46,
      'progress': 27,
      'status': 'Needs Attention',
      'statusColor': const Color.fromRGBO(149, 184, 209, 1),
    },
    {
      'name': 'Omar Ali',
      'age': 52,
      'progress': 49,
      'status': 'Needs Attention',
      'statusColor': const Color.fromRGBO(149, 184, 209, 1),
    },
    {
      'name': 'Emma Cole',
      'age': 34,
      'progress': 88,
      'status': 'On Track',
      'statusColor': const Color.fromRGBO(128, 155, 206, 1).withOpacity(0.6),
    },
    {
      'name': 'Sam Reed',
      'age': 24,
      'progress': 69,
      'status': 'On Track',
      'statusColor': const Color.fromRGBO(128, 155, 206, 1).withOpacity(0.6),
    },
    {
      'name': 'Nina Ford',
      'age': 40,
      'progress': 35,
      'status': 'Needs Attention',
      'statusColor': const Color.fromRGBO(149, 184, 209, 1),
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredPatients {
    final query = _searchController.text.trim().toLowerCase();

    return _patients.where((patient) {
      final name = (patient['name'] as String).toLowerCase();
      final age = (patient['age'] as int).toString();
      final status = patient['status'] as String;
      final matchesSearch =
          query.isEmpty || name.contains(query) || age.contains(query);
      final matchesFilter =
          _selectedFilter == 'All' || status == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final patients = _filteredPatients;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'All Patients',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search patient by name or age',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('On Track'),
                const SizedBox(width: 8),
                _buildFilterChip('Needs Attention'),
              ],
            ),
          ),
          Expanded(
            child: patients.isEmpty
                ? const Center(
                    child: Text(
                      'No patients found',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.76,
                    ),
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      return _AllPatientCard(patient: patients[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = label;
        });
      },
      selectedColor: const Color(0xFF2196F3).withOpacity(0.18),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isSelected ? const Color(0xFF2196F3) : Colors.black87,
      ),
      side: BorderSide(
        color: isSelected
            ? const Color(0xFF2196F3).withOpacity(0.45)
            : Colors.grey.shade300,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _AllPatientCard extends StatelessWidget {
  const _AllPatientCard({required this.patient});

  final Map<String, dynamic> patient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor:
                    const Color.fromRGBO(128, 155, 206, 1).withOpacity(0.6),
                child: Text(
                  (patient['name'] as String).substring(0, 1),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color:
                      const Color.fromRGBO(184, 224, 210, 1).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.teal[500],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            patient['name'] as String,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Text(
            'Age ${patient['age']}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${patient['progress']}%',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (patient['progress'] as int) / 100,
              minHeight: 6,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                patient['statusColor'] as Color,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 14,
                color: patient['statusColor'] as Color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  patient['status'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: patient['statusColor'] as Color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
