import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/ui/auth/login.dart';
import 'package:rehabilitation_app/ui/settings/PersonalInformationPage.dart';
import 'package:rehabilitation_app/ui/doctor/profile/MedicalLicensePage.dart';
import 'package:rehabilitation_app/ui/doctor/profile/SpecializationPage.dart';
import 'package:rehabilitation_app/ui/doctor/management/AvailabilityPage.dart';
import 'package:rehabilitation_app/ui/auth/ChangePasswordPage.dart';
import 'package:rehabilitation_app/ui/chats/Chats.dart';

class DoctorProfile extends StatefulWidget {
  final String source; // 'home' or 'settings'

  const DoctorProfile({Key? key, this.source = 'home'}) : super(key: key);

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  bool isLoading = true;
  Map<String, dynamic> userProfile = {};
  Map<String, dynamic> doctorStats = {};
  int _selectedNavIndex = 2; // Profile is index 2

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final profile = await ApiService.getUserProfile() ?? {};
      final stats = await ApiService.getDoctorStats();

      if (mounted) {
        setState(() {
          userProfile = profile;
          doctorStats = stats;
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with gradient
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF6BA5CF),
                      Color(0xFF9B8FD9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              if (widget.source == 'settings') {
                                if (Navigator.canPop(context)) Navigator.pop(context);
                              } else {
                                if (Navigator.canPop(context)) Navigator.pop(context);
                              }
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Profile Info Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          // Profile Picture
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Color(0xFF6BA5CF),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Profile Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userProfile['name'] ?? 'Loading...',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  (userProfile['role'] ?? '')
                                      .toString()
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userProfile['email'] ?? '',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Menu Items Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.badge_outlined,
                      title: 'Personal Information',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PersonalInformationPage()),
                        );
                      },
                      isFirst: true,
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      context,
                      icon: Icons.medical_information_outlined,
                      title: 'Medical License & Credentials',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MedicalLicensePage()),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      context,
                      icon: Icons.work_outline,
                      title: 'Specialization',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SpecializationPage()),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      context,
                      icon: Icons.calendar_month_outlined,
                      title: 'Availability & Schedule',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AvailabilityPage()),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      context,
                      icon: Icons.lock_reset,
                      title: 'Change Password',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ChangePasswordPage()),
                        );
                      },
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Statistics Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white))
                          : _buildStatCard(
                              '${doctorStats['activePatients'] ?? 0}',
                              'Active Patients'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white))
                          : _buildStatCard(
                              '${doctorStats['todaySessions'] ?? 0}',
                              'Total Sessions'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('-', 'Success Rate'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Log Out Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  onTap: () {
                    _showLogoutDialog();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.logout,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Log Out',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedNavIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF6BA5CF),
      unselectedItemColor: Colors.grey[400],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        if (index == 2) return;
        if (index == 0) {
          Navigator.popUntil(context, (route) => route.isFirst);
          return;
        }
        if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Chats()),
          );
          return;
        }
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF6BA5CF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF6BA5CF),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Colors.grey[200]),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 0),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await ApiService.clearToken();
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
