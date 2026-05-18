import 'package:flutter/material.dart';
import 'live_session_screen.dart';

class StartExerciseScreen extends StatelessWidget {
  /// Optional exercise data from the API. If null, generic defaults are shown.
  final Map<String, dynamic>? exercise;

  const StartExerciseScreen({super.key, this.exercise});

  static const Color _blue = Color(0xFF2196F3);

  @override
  Widget build(BuildContext context) {
    final String title = exercise?['title'] ?? 'Exercise Session';
    final String description = exercise?['description'] ?? 'Follow the guided steps to complete your session safely.';
    final int durationMin = exercise?['estimatedTimeMin'] ?? 10;
    final int reps = exercise?['repsTotal'] ?? 0;
    final String repsLabel = reps > 0 ? '$reps reps' : 'As assigned';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: SafeArea(
        child: Column(
          children: [
            /// TOP BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, size: 20),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Start Exercise',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'FLEXIO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _blue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/images/Exercise.png',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _InfoCard(
                                  icon: Icons.access_time,
                                  title: 'Duration',
                                  value: '$durationMin min',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _InfoCard(
                                  icon: Icons.fitness_center,
                                  title: 'Reps',
                                  value: repsLabel,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Before you start:',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    const _Bullet('Find a flat, safe surface'),
                    const _Bullet('Stop immediately if you feel pain'),
                    const _Bullet('Breathe normally throughout'),
                  ],
                ),
              ),
            ),

            /// START BUTTON
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LiveSessionScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Start Session',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: Color(0xFF2196F3)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12)),
              Text(value,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              size: 16, color: Color(0xFF2196F3)),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
