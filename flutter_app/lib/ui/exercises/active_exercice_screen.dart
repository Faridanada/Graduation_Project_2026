import 'package:flutter/material.dart';
import 'package:rehabilitation_app/ui/exercises/live_exercise_screen.dart';
import 'package:rehabilitation_app/ui/chats/Chats.dart';
import 'package:rehabilitation_app/ui/patient/home/patient_bottom_nav.dart';
import 'package:rehabilitation_app/services/api_service.dart';

class ActiveExerciseScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const ActiveExerciseScreen({super.key, required this.exercise});

  static const Color primaryBlue = Color(0xFF2196F3);

  @override
  State<ActiveExerciseScreen> createState() => _ActiveExerciseScreenState();
}

class _ActiveExerciseScreenState extends State<ActiveExerciseScreen> {
  Map<String, dynamic>? doctorProfile;
  bool isLoadingDoctor = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctor();
  }

  Future<void> _fetchDoctor() async {
    try {
      final data = await ApiService.getMyDoctor();
      if (mounted) {
        setState(() {
          doctorProfile = data;
          isLoadingDoctor = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => isLoadingDoctor = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.exercise['exerciseType'] ?? 'Exercise';
    final title = widget.exercise['title'] ?? '$type Session';
    final int numEx = widget.exercise['numberOfExercises'] as int? ?? 0;
    final int numReps = widget.exercise['numberOfReps'] as int? ?? 0;
    final int? reps = (numEx * numReps) > 0 ? (numEx * numReps) : null;
    final dynamic minAngleRaw = widget.exercise['minAngle'];
    final dynamic maxAngleRaw = widget.exercise['maxAngle'];
    final int? minAngle = minAngleRaw != null ? int.tryParse(minAngleRaw.toString()) : null;
    final int? maxAngle = maxAngleRaw != null ? int.tryParse(maxAngleRaw.toString()) : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 10),

                /// HEADER
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        }
                      },
                      child: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Start $type Exercise',
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),                const SizedBox(height: 32),
                const SizedBox(height: 16),



                /// OVERVIEW
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.fitness_center,
                              color: ActiveExerciseScreen.primaryBlue, size: 18),
                          SizedBox(width: 8),
                          Text('Exercise Overview',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (reps != null)
                            _OverviewItem(
                              icon: Icons.sync,
                              title: 'Reps',
                              value: '$reps total',
                            ),
                          if (minAngle != null && maxAngle != null) ...[
                            if (reps != null) const _Divider(),
                            _OverviewItem(
                              icon: Icons.straighten,
                              title: 'Range',
                              value: '$minAngle° - $maxAngle°',
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// BEFORE START
                _card(
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.orange, size: 18),
                          SizedBox(width: 8),
                          Text('Before you start',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 10),
                      _CheckItem('Make sure you are on a flat surface'),
                      _CheckItem('Wear comfortable clothes'),
                      _CheckItem('Stop if you feel pain'),
                      _CheckItem('Keep breathing normally'),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                /// BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ActiveExerciseScreen.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => LiveSessionScreen(exercise: widget.exercise)),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow),
                        const SizedBox(width: 8),
                        Text('Start $type Session',
                            style: const TextStyle(fontSize: 16)),
                      ],
                    ),
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

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _OverviewItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _OverviewItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2196F3);
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryBlue, size: 18),
          ),
          const SizedBox(height: 6),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.grey.shade300,
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String text;
  const _CheckItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
