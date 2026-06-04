import 'package:flutter/material.dart';

import 'package:rehabilitation_app/ui/exercises/session_summary_screen.dart';

class LiveSessionScreen extends StatefulWidget {
  const LiveSessionScreen({super.key});

  @override
  State<LiveSessionScreen> createState() => _LiveSessionScreenState();
}

class _LiveSessionScreenState extends State<LiveSessionScreen> {
  static const Color primaryBlue = Color(0xFF4A90E2);

  bool isPaused = false;

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// ICON
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.pause, size: 32, color: primaryBlue),
                  ),

                  const SizedBox(height: 16),

                  const Text("Session Paused",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 8),

                  const Text(
                    "The device has stopped safely.\nTake your time. You can resume when you are ready.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

                  /// RESUME
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) Navigator.pop(context);
                      setState(() => isPaused = false);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow, color: Colors.white),
                          SizedBox(width: 6),
                          Text("Resume Session",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// END
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.stop, color: Colors.red),
                        SizedBox(width: 6),
                        Text("End Session",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),

                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    const Text("Active Live Session",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Icon(Icons.settings),
                  ],
                ),

                const SizedBox(height: 8),

                /// MONITORED
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 14, color: Colors.green),
                      SizedBox(width: 4),
                      Text("Monitored by Doctor",
                          style: TextStyle(color: Colors.green, fontSize: 12)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// RING
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 180,
                      width: 180,
                      child: CircularProgressIndicator(
                        value: 0.82,
                        strokeWidth: 14,
                        strokeCap: StrokeCap.round,
                        color: primaryBlue,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                    Column(
                      children: [
                        const Text("08:24",
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text("of 10:00",
                            style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 6),
                        Icon(
                          isPaused ? Icons.play_arrow : Icons.pause,
                          size: 18,
                        ),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 16),

                const Text("Lift your left knee",
                    style: TextStyle(
                        color: primaryBlue, fontWeight: FontWeight.bold)),

                const SizedBox(height: 6),

                const Text("Follow the guidance and move slowly.",
                    style: TextStyle(color: Colors.grey)),

                const SizedBox(height: 16),

                /// IMAGE
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Image.asset("assets/images/activeexercise.png"),
                      const SizedBox(height: 8),
                      const Text("78°",
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                /// ===== STATS GRID (UNCHANGED) =====
                Row(
                  children: [
                    Expanded(
                        child: _statCard(
                      icon: Icons.refresh,
                      iconColor: Colors.green,
                      title: "Reps",
                      value: "5 / 12",
                      bottom: Row(
                        children: List.generate(
                          6,
                          (i) => Container(
                            margin: const EdgeInsets.only(right: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  i < 3 ? Colors.green : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _statCard(
                      icon: Icons.fitness_center,
                      iconColor: primaryBlue,
                      title: "Sets",
                      value: "1 / 3",
                      bottom: LinearProgressIndicator(
                        value: 0.33,
                        color: primaryBlue,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    )),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                        child: _statCard(
                      icon: Icons.favorite,
                      iconColor: Colors.red,
                      title: "Heart Rate",
                      value: "132 bpm",
                      valueColor: Colors.red,
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _statCard(
                      icon: Icons.autorenew,
                      iconColor: Colors.green,
                      title: "Recovery Score",
                      value: "84%",
                      valueColor: Colors.green,
                    )),
                  ],
                ),

                const SizedBox(height: 14),

                /// MESSAGE
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                  text: "Good job! Keep ",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: "going",
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: ".\n\nTry to lift a little higher."),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                /// ===== BUTTONS (UPDATED) =====
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!isPaused) {
                            setState(() => isPaused = true);
                            _showPauseDialog();
                          } else {
                            setState(() => isPaused = false);
                          }
                        },
                        child: _button(
                          isPaused ? "Resume" : "Pause",
                          isPaused ? Icons.play_arrow : Icons.pause,
                          primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SessionSummaryScreen(),
                            ),
                          );
                        },
                        child: _button("End Session", Icons.stop, Colors.red),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _button("Report", Icons.warning, Colors.grey)),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    Widget? bottom,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Colors.black)),
          if (bottom != null) ...[
            const SizedBox(height: 8),
            bottom,
          ]
        ],
      ),
    );
  }

  Widget _button(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text,
              style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
