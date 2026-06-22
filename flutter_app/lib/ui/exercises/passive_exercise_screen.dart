import 'package:flutter/material.dart';

import 'package:rehabilitation_app/ui/exercises/passive_live_session_screen.dart';

class PassiveExerciseScreen extends StatefulWidget {
  const PassiveExerciseScreen({super.key});

  @override
  State<PassiveExerciseScreen> createState() =>
      _PassiveExerciseScreenState();
}

class _PassiveExerciseScreenState
    extends State<PassiveExerciseScreen> {
  static const Color primaryBlue = Color(0xFF4A90E2);

  double rangeValue = 60;
  String speed = "Normal";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text("Start Passive Exercise",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const Text("FLEXIO",
                      style: TextStyle(
                          color: primaryBlue,
                          fontWeight: FontWeight.bold)),
                ],
              ),

              const SizedBox(height: 16),

              /// MAIN CARD (FIXED)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _card(),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Knee Flexion – Passive Mode",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Device will move your leg for you.",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                    /// FIXED IMAGE SIZE
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        "assets/images/passiveexercise.png", // FIXED
                        height: 90,
                        width: 90,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              /// STATUS CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _card(),
                child: Row(
                  children: [
                    const Icon(Icons.memory, size: 28),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: const [
                        Text("Exoskeleton Status",
                            style: TextStyle(
                                fontWeight:
                                    FontWeight.bold)),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text("Connected",
                                style: TextStyle(
                                    color:
                                        Colors.green)),
                            SizedBox(width: 6),
                            Icon(Icons.check_circle,
                                color: Colors.green,
                                size: 16),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text("Battery: 92%",
                            style: TextStyle(
                                color: Colors.grey)),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 14),

              /// ABOUT
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _card(),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.info,
                            color: primaryBlue),
                        SizedBox(width: 6),
                        Text("About Passive Mode",
                            style: TextStyle(
                                fontWeight:
                                    FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _check("The device will guide your leg movement."),
                    _check("Relax your muscles and let the device work."),
                    _check("Stop if you feel discomfort."),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              /// SETTINGS
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _card(),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    const Text("Settings",
                        style: TextStyle(
                            fontWeight: FontWeight.bold)),

                    const SizedBox(height: 14),

                    /// SPEED
                    Row(
                      children: [
                        const Icon(Icons.speed,
                            color: primaryBlue),
                        const SizedBox(width: 8),
                        const Expanded(
                            child: Text(
                                "Movement Speed")),
                        _speed("Slow"),
                        _speed("Normal"),
                        _speed("Fast"),
                      ],
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Adjust how fast the device moves",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12),
                    ),

                    const SizedBox(height: 16),

                    /// RANGE
                    Row(
                      children: const [
                        Icon(Icons.timeline,
                            color: primaryBlue),
                        SizedBox(width: 8),
                        Text("Range of Motion"),
                      ],
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Set the comfortable range for you",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12),
                    ),

                    Row(
                      children: [
                        const Text("30°"),
                        Expanded(
                          child: Slider(
                            value: rangeValue,
                            min: 30,
                            max: 90,
                            activeColor: primaryBlue,
                            onChanged: (v) =>
                                setState(() =>
                                    rangeValue = v),
                          ),
                        ),
                        const Text("90°"),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// BUTTON
              GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PassiveLiveSessionScreen(),
      ),
    );
  },
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(
      color: primaryBlue, // keep your blue gradient if you used one
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.play_arrow, color: Colors.white),
        SizedBox(width: 8),
        Text(
          "Start Passive Session",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
),
              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "You are in safe hands. We're monitoring you.",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// UI HELPERS
  BoxDecoration _card() => BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      );

  Widget _check(String text) => Padding(
        padding:
            const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            const Icon(Icons.check,
                color: Colors.green, size: 18),
            const SizedBox(width: 6),
            Expanded(child: Text(text)),
          ],
        ),
      );

  Widget _speed(String label) {
    final selected = speed == label;
    return GestureDetector(
      onTap: () =>
          setState(() => speed = label),
      child: Container(
        margin:
            const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? primaryBlue
              : primaryBlue.withOpacity(0.1),
          borderRadius:
              BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected
                    ? Colors.white
                    : primaryBlue,
                fontSize: 12)),
      ),
    );
  }
}