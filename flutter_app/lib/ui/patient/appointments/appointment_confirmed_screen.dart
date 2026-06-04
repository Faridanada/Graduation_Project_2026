import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/api_service.dart';

class AppointmentConfirmedScreen extends StatefulWidget {
  final String date;
  final String time;

  const AppointmentConfirmedScreen({
    super.key,
    required this.date,
    required this.time,
  });

  @override
  State<AppointmentConfirmedScreen> createState() =>
      _AppointmentConfirmedScreenState();
}

class _AppointmentConfirmedScreenState
    extends State<AppointmentConfirmedScreen> {
  bool reminderSet = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEAF2FF), Color(0xFFF6F9FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                /// 🔙 Back
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () { if (Navigator.canPop(context)) Navigator.pop(context); },
                  ),
                ),

                const SizedBox(height: 20),

                /// ✅ Check icon
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6EDC6E), Color(0xFF3CB371)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 50),
                ),

                const SizedBox(height: 20),

                /// 🧠 Title
                const Text(
                  "Appointment Confirmed",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Color(0xFF1E2A3A),
                  ),
                ),

                const SizedBox(height: 30),

                /// 📦 Appointment Card
                _glassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "In-Clinic Session",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Text(
                        widget.date,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 20,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.time,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// 📦 Actions Card
                _glassCard(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  child: Column(
                    children: [
                      /// 🔔 Reminder Button
                      GestureDetector(
                        onTap: () async {
                          if (reminderSet) return;

                          final success = await ApiService.createReminder(
                            "Appointment on ${widget.date} at ${widget.time}",
                            "general",
                          );

                          if (success && mounted) {
                            setState(() {
                              reminderSet = true;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Reminder set successfully ✅"),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Failed to set reminder ❌"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            Icon(
                              reminderSet
                                  ? Icons.check_circle
                                  : Icons.notifications_none,
                              color:
                                  reminderSet ? Colors.green : Colors.black87,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              reminderSet ? "Reminder Set" : "Set a Reminder",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color:
                                    reminderSet ? Colors.green : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),

                      /// 🏠 Back Home
                      GestureDetector(
                        onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
                        child: Row(
                          children: const [
                            Icon(Icons.home_outlined),
                            SizedBox(width: 10),
                            Text("Back to Home"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🌟 Glass Card Widget
  Widget _glassCard({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

