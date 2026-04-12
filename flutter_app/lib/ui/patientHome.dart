import 'package:flutter/material.dart';
import 'Chats.dart';
import 'SettingsPage.dart';

import 'report_wound_screen.dart';
import 'start_exercise_screen.dart';
import 'live_session_screen.dart';

import 'FindDoctorScreen.dart';
import '../services/api_service.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _HomeContent(),
    Chats(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF9FBFF),
              Color(0xFFEFF4FC),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Color(0xFF4A90E2),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// LOGO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "FLEXIO",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Color(0xFF4A90E2),
                  ),
                ),
                Row(
                  children: const [
                    Icon(Icons.notifications_none_rounded, size: 26),
                    SizedBox(width: 18),
                    Icon(Icons.settings_outlined, size: 26),
                  ],
                )
              ],
            ),

            const SizedBox(height: 24),

            /// GREETING
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Good Morning, $userName 👋",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1F2E),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Let's continue your recovery!",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF7A8194),
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF4A90E2).withOpacity(0.1),
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'P',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// EMERGENCY CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF5B5B), Color(0xFFE53935)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33E53935),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone, color: Colors.white, size: 22),
                      SizedBox(width: 8),
                      Text(
                        "Emergency Call",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  SizedBox(height: 3),
                  Text(
                    "Contact emergency support",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// TODAY EXERCISE CARD
            // (UNCHANGED — your full existing exercise card remains here exactly as you wrote it)

            /// TODAY EXERCISE CARD
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (todayExercises.isNotEmpty)
              ...todayExercises.map((exercise) {
                final double progressValue = (exercise['repsCompleted'] ?? 0) /
                    (exercise['repsTotal'] ?? 1);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: const Color(0xFFF4F7FC),
                    ),
                    child: Column(
                      children: [
                        /// TOP SECTION
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFF6F9FF), Color(0xFFEAF1FB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Today's Exercise",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF7A8194),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                exercise['title'] ?? 'Unknown Exercise',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1C1F2E),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text.rich(
                                              TextSpan(
                                                text: "Estimated Time: ",
                                                style: const TextStyle(
                                                  color: Color(0xFF7A8194),
                                                  fontSize: 13,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        "${exercise['estimatedTimeMin'] ?? 0}",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF1C1F2E),
                                                    ),
                                                  ),
                                                  const TextSpan(text: " min"),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Text(
                                              "Progress: ${exercise['repsCompleted'] ?? 0} / ${exercise['repsTotal'] ?? 0} reps",
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF7A8194),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: LinearProgressIndicator(
                                                  value: progressValue,
                                                  minHeight: 6,
                                                  backgroundColor:
                                                      const Color(0xFFE6ECF8),
                                                  color:
                                                      const Color(0xFFBFD3F2),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const StartExerciseScreen(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 26, vertical: 14),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF5C9DED),
                                            Color(0xFF4A90E2),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x334A90E2),
                                            blurRadius: 12,
                                            offset: Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.play_arrow,
                                              color: Colors.white, size: 20),
                                          SizedBox(width: 6),
                                          Text(
                                            "Start Now",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
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

                        /// BOTTOM FEELING SECTION
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEFF3FA),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(24),
                            ),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: const [
                                Text(
                                  "How are you feeling today?",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1C1F2E),
                                  ),
                                ),
                                SizedBox(width: 12),
                                _FeelingChip(
                                  label: "Low",
                                  emoji: "🙂",
                                  color: Color(0xFFE7F5EC),
                                ),
                                SizedBox(width: 8),
                                _FeelingChip(
                                  label: "Moderate",
                                  emoji: "😊",
                                  color: Color(0xFFFFF3E0),
                                ),
                                SizedBox(width: 8),
                                _FeelingChip(
                                  label: "High",
                                  emoji: "😣",
                                  color: Color(0xFFFDEAEA),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              })
            else
              Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text("No exercises assigned for today.",
                      style: TextStyle(color: Colors.grey))),

            const SizedBox(height: 24),

            /// REMINDERS CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.notifications_rounded,
                          color: Color(0xFFFFC107), size: 22),
                      SizedBox(width: 10),
                      Text(
                        "Reminders",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios,
                          size: 16, color: Color(0xFF7A8194)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (reminders.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F7FC),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: reminders.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final reminder = entry.value;
                          final isLast = idx == reminders.length - 1;

                          IconData iconData = Icons.medication_rounded;
                          Color iconColor = Colors.orange;

                          if (reminder['type'] == 'therapy') {
                            iconData = Icons.ac_unit;
                            iconColor = Colors.blue;
                          } else if (reminder['type'] == 'general') {
                            iconData = Icons.water_drop;
                            iconColor = Colors.lightBlue;
                          }

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4A90E2),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(iconData, color: iconColor),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        reminder['text'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF1C1F2E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast)
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFE3E9F4),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    )
                  else
                    const Center(
                        child: Text("No reminders for now.",
                            style: TextStyle(color: Colors.grey))),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ================= RECOVERY PLAN =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.calendar_month_rounded,
                          color: Color(0xFF4A90E2), size: 22),
                      SizedBox(width: 10),
                      Text(
                        "My Recovery Plan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1F2E),
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios,
                          size: 16, color: Color(0xFF7A8194)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (nextAppointment != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF3F6FD), Color(0xFFEAF0FB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE0EBFA),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.calendar_today_rounded,
                                            color: Color(0xFF4A90E2),
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                nextAppointment?['date'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1C1F2E),
                                                ),
                                              ),
                                              Text(
                                                nextAppointment?['time'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF7A8194),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8F1FF),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Text(
                                            "Next Appointment",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF4A90E2),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "${nextAppointment?['type'] ?? 'Consultation'} with ${nextAppointment?['doctorName'] ?? 'Doctor'}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF7A8194),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 9),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6FA8F6),
                                      Color(0xFF4A90E2)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: const Text(
                                  "View Details",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    const Center(
                        child: Text('No upcoming appointments',
                            style: TextStyle(color: Colors.grey))),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ================= YOUR IMPROVEMENT =================
            _whiteCard(
              child: Row(
                children: const [
                  Icon(Icons.bar_chart_rounded, color: Color(0xFF4A90E2)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Your Improvement",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ================= BOOK APPOINTMENT =================
            _whiteCard(
              child: Row(
                children: const [
                  Icon(Icons.event_available_rounded, color: Color(0xFF4CAF50)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Book Appointment",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Schedule a new appointment with your doctor",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7A8194),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ================= FIND DOCTOR =================
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FindDoctorScreen(),
                  ),
                );
              },
              child: _whiteCard(
                child: Row(
                  children: const [
                    Icon(Icons.search_rounded, color: Color(0xFF4A90E2)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Find Your Doctor",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Search and connect with your physical therapist",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF7A8194),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// ================= REPORT WOUND =================
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportWoundScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFF2F2),
                      Color(0xFFFDEAEA),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Color(0xFFE53935),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1AE53935),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.camera_alt_rounded, color: Color(0xFFE53935)),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Report Wound",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE53935),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Track healing & symptoms",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF7A8194),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        color: Color(0xFFE53935), size: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _whiteCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: child,
    );
  }
}

class _FeelingChip extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;

  const _FeelingChip({
    required this.label,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(emoji),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
