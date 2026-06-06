import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:rehabilitation_app/ui/app_theme.dart';
import 'package:rehabilitation_app/ui/exercises/session_completed_screen.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/ui/shared/NotificationsPage.dart';
import 'package:rehabilitation_app/ui/settings/SettingsPage.dart';
import 'package:rehabilitation_app/ui/patient/home/patient_bottom_nav.dart';

class RealTimeDataScreen extends StatefulWidget {
  const RealTimeDataScreen({super.key});

  @override
  State<RealTimeDataScreen> createState() => _RealTimeDataScreenState();
}

class _RealTimeDataScreenState extends State<RealTimeDataScreen> {
  bool isPaused = false;
  bool isLoading = true;

  double recoveryScore = 0.0;

  String exerciseTitle = "No Active Session";
  int repsTotal = 0;
  int repsCompleted = 0;
  int unreadNotifs = 0;

  @override
  void initState() {
    super.initState();
    _fetchSessionData();
  }

  Future<void> _fetchSessionData() async {
    try {
      final stats = await ApiService.getPatientDashboardStats();
      final exercises = await ApiService.getPatientExercises();

      if (mounted) {
        setState(() {
          if (stats['exerciseStats'] != null) {
            int total = stats['exerciseStats']['total'] ?? 0;
            int comp = stats['exerciseStats']['completed'] ?? 0;
            if (total > 0) recoveryScore = comp / total;
          }

          if (exercises.isNotEmpty) {
            final latest = exercises[0];
            exerciseTitle = latest['title'] ?? 'Exercise';
            repsTotal = latest['repsTotal'] ?? 20;
            repsCompleted = latest['repsCompleted'] ?? 0;
          }

          unreadNotifs = stats['unreadNotifications'] ?? 0;
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        ),
        title: const Text(
          "Real-Time Data",
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: unreadNotifs > 0,
              label: Text('$unreadNotifs'),
              child: const Icon(Icons.notifications_outlined, color: Colors.black),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              ).then((_) => _fetchSessionData());
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              const SizedBox(height: 10),

              /// EXERCISE OVERVIEW CARD
              _exerciseOverviewCard(),

              if (isPaused) _pausedBanner(),

              const SizedBox(height: 20),

              /// RECOVERY SCORE CARD
              _recoveryScoreCard(),

              const SizedBox(height: 16),

              /// GRID STATS
              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      Icons.fitness_center,
                      "Reps",
                      isLoading ? "..." : "$repsCompleted / $repsTotal",
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _infoCard(
                      Icons.track_changes,
                      "Accuracy",
                      "--%",
                      AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      Icons.sentiment_satisfied,
                      "Pain Level",
                      "-- / 10",
                      Colors.orange, // Keep a semantic color for pain
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _infoCard(
                      Icons.speed,
                      "ROM",
                      "--°",
                      AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Center(
                child: Text(
                  "More metrics will be available once sensors are connected.",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 30),

              if (!isLoading && repsTotal > 0)
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        isPaused ? "Resume" : "Pause",
                        isPaused ? Colors.green : AppColors.primary,
                        isPaused ? Icons.play_arrow : Icons.pause,
                        () {
                          setState(() => isPaused = !isPaused);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _actionButton(
                        "End",
                        Colors.redAccent,
                        Icons.stop,
                        () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SessionCompletedScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const PatientBottomNavBar(currentIndex: 0),
    );
  }

  /// ================= COMPONENTS =================

  Widget _exerciseOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Current Session",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              if (repsTotal > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPaused
                        ? Colors.orange.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPaused ? Icons.pause : Icons.circle,
                        size: 8,
                        color: isPaused ? Colors.orange : AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isPaused ? "PAUSED" : "LIVE",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isPaused ? Colors.orange : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isLoading ? "Loading..." : exerciseTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: repsTotal > 0 ? (repsCompleted / repsTotal) : 0,
                    minHeight: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                repsTotal > 0
                    ? "${((repsCompleted / repsTotal) * 100).toInt()}%"
                    : "0%",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Progress: $repsCompleted out of $repsTotal reps",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pausedBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: const [
          Icon(Icons.pause_circle_filled, color: Colors.orange, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Session is paused.\nTake your time before resuming.",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recoveryScoreCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 40,
            lineWidth: 8,
            percent: recoveryScore,
            animation: true,
            progressColor: AppColors.success,
            backgroundColor: AppColors.success.withValues(alpha: 0.15),
            circularStrokeCap: CircularStrokeCap.round,
            center: Text(
              "${(recoveryScore * 100).toInt()}%",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Recovery Score",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Based on your recent session performance.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                if (repsTotal > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      recoveryScore > 0.7 ? "On Track" : "Needs Practice",
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    String text,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
