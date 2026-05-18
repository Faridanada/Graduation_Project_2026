import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Chats.dart';
import 'SettingsPage.dart';
import 'NotificationsPage.dart';
import 'reminders.dart';
import 'improvements_screen.dart';
import 'book_appointement.dart';
import 'report_wound_screen.dart';
import 'start_exercise_screen.dart';
import 'FindDoctorScreen.dart';
import '../services/api_service.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    _HomeContent(),
    const Chats(showNavBar: false),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _currentIndex == 0 ? _buildAppBar() : null,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 0.5,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded), label: 'Chats'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
    );
  }

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
        IconButton(
          icon: const Icon(Icons.search, size: 28),
          color: Colors.black,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FindDoctorScreen()),
            );
          },
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.notifications_none,
              color: Colors.black,
              size: 28,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          color: Colors.black,
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
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  String userName = "Patient";
  bool isLoading = true;
  List<dynamic> todayExercises = [];
  List<dynamic> reminders = [];
  Map<String, dynamic>? nextAppointment;
  int completedExercises = 0;
  int upcomingAppointments = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final userProfile = await ApiService.getUserProfile();
      final name = userProfile != null ? userProfile['name'] : null;
      final exercises = await ApiService.getPatientTodayExercises();
      final fetchedReminders = await ApiService.getPatientReminders();
      final appointment = await ApiService.getPatientNextAppointment();

      if (mounted) {
        setState(() {
          if (name != null && name.isNotEmpty) {
            userName = name.split(' ')[0];
          }
          todayExercises = exercises;
          reminders = fetchedReminders;
          nextAppointment = appointment;
          completedExercises =
              exercises.where((e) => e['isCompleted'] == true).length;
          upcomingAppointments = appointment != null ? 1 : 0;
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),
              _buildGreetingSection(),
              const SizedBox(height: 18),
              _buildEmergencyCall(),
              const SizedBox(height: 24),
              _buildExercisesSection(),
              const SizedBox(height: 20),
              _buildRemindersSection(),
              const SizedBox(height: 36),
              _buildActivitiesSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Morning, ${userName.isNotEmpty ? userName : 'Patient'}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Let's continue your recovery!",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF2196F3).withOpacity(0.12),
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'P',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCall() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () async {
          final Uri phoneUri = Uri(scheme: 'tel', path: '112');
          if (await canLaunchUrl(phoneUri)) {
            await launchUrl(phoneUri);
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8A80)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: const [
              Icon(Icons.call, color: Colors.white, size: 22),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Emergency Call',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'Contact emergency support',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationsScreen()),
                  );
                },
                child: const Text(
                  'See All >',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2196F3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: reminders.isEmpty
                ? const Text(
                    'No reminders for now.',
                    style: TextStyle(color: Colors.grey),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: reminders.map<Widget>((r) {
                      final text = r['text'] ?? r.toString();
                      final time = r['time'] ?? '';
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.notifications,
                              color: Colors.orange),
                        ),
                        title: Text(text),
                        subtitle: time.isNotEmpty ? Text(time) : null,
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesSection() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Exercises',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: todayExercises.isEmpty
                ? const Text(
                    'No exercises assigned for today.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  )
                : Column(
                    children: todayExercises.map<Widget>((exercise) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.fitness_center,
                              color: Colors.blue),
                        ),
                        title: Text(exercise['title'] ?? 'Exercise'),
                        subtitle: Text(
                            'Est. time: ${exercise['estimatedTimeMin'] ?? 0} min'),
                        trailing: IconButton(
                          icon:
                              const Icon(Icons.play_arrow, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => StartExerciseScreen(
                                        exercise: exercise as Map<String, dynamic>?,
                                      )),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              _buildActivityTile(
                label: 'Start Exercise',
                icon: Icons.fitness_center,
                color: Colors.blue[200],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const StartExerciseScreen()),
                  );
                },
              ),
              _buildActivityTile(
                label: 'Appointments',
                icon: Icons.calendar_today,
                color: Colors.purple[200],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const BookAppointmentScreen()),
                  );
                },
              ),
              _buildActivityTile(
                label: 'My Improvement',
                icon: Icons.trending_up,
                color: Colors.orange[200],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ImprovementScreen()),
                  );
                },
              ),
              _buildActivityTile(
                label: 'Report Wound',
                icon: Icons.camera_alt,
                color: Colors.cyan[200],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ReportWoundScreen()),
                  );
                },
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.chevron_right, color: Colors.black54, size: 18),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: (color ?? Colors.blue).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color ?? Colors.blue, size: 20),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}
