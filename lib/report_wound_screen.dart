import 'package:flutter/material.dart';

class ReportWoundScreen extends StatefulWidget {
  const ReportWoundScreen({super.key});

  @override
  State<ReportWoundScreen> createState() => _ReportWoundScreenState();
}

class _ReportWoundScreenState extends State<ReportWoundScreen> {
  String selectedPain = "Medium";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FB), // different from cards
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              /// ================= HEADER =================
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back_ios, size: 18),
                  ),
                  const Spacer(),
                  const Text(
                    "Report Wound",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: const [
                      Icon(Icons.notifications_none_rounded),
                      SizedBox(width: 16),
                      Icon(Icons.settings_outlined),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 30),

              /// ================= UPLOAD =================
              const Text(
                "Upload Photos",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color(0xFFD6DEEA),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EEF8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 28,
                        color: Color(0xFF4A90E2),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined,
                            size: 18, color: Color(0xFF7A8194)),
                        SizedBox(width: 6),
                        Text(
                          "Take or upload wound photos",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7A8194),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 28),

              /// ================= WOUND AREA =================
              const Text(
                "Wound Area",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    CircleAvatar(
                      backgroundColor: Color(0xFFE8EEF8),
                      child:
                          Icon(Icons.circle_outlined, color: Color(0xFF4A90E2)),
                    ),
                    SizedBox(width: 14),
                    Text(
                      "Knee",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.keyboard_arrow_down, color: Color(0xFF4A90E2)),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              /// ================= PAIN LEVEL =================
              const Text(
                "Pain Level",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  _painOption("Low", Colors.teal),
                  const SizedBox(width: 12),
                  _painOption("Medium", Colors.orange),
                  const SizedBox(width: 12),
                  _painOption("High", Colors.red),
                ],
              ),

              const SizedBox(height: 28),

              /// ================= DESCRIPTION =================
              const Text(
                "Description",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Slight redness and swelling today.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1C1F2E),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Row(
                children: [
                  Icon(Icons.note_alt_outlined, color: Color(0xFF4A90E2)),
                  SizedBox(width: 6),
                  Text(
                    "Add Notes (Optional)",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4A90E2),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// ================= SUBMIT BUTTON =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6FA8F6),
                      Color(0xFF4A90E2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x334A90E2),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      "Submit Report",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _painOption(String label, Color color) {
    final bool isSelected = selectedPain == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPain = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
