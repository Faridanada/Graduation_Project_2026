import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
//import 'package:my_test_app/active_exercise_screen.dart';
import 'active_exercice_screen.dart';
import 'patient_bottom_nav.dart';

class RecoveryPlanScreen extends StatelessWidget {
  const RecoveryPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      /// ---------------- BODY ----------------
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
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
                    const Icon(Icons.notifications_none),
                    const SizedBox(width: 12),
                    const Icon(Icons.settings_outlined),
                  ],
                ),

                const SizedBox(height: 6),

                const Text(
                  "Your personalized plan for a faster recovery 💚",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                /// ================= OVERALL CARD =================
                /// ================= OVERALL CARD (FIXED PERFECTLY) =================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _card(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ===== TOP TEXT =====
                      const Text(
                        "Great job, John! 🎉",
                        style: TextStyle(
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
                            percent: 0.65,
                            circularStrokeCap: CircularStrokeCap.round,
                            backgroundColor: Colors.grey.shade200,
                            linearGradient: const LinearGradient(
                              colors: [Color(0xFF4A90E2), Color(0xFF4A90E2)],
                            ),
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "65%",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text("Completed",
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
                                children: const [
                                  _SideInfo(
                                    Icons.calendar_today,
                                    "Plan Started",
                                    "Apr 15, 2025",
                                  ),
                                  SizedBox(height: 16),
                                  _SideInfo(
                                    Icons.flag_outlined,
                                    "Est. Completion",
                                    "Jun 10, 2025",
                                  ),
                                  SizedBox(height: 16),
                                  _SideInfo(
                                    Icons.access_time,
                                    "Days Remaining",
                                    "42 days",
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

                /// SCROLLABLE (FIXED LIKE FIGMA)
                SizedBox(
                  height: 240,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        /// PHASE 1
                        _PhaseCard(
                          number: "✓",
                          title: "Phase 1",
                          subtitle: "Pain & Swelling\nReduction",
                          date: "Apr 15 – Apr 29",
                          status: "Completed",
                          borderColor: Colors.blue,
                          badgeColor: Colors.green,
                          circleColor: Colors.blue,
                          statusTextColor: Colors.green,
                        ),

                        _phaseLine(Colors.blue),

                        /// PHASE 2
                        _PhaseCard(
                          number: "2",
                          title: "Phase 2",
                          subtitle: "Mobility &\nStrength Building",
                          date: "Apr 30 – May 20",
                          status: "In Progress",
                          borderColor: Colors.blue,
                          badgeColor: Color(0xFFE8F0FF),
                          circleColor: Colors.blue,
                          statusTextColor: Colors.blue,
                        ),

                        _phaseLine(Colors.grey.shade300),

                        /// PHASE 3
                        _PhaseCard(
                          number: "3",
                          title: "Phase 3",
                          subtitle: "Advanced\nStrength",
                          date: "May 21 – Jun 3",
                          status: "Upcoming",
                          borderColor: Colors.grey.shade300,
                          badgeColor: Color(0xFFF1F3F6),
                          circleColor: Colors.grey,
                          statusTextColor: Colors.grey,
                        ),

                        _phaseLine(Colors.grey.shade300),

                        /// PHASE 4
                        _PhaseCard(
                          number: "4",
                          title: "Phase 4",
                          subtitle: "Return to Daily\nActivities",
                          date: "Jun 4 – Jun 10",
                          status: "Upcoming",
                          borderColor: Colors.grey.shade300,
                          badgeColor: Color(0xFFF1F3F6),
                          circleColor: Colors.grey,
                          statusTextColor: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// ================= TODAY PLAN =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Today's Plan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "April 29, 2025",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _exerciseTile(context),
                const SizedBox(height: 10),
                _medicationTile(),

                const SizedBox(height: 24),

                /// ================= PLAN DETAILS =================
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
                /// FIRST ROW
                Row(
                  children: const [
                    Expanded(
                      child: _DetailCard(
                        title: "Exercises",
                        value: "12 / 36 completed",
                        icon: Icons.directions_run,
                        color: Color(0xFF5B9CFF),
                        lightColor: Color(0xFFEFF6FF),
                        progress: 0.5,
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: _DetailCard(
                        title: "Medications",
                        value: "18 / 36 taken",
                        icon: Icons.medication,
                        color: Color(0xFF34D399),
                        lightColor: Color(0xFFECFDF5),
                        progress: 0.6,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                /// SECOND ROW
                Row(
                  children: const [
                    Expanded(
                      child: _DetailCard(
                        title: "Appointments",
                        value: "2 upcoming",
                        icon: Icons.calendar_month,
                        color: Color(0xFFA78BFA),
                        lightColor: Color(0xFFF5F3FF),
                        progress: 0.45,
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: _DetailCard(
                        title: "Guidelines",
                        value: "8 tips",
                        icon: Icons.description_outlined,
                        color: Color(0xFFFB7185),
                        lightColor: Color(0xFFFFF1F2),
                        progress: 0.55,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// ================= TIP =================
                /// ================= TODAY TIP =================
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
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// TITLE
                            Text(
                              "Today's Tip",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1F2937),
                              ),
                            ),

                            SizedBox(height: 6),

                            /// DESCRIPTION
                            Text(
                              "Consistency is key! Small steps every day lead to big improvements.",
                              style: TextStyle(
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

      bottomNavigationBar: const PatientBottomNavBar(currentIndex: 0),
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

  static Widget _exerciseTile(BuildContext context) {
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Exercise Session",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Knee Flexion – Active Mode"),
                SizedBox(height: 4),
                Text(
                  "15 min  •  2 of 3 sets completed",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _gradientButton(context),
        ],
      ),
    );
  }

  static Widget _medicationTile() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _card(),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: Color(0xFFFFF7EA),
            child: Icon(
              Icons.medication,
              color: Color(0xFFFFC857),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Medication",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Take your morning medication"),
                SizedBox(height: 4),
                Text(
                  "09:00 AM",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Text("Taken", style: TextStyle(color: Colors.green)),
                SizedBox(width: 4),
                Icon(Icons.check, size: 16, color: Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _gradientButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ActiveExerciseScreen(),
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
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 162,
          height: 212,
          margin: const EdgeInsets.only(top: 18),
          padding: const EdgeInsets.fromLTRB(14, 28, 14, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  status == "Completed" ? const Color(0xFFB7EACB) : borderColor,
            ),
          ),
          child: Column(
            children: [
              /// TITLE
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

              /// SUBTITLE
              /// SUBTITLE
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

              /// DATE
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

              /// STATUS BADGE
              /// STATUS BADGE
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: status == "Completed"
                        ? const Color(0xFFE8F8EF)
                        : badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// CHECK ICON FOR COMPLETED
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
                          color: status == "Completed"
                              ? Colors.green
                              : statusTextColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        /// TOP NUMBER CIRCLE
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
/// DETAILS CARD
/// DETAILS CARD
class _DetailCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color lightColor;
  final double progress;

  const _DetailCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.lightColor,
    required this.progress,
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
          /// ICON
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

          /// TITLE
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 4),

          /// VALUE
          Text(
            value,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),

          const Spacer(),

          /// PROGRESS BAR
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: progress,
              color: color.withOpacity(0.85),
              backgroundColor: color.withOpacity(0.12),
            ),
          ),
        ],
      ),
    );
  }
}
