import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:rehabilitation_app/ui/exercises/active_exercice_screen.dart';
import 'package:rehabilitation_app/ui/patient/home/patient_bottom_nav.dart';
import 'package:rehabilitation_app/ui/patient/doctors/FindDoctorScreen.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/ui/shared/NotificationsPage.dart';
import 'package:rehabilitation_app/ui/settings/SettingsPage.dart';
class RecoveryPlanScreen extends StatefulWidget {
  const RecoveryPlanScreen({super.key});

  @override
  State<RecoveryPlanScreen> createState() => _RecoveryPlanScreenState();
}

class _RecoveryPlanScreenState extends State<RecoveryPlanScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _planData;
  Map<String, dynamic>? _patientProfile;
  bool _isReminding = false;
  int _unreadNotifs = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final profile = await ApiService.getUserProfile();
    final plan = await ApiService.getRecoveryPlan();
    final stats = await ApiService.getPatientDashboardStats();

    if (mounted) {
      setState(() {
        _patientProfile = profile;
        _planData = plan;
        _unreadNotifs = stats['unreadNotifications'] ?? 0;
        _isLoading = false;
      });
    }
  }

  Future<void> _remindDoctor() async {
    setState(() => _isReminding = true);
    final success = await ApiService.remindDoctorToCreatePlan();
    if (mounted) {
      setState(() => _isReminding = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder sent to your doctor!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to send reminder.'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F6FA),
        body: Center(child: CircularProgressIndicator()),
        bottomNavigationBar: PatientBottomNavBar(currentIndex: 0),
      );
    }

    if (_planData == null) {
      final hasDoctor = _patientProfile?['assignedDoctorId'] != null;
      return Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        appBar: AppBar(
          title: const Text("My Recovery Plan"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsPage(),
                    ),
                  ).then((_) => _fetchData());
                },
                child: Center(
                  child: Badge(
                    isLabelVisible: _unreadNotifs > 0,
                    label: Text('$_unreadNotifs'),
                    child: const Icon(Icons.notifications_none),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.assignment_late_outlined,
                  size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text("You have no recovery plan yet.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              hasDoctor
                  ? ElevatedButton.icon(
                      onPressed: _isReminding ? null : _remindDoctor,
                      icon: _isReminding
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.notifications_active),
                      label: Text(_isReminding ? 'Sending...' : 'Remind Doctor'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FindDoctorScreen()));
                      },
                      icon: const Icon(Icons.person_search),
                      label: const Text('Connect with Doctor'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                      ),
                    ),
            ],
          ),
        ),
        bottomNavigationBar: const PatientBottomNavBar(currentIndex: 0, hideActiveState: true),
      );
    }

    final name = _patientProfile?['name']?.split(' ')[0] ?? 'Patient';
    final progress = (_planData!['overallProgress'] ?? 0).toDouble();
    final phases = _planData!['phases'] as List? ?? [];
    final exercises = _planData!['exercisePlan'] != null
        ? [_planData!['exercisePlan']]
        : [];
    final tip = _planData!['todayTip'] ?? "Consistency is key!";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      /// ---------------- BODY ----------------
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  /// HEADER
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "My Recovery Plan",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsPage(),
                            ),
                          ).then((_) => _fetchData());
                        },
                        child: Badge(
                          isLabelVisible: _unreadNotifs > 0,
                          label: Text('$_unreadNotifs'),
                          child: const Icon(Icons.notifications_none),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsPage(),
                            ),
                          );
                        },
                        child: const Icon(Icons.settings_outlined),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ================= OVERALL CARD =================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _card(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ===== TOP TEXT =====
                      Text(
                        "Great job, $name! 🎉",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        "You’re on track. Keep following your plan consistently.",
                        style: TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 16),

                      /// ===== MIDDLE ROW (RING + RIGHT INFO) =====
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /// RING
                          CircularPercentIndicator(
                            radius: 65,
                            lineWidth: 10,
                            percent: (progress / 100).clamp(0.0, 1.0),
                            circularStrokeCap: CircularStrokeCap.round,
                            backgroundColor: Colors.grey.shade200,
                            linearGradient: const LinearGradient(
                              colors: [Color(0xFF4A90E2), Color(0xFF4A90E2)],
                            ),
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${progress.toInt()}%",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text("Completed",
                                    style: TextStyle(fontSize: 11)),
                              ],
                            ),
                          ),

                          const SizedBox(width: 18),

                          /// RIGHT SIDE
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 45),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _SideInfo(
                                    Icons.calendar_today,
                                    "Plan Started",
                                    _planData!['startDate'] ?? 'TBD',
                                  ),
                                  const SizedBox(height: 16),
                                  _SideInfo(
                                    Icons.flag_outlined,
                                    "Est. Completion",
                                    _planData!['endDate'] ?? 'TBD',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// ===== BOTTOM BADGE =====
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.blue),
                            SizedBox(width: 6),
                            Text(
                              "You're doing great!",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// ================= PHASES =================
                const Text(
                  "Your Recovery Phases",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),

                const SizedBox(height: 12),

                /// SCROLLABLE
                SizedBox(
                  height: 290,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int i = 0; i < phases.length; i++) ...[
                          _PhaseCard(
                            number: phases[i]['status'] == 'Completed'
                                ? "✓"
                                : "${i + 1}",
                            title: phases[i]['title'] ?? 'Phase',
                            subtitle: phases[i]['subtitle'] ?? '',
                            date: phases[i]['date'] ?? '',
                            status: phases[i]['status'] ?? 'Upcoming',
                            borderColor: phases[i]['status'] == 'Completed' ||
                                    phases[i]['status'] == 'Active'
                                ? Colors.blue
                                : (phases[i]['status'] == 'Overdue' ? Colors.red : Colors.grey.shade300),
                            badgeColor: phases[i]['status'] == 'Completed'
                                ? const Color(0xFFE8F0FF)
                                : (phases[i]['status'] == 'Overdue' ? const Color(0xFFFFEBEB) : const Color(0xFFF1F3F6)),
                            circleColor: phases[i]['status'] == 'Completed' ||
                                    phases[i]['status'] == 'Active'
                                ? Colors.blue
                                : (phases[i]['status'] == 'Overdue' ? Colors.red : Colors.grey),
                            statusTextColor: phases[i]['status'] == 'Completed'
                                ? Colors.green
                                : (phases[i]['status'] == 'Active'
                                    ? Colors.blue
                                    : (phases[i]['status'] == 'Overdue' ? Colors.red : Colors.grey)),
                            onMarkCompleted: (phases[i]['status'] == 'Active' || phases[i]['status'] == 'Overdue')
                                ? () async {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marking phase completed...')));
                                    final success = await ApiService.markPhaseCompleted(_planData!['id'], i);
                                    if (success) {
                                      _fetchData();
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to complete phase', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                                    }
                                  }
                                : null,
                          ),
                          if (i < phases.length - 1)
                            _phaseLine(phases[i]['status'] == 'Completed'
                                ? Colors.blue
                                : Colors.grey.shade300),
                        ]
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// ================= TODAY PLAN =================
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Plan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (exercises.isNotEmpty) ...[
                  _exerciseTile(context, exercises[0]),
                  const SizedBox(height: 10),
                ],
                if (exercises.isEmpty)
                  const Text("No tasks for today.",
                      style: TextStyle(color: Colors.grey)),

                const SizedBox(height: 24),

                /// ================= PLAN DETAILS =================
                const Text(
                  "Plan Details",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 14),

                /// FIRST ROW
                Row(
                  children: [
                    Expanded(
                      child: _DetailCard(
                        title: "Exercises",
                        value: exercises.isNotEmpty ? "1 Assigned" : "None",
                        icon: Icons.directions_run,
                        color: const Color(0xFF5B9CFF),
                        lightColor: const Color(0xFFEFF6FF),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _DetailCard(
                        title: "Appointments",
                        value: "Check Calendar",
                        icon: Icons.calendar_month,
                        color: const Color(0xFFA78BFA),
                        lightColor: const Color(0xFFF5F3FF),
                      ),
                    ),
                  ],
                ),


                const SizedBox(height: 20),

                /// ================= TIP =================
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFFAF4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD8F3E3),
                    ),
                  ),
                  child: Row(
                    children: [
                      /// ICON
                      Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6ED6A8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 16),

                      /// TEXT
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// TITLE
                            const Text(
                              "Today's Tip",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1F2937),
                              ),
                            ),

                            const SizedBox(height: 6),

                            /// DESCRIPTION
                            Text(
                              tip,
                              style: const TextStyle(
                                color: Color(0xFF4B5563),
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const PatientBottomNavBar(currentIndex: 0, hideActiveState: true),
    );
  }

  /// ---------------- WIDGETS ----------------

  static BoxDecoration _card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
      ],
    );
  }

  static Widget _exerciseTile(BuildContext context, Map<String, dynamic> exercise) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _card(),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: Color(0xFFEAF3FF),
            child: Icon(
              Icons.fitness_center,
              color: Color(0xFF4A90E2),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Exercise Session",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("${exercise['title'] ?? 'Leg Extensions'} – ${exercise['mode'] ?? 'Active Mode'}"),
                const SizedBox(height: 4),
                Text(
                  "${exercise['estimatedTimeMin'] ?? 15} min  •  ${exercise['repsTotal'] ?? 15} reps total",
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


  static Widget _gradientButton(BuildContext context, Map<String, dynamic> exercise) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActiveExerciseScreen(exercise: exercise),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF4A90E2),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Text(
          "Start Now",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/// SIDE INFO
class _SideInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SideInfo(this.icon, this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

/// PHASE CARD
class _PhaseCard extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final String date;
  final String status;

  final Color borderColor;
  final Color badgeColor;
  final Color circleColor;
  final Color statusTextColor;
  final VoidCallback? onMarkCompleted;

  const _PhaseCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.status,
    required this.borderColor,
    required this.badgeColor,
    required this.circleColor,
    required this.statusTextColor,
    this.onMarkCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 162,
          margin: const EdgeInsets.only(top: 18),
          padding: const EdgeInsets.fromLTRB(14, 28, 14, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: status == "Completed" ? const Color(0xFFB7EACB) : borderColor,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: borderColor == Colors.blue ? Colors.blue : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                date,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: status == "Completed" ? const Color(0xFFE8F8EF) : badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (status == "Completed")
                        const Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: Icon(
                            Icons.check,
                            color: Colors.green,
                            size: 16,
                          ),
                        ),
                      Text(
                        status,
                        style: TextStyle(
                          color: status == "Completed" ? Colors.green : statusTextColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (onMarkCompleted != null) ...[
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onMarkCompleted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 36),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text("Mark Complete", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _phaseLine(Color color) {
  return Container(
    width: 36,
    height: 3,
    margin: const EdgeInsets.only(bottom: 70),
    color: color,
  );
}

/// DETAILS CARD
class _DetailCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color lightColor;

  const _DetailCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.lightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: lightColor.withOpacity(0.65),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color.withOpacity(0.85),
              size: 24,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
