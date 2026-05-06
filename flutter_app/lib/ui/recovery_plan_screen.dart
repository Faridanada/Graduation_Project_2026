import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class RecoveryPlanScreen extends StatelessWidget {
  const RecoveryPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              /// HEADER
              Row(
                children: [
                  const Icon(Icons.arrow_back_ios_new, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "My Recovery Plan",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Stack(
                    children: [
                      const Icon(Icons.notifications_none),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.settings_outlined),
                ],
              ),

              const SizedBox(height: 6),

              const Text(
                "Your personalized plan for a faster recovery 💚",
                style: TextStyle(color: Color(0xFF8A94A6)),
              ),

              const SizedBox(height: 20),

              /// OVERALL CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _card(),
                child: Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 55,
                      lineWidth: 12,
                      percent: 0.65,
                      circularStrokeCap: CircularStrokeCap.round,
                      backgroundColor: const Color(0xFFE6EAF2),
                      linearGradient: const LinearGradient(
                        colors: [Color(0xFF6A5AE0), Color(0xFF3F8CFF)],
                      ),
                      center: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("65%",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
                          Text("Completed", style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    /// TEXT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Great job, John! 🎉",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 6),
                          const Text(
                            "You're on track. Keep following your plan consistently.",
                            style: TextStyle(color: Color(0xFF8A94A6)),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF2FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star,
                                    size: 14, color: Color(0xFF3F8CFF)),
                                SizedBox(width: 4),
                                Text("You're doing great!",
                                    style: TextStyle(
                                        color: Color(0xFF3F8CFF),
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// DIVIDER
                    Container(
                      width: 1,
                      height: 90,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      color: const Color(0xFFE6EAF2),
                    ),

                    /// RIGHT INFO
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SideInfo(Icons.calendar_today, "Plan Started",
                            "Apr 15, 2025"),
                        SizedBox(height: 12),
                        SideInfo(Icons.flag_outlined, "Est. Completion",
                            "Jun 10, 2025"),
                        SizedBox(height: 12),
                        SideInfo(
                            Icons.access_time, "Days Remaining", "42 days"),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// PHASES
              const Text("Your Recovery Phases",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

              const SizedBox(height: 14),

              SizedBox(
                height: 170,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    PhaseCard(
                      index: 1,
                      active: true,
                      completed: true,
                      title: "Phase 1",
                      subtitle: "Pain & Swelling\nReduction",
                      date: "Apr 15 – Apr 29",
                      status: "Completed",
                    ),
                    PhaseCard(
                      index: 2,
                      active: true,
                      completed: false,
                      title: "Phase 2",
                      subtitle: "Mobility &\nStrength Building",
                      date: "Apr 30 – May 20",
                      status: "In Progress",
                    ),
                    PhaseCard(
                      index: 3,
                      active: false,
                      completed: false,
                      title: "Phase 3",
                      subtitle: "Advanced\nStrength",
                      date: "May 21 – Jun 3",
                      status: "Upcoming",
                    ),
                    PhaseCard(
                      index: 4,
                      active: false,
                      completed: false,
                      title: "Phase 4",
                      subtitle: "Return to Daily\nActivities",
                      date: "Jun 4 – Jun 10",
                      status: "Upcoming",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// TODAY
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Today's Plan",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("April 29, 2025",
                      style: TextStyle(color: Color(0xFF8A94A6))),
                ],
              ),

              const SizedBox(height: 12),

              exerciseTile(),
              const SizedBox(height: 10),
              medicationTile(),

              const SizedBox(height: 24),

              /// DETAILS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Plan Details",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("View All", style: TextStyle(color: Colors.blue)),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: const [
                  DetailCard("Exercises", "12 / 36 completed", Colors.blue),
                  SizedBox(width: 10),
                  DetailCard("Medications", "18 / 36 taken", Colors.green),
                  SizedBox(width: 10),
                  DetailCard("Appointments", "2 upcoming", Colors.purple),
                  SizedBox(width: 10),
                  DetailCard("Guidelines", "8 tips", Colors.pink),
                ],
              ),

              const SizedBox(height: 20),

              /// TIP
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _card(),
                child: Row(
                  children: const [
                    CircleAvatar(
                      backgroundColor: Color(0xFF6FD3A8),
                      child: Icon(Icons.star, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Consistency is key! Small steps every day lead to big improvements.",
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF3F8CFF),
        unselectedItemColor: const Color(0xFF8A94A6),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chats"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  static BoxDecoration _card() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      );
}

/// ================= COMPONENTS =================

class SideInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const SideInfo(this.icon, this.title, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF3F8CFF)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 11, color: Color(0xFF8A94A6))),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class PhaseCard extends StatelessWidget {
  final int index;
  final bool active;
  final bool completed;
  final String title, subtitle, date, status;

  const PhaseCard({
    super.key,
    required this.index,
    required this.active,
    required this.completed,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: active ? const Color(0xFF3F8CFF) : const Color(0xFFE6EAF2)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor:
                active ? const Color(0xFF3F8CFF) : const Color(0xFFE6EAF2),
            child: completed
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text("$index",
                    style:
                        TextStyle(color: active ? Colors.white : Colors.grey)),
          ),
          const SizedBox(height: 6),
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: active ? const Color(0xFF3F8CFF) : Colors.grey)),
          const SizedBox(height: 6),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          Text(date,
              style: const TextStyle(fontSize: 11, color: Color(0xFF8A94A6))),
          const SizedBox(height: 8),

          /// STATUS CHIP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: completed
                  ? const Color(0xFFE6F6EC)
                  : active
                      ? const Color(0xFFEAF2FF)
                      : const Color(0xFFF1F3F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                color: completed
                    ? Colors.green
                    : active
                        ? const Color(0xFF3F8CFF)
                        : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const DetailCard(this.title, this.subtitle, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: RecoveryPlanScreen._card(),
        child: Column(
          children: [
            Icon(Icons.circle, color: color, size: 20),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.5,
              color: color,
              backgroundColor: color.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }
}

Widget exerciseTile() {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: RecoveryPlanScreen._card(),
    child: Row(
      children: [
        const CircleAvatar(
          backgroundColor: Color(0xFFEDE9FE),
          child: Icon(Icons.fitness_center, color: Colors.deepPurple),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Exercise Session",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Knee Flexion – Active Mode"),
              SizedBox(height: 4),
              Text("15 min  •  2 of 3 sets completed",
                  style: TextStyle(fontSize: 12, color: Color(0xFF8A94A6))),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF6A5AE0)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text("Start Now", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

Widget medicationTile() {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: RecoveryPlanScreen._card(),
    child: Row(
      children: [
        const CircleAvatar(
          backgroundColor: Color(0xFFFFF3E0),
          child: Icon(Icons.medication, color: Colors.orange),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Medication", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Take your morning medication"),
              SizedBox(height: 4),
              Text("09:00 AM",
                  style: TextStyle(fontSize: 12, color: Color(0xFF8A94A6))),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F6EC),
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
