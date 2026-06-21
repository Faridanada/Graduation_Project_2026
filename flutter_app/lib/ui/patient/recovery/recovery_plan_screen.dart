import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:rehabilitation_app/ui/exercises/active_exercice_screen.dart';
import 'package:rehabilitation_app/ui/patient/home/patient_bottom_nav.dart';
import 'package:rehabilitation_app/ui/patient/doctors/FindDoctorScreen.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/ui/shared/NotificationsPage.dart';
import 'package:rehabilitation_app/ui/settings/SettingsPage.dart';
import 'package:rehabilitation_app/ui/shared/notification_bell.dart';
class RecoveryPlanScreen extends StatefulWidget {
  final bool isDoctorView;
  final Map<String, dynamic>? initialPlanData;
  final Map<String, dynamic>? initialPatientProfile;

  const RecoveryPlanScreen({
    super.key,
    this.isDoctorView = false,
    this.initialPlanData,
    this.initialPatientProfile,
  });

  static const List<String> _dailyTips = [
    "Consistency is the key to recovery. Stay committed.",
    "Listen to your body. Rest when you feel pain, not just fatigue.",
    "Hydration is crucial for muscle repair. Drink plenty of water.",
    "Small progress is still progress. Celebrate every little victory.",
    "Don't rush the process. Healing takes time and patience.",
    "Focus on your breathing during exercises to improve oxygen flow.",
    "Maintain good posture even when you're not exercising.",
    "Quality over quantity. Proper form prevents further injury.",
    "A positive mindset can significantly impact your physical healing.",
    "Sleep is when your body heals the most. Aim for 7-8 hours.",
    "Ice reduces inflammation; heat relaxes muscles. Use them wisely.",
    "Never skip your warm-up. It prepares your body for the work ahead.",
    "Cooling down is just as important as the exercise itself.",
    "Nutrition plays a vital role in recovery. Eat protein-rich foods.",
    "It's normal to have bad days. Don't let them discourage you.",
    "Set realistic, short-term goals to keep your motivation high.",
    "Communicate openly with your doctor about your pain levels.",
    "Stretching gently can improve your flexibility and reduce stiffness.",
    "Avoid comparing your recovery journey to someone else's.",
    "Keep a journal to track your daily progress and feelings.",
    "Engage your core. It provides stability for all your movements.",
    "Don't push through sharp pain. Discomfort is okay, pain is not.",
    "Wear comfortable, supportive footwear during your exercises.",
    "Take your prescribed medication exactly as directed.",
    "Incorporate light walks into your routine if permitted.",
    "Visualize yourself moving smoothly and pain-free.",
    "Patience is your best friend during physical therapy.",
    "If an exercise feels wrong, stop and ask your physical therapist.",
    "Consistency beats intensity when it comes to rehabilitation.",
    "Don't forget to stretch the muscles opposing your injury.",
    "A balanced diet helps rebuild damaged tissues faster.",
    "Stress can tighten muscles. Practice relaxation techniques.",
    "Keep your appointments. Consistency with your doctor matters.",
    "Ask questions. Understanding your injury helps you heal better.",
    "Massage therapy can be a great addition to your recovery plan.",
    "Don't hold your breath during exercises. Breathe rhythmically.",
    "Use mirrors to check your form while exercising at home.",
    "Celebrate the days when you experience less pain.",
    "Recovery isn't linear. Expect ups and downs.",
    "Keep the injured area elevated when resting to reduce swelling.",
    "Start slow and gradually increase your range of motion.",
    "Trust the process, even when it feels incredibly slow.",
    "Incorporate balance exercises to prevent future injuries.",
    "Listen to calming music during your routine to stay relaxed.",
    "Avoid sitting in the same position for too long.",
    "Your body is working hard to heal. Treat it with kindness.",
    "Focus on what your body can do, not what it can't.",
    "Strength is built in the recovery phase, not just the workout.",
    "A strong support system can make recovery much easier.",
    "Every day is a step closer to getting back to 100%."
  ];

  @override
  State<RecoveryPlanScreen> createState() => _RecoveryPlanScreenState();
}

class _RecoveryPlanScreenState extends State<RecoveryPlanScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _planData;
  Map<String, dynamic>? _patientProfile;
  bool _isReminding = false;

  @override
  void initState() {
    super.initState();
    if (widget.isDoctorView) {
      _planData = widget.initialPlanData;
      _patientProfile = widget.initialPatientProfile;
      _isLoading = false;
    } else {
      _fetchData();
    }
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
      return Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: widget.isDoctorView ? null : const PatientBottomNavBar(currentIndex: 0),
      );
    }

    if (_planData == null) {
      final hasDoctor = _patientProfile?['assignedDoctorId'] != null;
      return Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        appBar: AppBar(
          title: Text(widget.isDoctorView ? "Recovery Plan" : "My Recovery Plan"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
          actions: widget.isDoctorView ? null : [
            Padding(
              padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: const NotificationBell(),
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
        bottomNavigationBar: widget.isDoctorView ? null : const PatientBottomNavBar(currentIndex: 0, hideActiveState: true),
      );
    }

    final name = _patientProfile?['name']?.split(' ')[0] ?? 'Patient';
    final phases = _planData!['phases'] as List? ?? [];
    int completedPhases = phases.where((p) => p['status'] == 'Completed').length;
    final progress = phases.isEmpty ? 0.0 : (completedPhases / phases.length) * 100;
    Map<String, dynamic>? activePhase;
    for (var p in phases) {
      if (p['status'] == 'Active') {
        activePhase = p;
        break;
      }
    }
    if (activePhase == null) {
      for (var p in phases) {
        if (p['active'] == true && p['completed'] != true) {
          activePhase = p;
          break;
        }
      }
    }
    final List<dynamic> exercises = (activePhase != null && activePhase['exercises'] is List) ? activePhase['exercises'] : [];
    
    final int tipIndex = DateTime.now().difference(DateTime(2024, 1, 1)).inDays % RecoveryPlanScreen._dailyTips.length;
    final tip = RecoveryPlanScreen._dailyTips[tipIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (Navigator.canPop(context))
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      Expanded(
                        child: Text(
                          widget.isDoctorView ? "$name's Recovery Plan" : "My Recovery Plan",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!widget.isDoctorView) ...[
                        const NotificationBell(),
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
                      ]
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _card(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
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

                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Your Recovery Phases",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: phases.length,
                  itemBuilder: (context, i) {
                    return _PhaseCard(
                      number: phases[i]['status'] == 'Completed'
                          ? "✔"
                          : (i + 1).toString().padLeft(2, '0'),
                      subtitle: phases[i]['subtitle'] ?? '',
                      date: phases[i]['date'] ?? '',
                      exercises: phases[i]['exercises'] ?? [],
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
                      onMarkCompleted: (!widget.isDoctorView && (phases[i]['status'] == 'Active' || phases[i]['status'] == 'Overdue'))
                          ? () async {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marking phase completed...')));
                              final success = await ApiService.markPhaseCompleted(_planData!['id'], i);
                              if (success) {
                                if (!widget.isDoctorView) _fetchData();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to complete phase', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                              }
                            }
                          : null,
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text("Today's Tasks", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                if (exercises.isEmpty)
                  const Text("No tasks for today.", style: TextStyle(color: Colors.grey))
                else
                  ...exercises.map((ex) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _exerciseTile(context, ex as Map<String, dynamic>),
                      )).toList(),

                if (!widget.isDoctorView) ...[
                  const SizedBox(height: 24),



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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.isDoctorView ? null : const PatientBottomNavBar(currentIndex: 0, hideActiveState: true),
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

  static Widget _exerciseTile(BuildContext context, Map<String, dynamic> rawExercise) {
    // Map available phase exercise fields to what the UI/ActiveExerciseScreen expects
    final exercise = Map<String, dynamic>.from(rawExercise);
    final type = exercise['exerciseType'] ?? 'Exercise';
    final isStab = type == 'Stabilization';
    
    exercise['title'] ??= isStab ? "Stabilization" : "$type Session";
    exercise['mode'] ??= isStab ? "Rest" : "${exercise['minAngle'] ?? 0}° - ${exercise['maxAngle'] ?? 90}° Range";
    exercise['estimatedTimeMin'] ??= 15;
    exercise['repsTotal'] ??= isStab ? 0 : (exercise['numberOfExercises'] ?? 3) * (exercise['numberOfReps'] ?? 10);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _card(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFFEAF3FF),
            child: Icon(
              isStab ? Icons.lock_outline : Icons.fitness_center,
              color: const Color(0xFF4A90E2),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(exercise['mode']),
                const SizedBox(height: 4),
                Text(
                  isStab 
                      ? "${exercise['stabilizationDays'] ?? 7} Days"
                      : "${exercise['repsTotal']} reps total  •  ${exercise['numberOfExercises'] ?? 3} sets of ${exercise['numberOfReps'] ?? 10}",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isStab)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Rest Day",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            )
          else
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

class _PhaseCard extends StatelessWidget {
  final String number;
  final String subtitle;
  final String date;
  final String status;
  final List<dynamic> exercises;

  final Color borderColor;
  final Color badgeColor;
  final Color circleColor;
  final Color statusTextColor;
  final VoidCallback? onMarkCompleted;

  const _PhaseCard({
    required this.number,
    required this.subtitle,
    required this.date,
    required this.status,
    required this.exercises,
    required this.borderColor,
    required this.badgeColor,
    required this.circleColor,
    required this.statusTextColor,
    this.onMarkCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: circleColor,
              child: Text(
                number,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              subtitle.isNotEmpty ? subtitle : "Phase",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              date,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: status == "Completed" ? const Color(0xFFE8F8EF) : badgeColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (status == "Completed")
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(Icons.check, color: Colors.green, size: 14),
                    ),
                  Text(
                    status,
                    style: TextStyle(
                      color: status == "Completed" ? Colors.green : statusTextColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Exercises:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    for (var ex in exercises)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Icon(
                              ex['exerciseType'] == 'Stabilization' ? Icons.lock_outline :
                              ex['exerciseType'] == 'Passive' ? Icons.autorenew :
                              ex['exerciseType'] == 'Passive-Monitored' ? Icons.videocam_outlined :
                              Icons.accessibility_new_outlined,
                              size: 16, 
                              color: ex['exerciseType'] == 'Stabilization' ? Colors.orange :
                                     ex['exerciseType'] == 'Passive' ? Colors.purple :
                                     ex['exerciseType'] == 'Passive-Monitored' ? Colors.red :
                                     Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ex['exerciseType'] ?? 'Exercise',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (ex['exerciseType'] == 'Stabilization')
                              Text("${ex['stabilizationDays'] ?? 7} Days", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
                            else
                              Text("${ex['numberOfExercises'] ?? 3}x${ex['numberOfReps'] ?? 10} • ${ex['minAngle'] ?? 0}°-${ex['maxAngle'] ?? 90}°", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    if (onMarkCompleted != null) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onMarkCompleted,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: const Text("Mark Phase as Complete", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
