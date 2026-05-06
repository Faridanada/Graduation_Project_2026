import 'package:flutter/material.dart';

class PassiveLiveSessionScreen extends StatefulWidget {
  const PassiveLiveSessionScreen({super.key});

  @override
  State<PassiveLiveSessionScreen> createState() =>
      _PassiveLiveSessionScreenState();
}

class _PassiveLiveSessionScreenState
    extends State<PassiveLiveSessionScreen> {
  static const Color primaryBlue = Color(0xFF4A90E2);

  bool isPaused = false;
  bool isStopped = false;
  bool isEmergencyStopped = false;

  double progress = 0.64;
  String time = "06:24";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 10),

                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Icon(Icons.arrow_back),
                    Text("Passive Live Session",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Icon(Icons.settings),
                  ],
                ),

                const SizedBox(height: 10),

                /// TAGS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _chip("PASSIVE MODE", primaryBlue),
                    _chip("Device Connected", Colors.green,
                        icon: Icons.wifi),
                  ],
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
                        value: progress,
                        strokeWidth: 14,
                        strokeCap: StrokeCap.round,
                        color: primaryBlue,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                    Column(
                      children: [
                        Text(time,
                            style: const TextStyle(
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

                const SizedBox(height: 18),

                const Text("Device moving your leg",
                    style: TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),

                const SizedBox(height: 6),

                const Text("Please relax and breathe normally.",
                    style: TextStyle(color: Colors.grey)),

                const SizedBox(height: 16),

                /// IMAGE
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Image.asset("assets/exercise2.png", height: 120),
                      const SizedBox(height: 8),
                      /*const Text("60°",
                          style: TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),*/
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                /// GRID
                Row(
                  children: [
                    Expanded(
                        child: _statCard(Icons.straighten,
                            "Range Completed", "60° / 90°", "67%")),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _progressCard(
                            Icons.show_chart, "Session Progress", progress)),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                        child: _statCard(
                            Icons.loop, "Movement Cycles", "10 / 15", "Cycles")),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _statCard(Icons.favorite,
                            "Muscle Relaxation", "Good", "Keep relaxing",
                            valueColor: Colors.green)),
                  ],
                ),

                const SizedBox(height: 14),

                /// TIP
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lightbulb, color: primaryBlue, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Tip: Stay relaxed and let the device guide you.",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                /// BUTTONS
                Row(
                  children: [
                    Expanded(
                        child: _button(
                            "Pause", Icons.pause, primaryBlue, _pause)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _button(
                            "Stop", Icons.stop, Colors.red, _stopSession)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _button("Emergency",
                            Icons.warning, Colors.red, _emergencyStop)),
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

  /// CHIP
  Widget _chip(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(text,
              style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  /// CARD
  Widget _statCard(
      IconData icon, String title, String value, String sub,
      {Color? valueColor}) {
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
              Icon(icon, color: primaryBlue, size: 18),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Colors.black)),
          Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  /// PROGRESS
  Widget _progressCard(IconData icon, String title, double progress) {
    return _statCard(icon, title, "${(progress * 100).toInt()}%", "",
        valueColor: Colors.black);
  }

  /// BUTTON
  Widget _button(
      String text, IconData icon, Color color, VoidCallback onTap) {
    final disabled = isEmergencyStopped;

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Opacity(
        opacity: disabled ? 0.4 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(text,
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  /// PAUSE
  void _pause() {
    setState(() => isPaused = true);
    _showPauseDialog();
  }

  /// STOP
  void _stopSession() {
    _showStopDialog();
  }

  /// EMERGENCY
  void _emergencyStop() {
    setState(() {
      isEmergencyStopped = true;
      isPaused = false;
    });
    _showEmergencyDialog();
  }

  /// PAUSE DIALOG
  void _showPauseDialog() {
    showDialog(
      context: context,
      builder: (_) => _dialog("Session Paused", "Resume Session", () {
        Navigator.pop(context);
        setState(() => isPaused = false);
      }),
    );
  }

  /// STOP DIALOG
  void _showStopDialog() {
    showDialog(
      context: context,
      builder: (_) => _dialog("Session Stopped", "Restart Session", () {
        Navigator.pop(context);
        setState(() {
          progress = 0;
          time = "00:00";
        });
      }),
    );
  }

  /// EMERGENCY DIALOG
  void _showEmergencyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.warning, color: Colors.red, size: 36),
              ),
              const SizedBox(height: 14),
              const Text("Emergency Stop Activated",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              const Text(
                "The session has been stopped immediately.\n\nYour doctor has been alerted.\nPlease wait for instructions.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text("Understood",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// SHARED DIALOG
  Widget _dialog(String title, String buttonText, VoidCallback onTap) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pause, size: 40, color: primaryBlue),
            const SizedBox(height: 10),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            const Text("Take your time."),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(buttonText,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}