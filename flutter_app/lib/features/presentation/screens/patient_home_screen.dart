import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:rehabilitation_app/features/presentation/widgets/appointment_card.dart';
import 'package:rehabilitation_app/features/presentation/widgets/action_card.dart';
import 'chats_screen.dart';
import 'profile_screen.dart';
import 'package:rehabilitation_app/ui/patient/doctors/FindDoctorScreen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _HomeContent(),
    ChatsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              /// Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'FLEXIO',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.primaryBlue,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FindDoctorScreen(),
                            ),
                          );
                        },
                      ),
                      const Icon(Icons.notifications_none_rounded),
                      const SizedBox(width: 20),
                      const Icon(Icons.settings_outlined),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 30),

              /// Greeting
              const Text(
                'Good Morning, John 👋',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Let's get ready for your recovery!",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 30),

              const AppointmentCard(),

              const SizedBox(height: 25),

              /// Start Exercise Button
              Container(
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF5C9DED),
                      Color(0xFF4A90E2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x334A90E2),
                      blurRadius: 25,
                      offset: Offset(0, 12),
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Start Exercise',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const ActionCard(
                title: "Report Wound",
                icon: Icons.medical_services_outlined,
                iconBg: AppColors.lightBlue,
              ),

              const SizedBox(height: 20),

              const ActionCard(
                title: "Progress",
                icon: Icons.bar_chart_rounded,
                iconBg: AppColors.lightBlue,
              ),

              const SizedBox(height: 20),

              const ActionCard(
                title: "Emergency Call",
                icon: Icons.phone_rounded,
                iconBg: Colors.redAccent,
                isEmergency: true,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
