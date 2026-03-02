import 'package:flutter/material.dart';

class AiReports extends StatefulWidget {
  const AiReports({Key? key}) : super(key: key);

  @override
  State<AiReports> createState() => _AiReportsState();
}

class _AiReportsState extends State<AiReports> {
  String selectedFilter = 'Weekly';
  String? selectedPatient = 'John Doe';
  String selectedRisk = 'Low Risk'; // Will be updated based on selected patient

  final List<String> patients = [
    'John Doe',
    'Alice Smith',
    'Mark Lee',
    'Emma Brown'
  ];
  final List<String> timeframes = ['Weekly', 'Monthly', 'Custom'];
  final List<String> risks = ['Low Risk', 'Medium', 'High Risk'];

  // Patient-specific data: recovery score and risk level
  final Map<String, Map<String, dynamic>> patientData = {
    'John Doe': {
      'recoveryScore': '82%',
      'recoveryStatus': 'Patient recovery\nis on track',
      'riskLevel': 'Low Risk',
    },
    'Alice Smith': {
      'recoveryScore': '65%',
      'recoveryStatus': 'Patient needs\nmore attention',
      'riskLevel': 'Medium',
    },
    'Mark Lee': {
      'recoveryScore': '92%',
      'recoveryStatus': 'Excellent\nprogress',
      'riskLevel': 'Low Risk',
    },
    'Emma Brown': {
      'recoveryScore': '45%',
      'recoveryStatus': 'Critical\nattention required',
      'riskLevel': 'High Risk',
    },
  };

  final List<Map<String, dynamic>> weeklyProgress = [
    {
      'time': '09:00 AM',
      'name': 'John Doe',
      'service': 'Knee rehabilitation',
      'progress': '78%',
      'hasCheckmark': true,
    },
    {
      'time': '11:30 AM',
      'name': 'Alice Smith',
      'service': 'Wound check',
      'progress': '23%',
      'hasCheckmark': true,
    },
    {
      'time': '02:00 PM',
      'name': 'Mark Lee',
      'service': 'Shoulder therapy',
      'progress': '92%',
      'hasCheckmark': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filters & Selection
                _buildFiltersSection(),
                const SizedBox(height: 24),

                // Risk Assessment
                _buildRiskAssessment(),
                const SizedBox(height: 24),

                // Recovery Score Card
                _buildRecoveryScoreCard(),
                const SizedBox(height: 32),

                // Weekly Progress Section
                _buildWeeklyProgressSection(),
                const SizedBox(height: 32),

                // Action Buttons
                _buildActionButtons(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF95B8D1),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: const Text(
        'AI Reports',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Patient Selection Label
        const Text(
          'Select Patient',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        // Patient Selection Dropdown
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedPatient,
              isExpanded: true,
              icon: const Icon(Icons.expand_more, color: Colors.grey),
              items: patients.map((patient) {
                return DropdownMenuItem<String>(
                  value: patient,
                  child: Text(
                    patient,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: 'Poppins',
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPatient = value;
                  // Update risk level based on selected patient
                  if (value != null && patientData.containsKey(value)) {
                    selectedRisk = patientData[value]!['riskLevel'];
                  }
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Timeframe Filters
        Row(
          children: [
            _buildFilterButton('Weekly', selectedFilter == 'Weekly'),
            const SizedBox(width: 12),
            _buildFilterButton('Monthly', selectedFilter == 'Monthly'),
            const SizedBox(width: 12),
            _buildFilterButton('Custom', selectedFilter == 'Custom'),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5798C6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _buildRiskAssessment() {
    // Get current patient's risk level
    String currentRisk =
        selectedPatient != null && patientData.containsKey(selectedPatient)
            ? patientData[selectedPatient]!['riskLevel']
            : 'Low Risk';

    return Row(
      children: [
        _buildRiskBadge('Low Risk', currentRisk == 'Low Risk',
            const Color.fromARGB(255, 99, 197, 150), Icons.check_circle),
        const SizedBox(width: 12),
        _buildRiskBadge('Medium', currentRisk == 'Medium',
            const Color.fromARGB(255, 255, 165, 0), Icons.circle_outlined),
        const SizedBox(width: 12),
        _buildRiskBadge('High Risk', currentRisk == 'High Risk',
            const Color.fromARGB(255, 239, 68, 68), Icons.warning),
      ],
    );
  }

  Widget _buildRiskBadge(
      String label, bool isSelected, Color activeColor, IconData icon) {
    Color displayColor = isSelected ? activeColor : Colors.grey[400]!;
    IconData displayIcon = isSelected ? icon : Icons.circle_outlined;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRisk = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(displayIcon, size: 16, color: displayColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: displayColor,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoveryScoreCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recovery Score',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score Percentage
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedPatient != null &&
                            patientData.containsKey(selectedPatient)
                        ? patientData[selectedPatient]!['recoveryScore']
                        : '82%',
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedPatient != null &&
                            patientData.containsKey(selectedPatient)
                        ? patientData[selectedPatient]!['recoveryStatus']
                        : 'Patient recovery\nis on track',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 32),
              // Line Chart
              Expanded(
                child: _buildLineChart(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Chart area
        SizedBox(
          height: 80,
          child: CustomPaint(
            painter: LineChartPainter(),
            size: const Size(double.infinity, 80),
          ),
        ),
        const SizedBox(height: 12),
        // Day labels
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Tue',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              'Wed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              'Thu',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              'Sun',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Progress',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        ...weeklyProgress.map((session) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildProgressCard(session),
            )),
      ],
    );
  }

  Widget _buildProgressCard(Map<String, dynamic> session) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Time chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 87, 152, 198),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              session['time']!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Patient info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session['name']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session['service']!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          // Progress percentage with checkmark
          if (session['progress'] != null)
            Row(
              children: [
                if (session['hasCheckmark'] == true)
                  const Icon(
                    Icons.check_circle,
                    color: Color.fromARGB(255, 99, 197, 150),
                    size: 18,
                  ),
                if (session['hasCheckmark'] == true) const SizedBox(width: 6),
                Text(
                  session['progress']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 99, 197, 150),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Send Report button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report sent to patient')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5798C6),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.mail_outline, color: Colors.white),
            label: const Text(
              'Send Report to Patient',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Export PDF button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting report to PDF')),
              );
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey[300]!, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(Icons.file_download_outlined, color: Colors.grey[600]),
            label: Text(
              'Export PDF',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Add Clinical Note button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add clinical note')),
              );
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey[300]!, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(Icons.add_circle_outline, color: Colors.grey[600]),
            label: Text(
              'Add Clinical Note',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF95B8D1),
      unselectedItemColor: Colors.grey,
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
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}

// Custom painter for the line chart
class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF95B8D1)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = const Color(0xFF95B8D1)
      ..style = PaintingStyle.fill;

    // Points along the line (simplified)
    final points = [
      Offset(0, size.height * 0.6),
      Offset(size.width * 0.33, size.height * 0.45),
      Offset(size.width * 0.66, size.height * 0.3),
      Offset(size.width, size.height * 0.2),
    ];

    // Draw line
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    // Draw dots
    for (var point in points) {
      canvas.drawCircle(point, 5, dotPaint);
    }

    // Draw light background area under the line
    final backgroundPaint = Paint()
      ..color = const Color(0xFF95B8D1).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    for (var point in points) {
      path.lineTo(point.dx, point.dy);
    }
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
