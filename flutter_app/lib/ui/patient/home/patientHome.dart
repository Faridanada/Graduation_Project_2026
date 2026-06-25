import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rehabilitation_app/ui/chats/Chats.dart';
import 'package:rehabilitation_app/ui/settings/SettingsPage.dart';
import 'package:rehabilitation_app/ui/shared/NotificationsPage.dart';
import 'package:rehabilitation_app/ui/app_theme.dart';
import 'package:rehabilitation_app/ui/patient/recovery/reminders.dart';
import 'package:rehabilitation_app/ui/patient/recovery/improvements_screen.dart';
import 'package:rehabilitation_app/ui/patient/appointments/book_appointement.dart';
import 'package:rehabilitation_app/ui/patient/recovery/report_wound_screen.dart';
import 'package:rehabilitation_app/ui/exercises/active_exercice_screen.dart';
import 'package:rehabilitation_app/ui/patient/doctors/FindDoctorScreen.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/ui/patient/profile/PatientProfile.dart';
import 'package:rehabilitation_app/ui/patient/recovery/recovery_plan_screen.dart';
import 'package:rehabilitation_app/ui/shared/profile_avatar.dart';
import 'package:rehabilitation_app/ui/chats/ChatbotPage.dart';
import 'package:rehabilitation_app/ui/shared/notification_bell.dart';
import 'package:rehabilitation_app/ui/patient/exercises/WaitingForDoctorScreen.dart';
import 'package:rehabilitation_app/ui/exercises/passive_exercise_screen.dart';
import 'package:rehabilitation_app/ui/exercises/stabilization_exercise_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  final int initialTab;
  const PatientHomeScreen({super.key, this.initialTab = 0});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    // Unread count is now managed globally and initialized by other dashboard API calls.
  }

  void _goToHomeTab() {
    setState(() => _currentIndex = 0);
  }

  List<Widget> _buildPages() {
    return [
      _HomeContent(),
      Chats(
        showNavBar: false,
        onBackToHome: _goToHomeTab,
      ),
      PatientProfile(
        isTab: true,
        onBackToHome: _goToHomeTab,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _currentIndex == 0 ? _buildAppBar() : null,
      body: _buildPages()[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
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
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatbotPage()),
                );
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.question_mark_rounded, color: Colors.white),
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0.5,
      shadowColor: Colors.grey.withOpacity(0.1),
      title: Text('FLEXIO', style: AppTextStyles.heading(context)),
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
        const NotificationBell(),
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
  String? userProfileImage;
  String? patientId;
  bool isLoading = true;
  List<dynamic> todayExercises = [];
  List<dynamic> reminders = [];
  Map<String, dynamic>? nextAppointment;
  Map<String, dynamic>? assignedDoctor;
  int completedExercises = 0;
  int upcomingAppointments = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    ApiService.profileUpdateNotifier.addListener(_loadDashboardData);
  }

  @override
  void dispose() {
    ApiService.profileUpdateNotifier.removeListener(_loadDashboardData);
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    try {
      final userProfile = await ApiService.getUserProfile();
      final name = userProfile != null ? userProfile['name'] : null;
      List<dynamic> exercises = await ApiService.getPatientTodayExercises();
      
      // Fallback: If no explicit today exercises, pull from Active Recovery Plan phase
      if (exercises.isEmpty) {
        final plan = await ApiService.getRecoveryPlan();
        if (plan != null && plan['phases'] != null) {
          final planId = plan['id']?.toString() ?? plan['_id']?.toString();
          
          List<dynamic> completions = [];
          if (planId != null) {
            completions = await ApiService.getCompletions(planId: planId);
          }
          
          final todayStr = DateTime.now().toIso8601String().substring(0, 10);
          
          final phases = plan['phases'] as List<dynamic>;
          for (var phase in phases) {
            if (phase['status'] == 'Active' || phase['status'] == 'Overdue') {
              final phaseExs = phase['exercises'] ?? [];
              for (var ex in phaseExs) {
                if (ex is Map) {
                  ex['planId'] = planId;
                  final exId = ex['id']?.toString() ?? ex['_id']?.toString();
                  final isDone = completions.any((c) {
                    final cExId = c['exerciseId']?.toString();
                    final cDate = c['date']?.toString() ?? c['createdAt']?.toString() ?? '';
                    return cExId == exId && cDate.startsWith(todayStr) && c['done'] == true;
                  });
                  ex['isCompleted'] = isDone;
                }
              }
              exercises.addAll(phaseExs);
            }
          }
        }
      }

      final fetchedReminders = await ApiService.getPatientReminders();
      final appointment = await ApiService.getPatientNextAppointment();
      final doctor = await ApiService.getMyDoctor();

      if (mounted) {
        setState(() {
          if (name != null && name.isNotEmpty) {
            userName = name.split(' ')[0];
          }
          userProfileImage = userProfile?['profileImageUrl']?.toString() ?? userProfile?['profileImage']?.toString();
          patientId = userProfile?['id']?.toString() ?? userProfile?['_id']?.toString();
          // Filter out completed exercises so they disappear from the list
          todayExercises = exercises.where((e) => e['isCompleted'] != true).toList();
          reminders = fetchedReminders;
          nextAppointment = appointment;
          assignedDoctor = doctor;
          completedExercises =
              exercises.where((e) => e['isCompleted'] == true).length;
          upcomingAppointments = appointment != null ? 1 : 0;
          isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          _hasError = true;
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
              if (_hasError)
                _buildErrorState()
              else ...[
                _buildEmergencyCall(),
                const SizedBox(height: 24),
                _buildExercisesSection(),
                const SizedBox(height: 20),
                _buildRemindersSection(),
                const SizedBox(height: 36),
                _buildActivitiesSection(),
                const SizedBox(height: 32),
              ],
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
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
                      style: AppTextStyles.section(context)),
                  const SizedBox(height: 6),
                  Text("Let's continue your recovery!",
                      style: AppTextStyles.body(context)
                          .copyWith(color: Colors.grey[600])),
                ],
              ),
            ),
            ProfileAvatar(
              imageUrl: userProfileImage,
              name: userName,
              radius: 24,
              backgroundColor: AppColors.primary.withOpacity(0.12),
              textColor: const Color(0xFF2196F3),
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
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.call, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Emergency Call',
                    style: AppTextStyles.body(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
              Text('Contact emergency support',
                  style: AppTextStyles.caption(context)
                      .copyWith(color: Colors.white70)),
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          // Updated to match Recovery Plan UI
          if (todayExercises.isEmpty)
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
              child: const Text(
                'No exercises assigned for today.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...todayExercises.map((exercise) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _exerciseTile(context, exercise as Map<String, dynamic>),
              );
            }).toList(),
        ],
      ),
    );
  }

  String _getExerciseSubtitle(Map<String, dynamic> exercise) {
    final type = exercise['exerciseType'] ?? exercise['mode'] ?? '';
    
    if (type == 'Passive' || type == 'Passive-Monitored') {
      final time = exercise['estimatedTimeMin'] ?? 10;
      return "$time mins duration";
    } else if (type == 'Stabilization') {
      final angle = exercise['holdAngle'] ?? 90;
      final days = exercise['stabilizationDays'] ?? 1;
      return "Hold Angle: $angle°  •  $days Days";
    } else {
      // Active / Default
      final sets = exercise['numberOfExercises'] ?? 3;
      final repsPerSet = exercise['numberOfReps'] ?? 10;
      final repsTotal = exercise['repsTotal'] ?? (sets * repsPerSet);
      return "$repsTotal reps total  •  $sets sets of $repsPerSet";
    }
  }

  IconData _getExerciseIcon(String type) {
    if (type == 'Passive-Monitored') return Icons.videocam_outlined;
    if (type == 'Passive') return Icons.autorenew;
    if (type == 'Active') return Icons.accessibility_new_outlined;
    if (type == 'Stabilization') return Icons.lock_outline;
    return Icons.fitness_center;
  }

  Color _getExerciseColor(String type) {
    if (type == 'Passive-Monitored') return Colors.red;
    if (type == 'Passive') return Colors.purple;
    if (type == 'Active') return Colors.green;
    if (type == 'Stabilization') return Colors.orange;
    return const Color(0xFF4A90E2);
  }

  Widget _exerciseTile(BuildContext context, Map<String, dynamic> exercise) {
    final type = exercise['exerciseType'] ?? exercise['mode'] ?? '';
    final isStab = type == 'Stabilization';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: _getExerciseColor(type).withOpacity(0.1),
            child: Icon(
              _getExerciseIcon(type),
              color: _getExerciseColor(type),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      exercise['title'] ?? 'Exercise',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                    ),
                    const Text("  •  ", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    Text(
                      exercise['mode'] ?? exercise['exerciseType'] ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getExerciseSubtitle(exercise),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _gradientButton(context, exercise),
        ],
      ),
    );
  }

  Widget _gradientButton(BuildContext context, Map<String, dynamic> exercise) {
    return GestureDetector(
      onTap: () async {
        final response = await ApiService.startSession(exerciseId: exercise['id'] ?? exercise['_id']);
        if (response != null && response['sessionId'] != null) {
          exercise['sessionId'] = response['sessionId'];
        } else {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to start session. Please log out and log in again."), backgroundColor: Colors.red),
          );
          return;
        }
        if (!context.mounted) return;

        if (exercise['exerciseType'] == 'Passive-Monitored' && assignedDoctor != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WaitingForDoctorScreen(
                exercise: Map<String, dynamic>.from(exercise),
                patientId: patientId ?? '',
                patientName: userName,
                doctorId: assignedDoctor?['id']?.toString() ?? assignedDoctor?['_id']?.toString() ?? '',
              ),
            ),
          );
        } else if (exercise['exerciseType'] == 'Passive') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PassiveExerciseScreen(
                exercise: Map<String, dynamic>.from(exercise),
              ),
            ),
          ).then((_) => _loadDashboardData());
        } else if (exercise['exerciseType'] == 'Stabilization') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StabilizationExerciseScreen(
                exercise: Map<String, dynamic>.from(exercise),
              ),
            ),
          ).then((_) => _loadDashboardData());
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ActiveExerciseScreen(
                exercise: Map<String, dynamic>.from(exercise),
              ),
            ),
          ).then((_) => _loadDashboardData());
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2196F3).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Text(
          "Start Now",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
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
          LayoutBuilder(
            builder: (context, constraints) {
              final gridItemWidth = (constraints.maxWidth - 12) / 2;
              final gridItemHeight = gridItemWidth / 1.3;
              return Column(
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _buildActivityTile(
                        label: 'My Recovery Plan',
                        icon: Icons.fitness_center,
                        color: Colors.blue[200],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RecoveryPlanScreen()),
                          ).then((_) => _loadDashboardData());
                        },
                      ),
                      _buildActivityTile(
                        label: 'Book Appointments',
                        icon: Icons.calendar_today,
                        color: Colors.purple[200],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => BookAppointmentScreen(doctor: assignedDoctor)),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: gridItemHeight,
                    child: _buildHorizontalActivityTile(
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
                  ),
                ],
              );
            },
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
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
                Icon(Icons.chevron_right, color: Colors.black54, size: 16),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              width: 48,
              height: 40,
              decoration: BoxDecoration(
                color: (color ?? Colors.blue).withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color ?? Colors.blue, size: 30),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
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

  Widget _buildHorizontalActivityTile({
    required String label,
    required IconData icon,
    required Color? color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (color ?? Colors.blue).withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color ?? Colors.blue, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text(
              "Failed to load dashboard data",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  _hasError = false;
                });
                _loadDashboardData();
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
