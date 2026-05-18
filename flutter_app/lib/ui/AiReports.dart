import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AiReports extends StatefulWidget {
  const AiReports({Key? key}) : super(key: key);

  @override
  State<AiReports> createState() => _AiReportsState();
}

class _AiReportsState extends State<AiReports> {
  String selectedFilter = 'Weekly';
  String? selectedPatient;
  String selectedRisk = 'Low Risk';
  bool _isLoading = true;

  List<String> patients = [];
  final List<String> timeframes = ['Weekly', 'Monthly', 'Custom'];

  // Dynamic patient mapping
  Map<String, Map<String, dynamic>> patientData = {};
  List<Map<String, dynamic>> weeklyProgress = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final realPatients = await ApiService.getDoctorPatients();
      if (mounted) {
        setState(() {
          patients = realPatients.map((p) => p['name'] as String).toList();

          if (patients.isNotEmpty) {
            selectedPatient = patients.first;
            // Generate some semi-dynamic placeholder data for each real patient
            for (var p in realPatients) {
              final score = 60 +
                  (p['name'].length * 2) %
                      35; // Derived from name for consistency
              patientData[p['name']] = {
                'recoveryScore': '$score%',
                'recoveryStatus': score > 80
                    ? 'Patient recovery\nis on track'
                    : 'Patient needs\nmore attention',
                'riskLevel': score > 85
                    ? 'Low Risk'
                    : (score > 65 ? 'Medium' : 'High Risk'),
              };
            }
            selectedRisk = patientData[selectedPatient!]!['riskLevel'];

            // Generate mock progress for the selected patient
            weeklyProgress = [
              {
                'time': '09:00 AM',
                'name': selectedPatient,
                'service': 'Consultation',
                'progress': '78%',
                'hasCheckmark': true,
              },
            ];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (patients.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: Text('No patients found')),
      );
    }

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
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black),
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
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
      centerTitle: true,
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
          color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.white,
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
            color: Colors.black.withValues(alpha: 0.05),
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
    // Extract percentage from recovery score
    String recoveryScore =
        selectedPatient != null && patientData.containsKey(selectedPatient)
            ? patientData[selectedPatient]!['recoveryScore']
            : '82%';
    int percentage = int.parse(recoveryScore.replaceAll('%', ''));

    // Get labels based on selected timeframe
    List<String> labels = _getTimeframeLabels();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Chart area
        SizedBox(
          height: 80,
          child: CustomPaint(
            painter: LineChartPainter(
              percentage: percentage,
              timeframe: selectedFilter,
            ),
            size: const Size(double.infinity, 80),
          ),
        ),
        const SizedBox(height: 12),
        // Time labels based on selected filter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: labels
              .map(
                (label) => Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  List<String> _getTimeframeLabels() {
    switch (selectedFilter) {
      case 'Weekly':
        return ['Mon', 'Wed', 'Fri', 'Sun'];
      case 'Monthly':
        return ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
      case 'Custom':
        return ['Jan', 'Feb', 'Mar', 'Apr'];
      default:
        return ['Mon', 'Wed', 'Fri', 'Sun'];
    }
  }

  void _showClinicalNoteDialog() {
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Add Clinical Note',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Patient info subtitle
                if (selectedPatient != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Patient: $selectedPatient',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                // Note text field
                TextField(
                  controller: noteController,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: 'Write your clinical note here...',
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey[400],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF95B8D1),
                        width: 2,
                      ),
                    ),
                    fillColor: Colors.grey[50],
                    filled: true,
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (noteController.text.isNotEmpty) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Clinical note saved successfully',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                      backgroundColor: const Color.fromARGB(255, 99, 197, 150),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Please write a note before saving',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                      backgroundColor: const Color.fromARGB(255, 239, 68, 68),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5798C6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.check, color: Colors.white, size: 18),
              label: const Text(
                'Save Note',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
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
            color: Colors.black.withValues(alpha: 0.05),
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
              _showClinicalNoteDialog();
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

}


// Custom painter for the line chart
class LineChartPainter extends CustomPainter {
  final int percentage;
  final String timeframe;

  LineChartPainter({this.percentage = 82, this.timeframe = 'Weekly'});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF95B8D1)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = const Color(0xFF95B8D1)
      ..style = PaintingStyle.fill;

    // Generate points based on percentage
    final points = _generateChartPoints(size);

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
      ..color = const Color(0xFF95B8D1).withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    for (var point in points) {
      path.lineTo(point.dx, point.dy);
    }
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, backgroundPaint);

    // Draw trend indicator (arrow)
    _drawTrendArrow(canvas, size, points);
  }

  List<Offset> _generateChartPoints(Size size) {
    // Convert percentage to normalized value (0.0 to 1.0)
    double normalizedScore = percentage / 100.0;

    // Generate data points based on timeframe and percentage
    final points = <Offset>[];

    // Different patterns for different timeframes
    if (timeframe == 'Monthly') {
      // Monthly view - slower progression, more stable
      if (percentage >= 80) {
        points.add(Offset(0, size.height * 0.5));
        points.add(Offset(size.width * 0.33, size.height * 0.4));
        points.add(Offset(size.width * 0.66, size.height * 0.25));
        points.add(Offset(size.width, size.height * 0.1));
      } else if (percentage >= 60) {
        points.add(Offset(0, size.height * 0.6));
        points.add(Offset(size.width * 0.33, size.height * 0.5));
        points.add(Offset(size.width * 0.66, size.height * 0.35));
        points.add(Offset(size.width, size.height * 0.2));
      } else if (percentage >= 40) {
        points.add(Offset(0, size.height * 0.75));
        points.add(Offset(size.width * 0.33, size.height * 0.6));
        points.add(Offset(size.width * 0.66, size.height * 0.45));
        points.add(Offset(size.width, size.height * 0.35));
      } else {
        points.add(Offset(0, size.height * 0.9));
        points.add(Offset(size.width * 0.33, size.height * 0.7));
        points.add(Offset(size.width * 0.66, size.height * 0.55));
        points.add(Offset(size.width, size.height * 0.45));
      }
    } else if (timeframe == 'Custom') {
      // Custom view - more volatile, shows ups and downs
      if (percentage >= 80) {
        points.add(Offset(0, size.height * 0.55));
        points.add(Offset(size.width * 0.33, size.height * 0.35));
        points.add(Offset(size.width * 0.66, size.height * 0.45));
        points.add(Offset(size.width, size.height * 0.15));
      } else if (percentage >= 60) {
        points.add(Offset(0, size.height * 0.65));
        points.add(Offset(size.width * 0.33, size.height * 0.45));
        points.add(Offset(size.width * 0.66, size.height * 0.55));
        points.add(Offset(size.width, size.height * 0.25));
      } else if (percentage >= 40) {
        points.add(Offset(0, size.height * 0.8));
        points.add(Offset(size.width * 0.33, size.height * 0.55));
        points.add(Offset(size.width * 0.66, size.height * 0.65));
        points.add(Offset(size.width, size.height * 0.4));
      } else {
        points.add(Offset(0, size.height * 0.92));
        points.add(Offset(size.width * 0.33, size.height * 0.65));
        points.add(Offset(size.width * 0.66, size.height * 0.75));
        points.add(Offset(size.width, size.height * 0.5));
      }
    } else {
      // Weekly view - default (as before)
      if (percentage >= 80) {
        // High score - show strong upward trend
        points.add(Offset(0, size.height * (1 - normalizedScore * 0.4)));
        points.add(Offset(
            size.width * 0.33, size.height * (1 - normalizedScore * 0.55)));
        points.add(Offset(
            size.width * 0.66, size.height * (1 - normalizedScore * 0.7)));
        points.add(
            Offset(size.width, size.height * (1 - normalizedScore * 0.85)));
      } else if (percentage >= 60) {
        // Medium-high score - moderate upward trend
        points.add(Offset(0, size.height * (1 - normalizedScore * 0.3)));
        points.add(Offset(
            size.width * 0.33, size.height * (1 - normalizedScore * 0.45)));
        points.add(Offset(
            size.width * 0.66, size.height * (1 - normalizedScore * 0.6)));
        points.add(
            Offset(size.width, size.height * (1 - normalizedScore * 0.72)));
      } else if (percentage >= 40) {
        // Medium score - gradually improving
        points.add(Offset(0, size.height * (1 - normalizedScore * 0.2)));
        points.add(Offset(
            size.width * 0.33, size.height * (1 - normalizedScore * 0.35)));
        points.add(Offset(
            size.width * 0.66, size.height * (1 - normalizedScore * 0.5)));
        points
            .add(Offset(size.width, size.height * (1 - normalizedScore * 0.6)));
      } else {
        // Low score - steep upward trend
        points.add(Offset(0, size.height * 0.95));
        points.add(Offset(
            size.width * 0.33, size.height * (1 - normalizedScore * 0.25)));
        points.add(Offset(
            size.width * 0.66, size.height * (1 - normalizedScore * 0.4)));
        points.add(
            Offset(size.width, size.height * (1 - normalizedScore * 0.55)));
      }
    }

    return points;
  }

  void _drawTrendArrow(Canvas canvas, Size size, List<Offset> points) {
    if (points.length < 2) return;

    final lastPoint = points.last;
    final secondLastPoint = points[points.length - 2];

    // Determine trend direction
    bool isIncreasing = lastPoint.dy < secondLastPoint.dy;
    bool isDecreasing = lastPoint.dy > secondLastPoint.dy;

    // Arrow paint
    final arrowPaint = Paint()
      ..color = isIncreasing
          ? const Color.fromARGB(255, 99, 197, 150)
          : isDecreasing
              ? const Color.fromARGB(255, 239, 68, 68)
              : Colors.grey
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Draw trend icon near the last point
    final arrowX = lastPoint.dx - 20;
    final arrowY = lastPoint.dy - 15;

    if (isIncreasing) {
      // Draw upward arrow
      canvas.drawLine(
          Offset(arrowX, arrowY + 8), Offset(arrowX, arrowY - 8), arrowPaint);
      canvas.drawLine(Offset(arrowX, arrowY - 8),
          Offset(arrowX - 4, arrowY - 4), arrowPaint);
      canvas.drawLine(Offset(arrowX, arrowY - 8),
          Offset(arrowX + 4, arrowY - 4), arrowPaint);
    } else if (isDecreasing) {
      // Draw downward arrow
      canvas.drawLine(
          Offset(arrowX, arrowY - 8), Offset(arrowX, arrowY + 8), arrowPaint);
      canvas.drawLine(Offset(arrowX, arrowY + 8),
          Offset(arrowX - 4, arrowY + 4), arrowPaint);
      canvas.drawLine(Offset(arrowX, arrowY + 8),
          Offset(arrowX + 4, arrowY + 4), arrowPaint);
    } else {
      // Draw horizontal arrow (stable)
      canvas.drawLine(
          Offset(arrowX - 6, arrowY), Offset(arrowX + 6, arrowY), arrowPaint);
    }
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.timeframe != timeframe;
  }
}
