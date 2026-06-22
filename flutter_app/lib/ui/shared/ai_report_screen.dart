import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/models/session_report.dart';
import 'package:rehabilitation_app/ui/chats/ConversationScreen.dart';
import 'package:rehabilitation_app/ui/shared/report_widgets.dart';

class AiReportScreen extends StatefulWidget {
  const AiReportScreen({super.key});

  @override
  State<AiReportScreen> createState() => _AiReportScreenState();
}

class _AiReportScreenState extends State<AiReportScreen> {
  bool _isLoading = true;
  String _firstName = "";
  String? _assignedDoctorId;
  String? _assignedDoctorName;
  
  SessionReportEnvelope? _envelope;
  int _streak = 0;
  
  Timer? _pollTimer;
  int _pollTicks = 0;
  String? _latestSessionId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final profile = await ApiService.getUserProfile();
      if (profile != null && mounted) {
        setState(() {
          _firstName = (profile['name'] ?? "Patient").split(' ').first;
          _assignedDoctorId = profile['assignedDoctorId'];
          _assignedDoctorName = profile['assignedDoctorName'] ?? "Doctor";
        });
        
        final patientId = profile['id'];
        if (patientId != null) {
          final sessions = await ApiService.getPatientSessions(patientId);
          
          DateTime now = DateTime.now();
          int streak = sessions.where((s) => s.reportStatus == 'completed' && now.difference(s.startTime).inDays <= 7).length;
          
          setState(() {
            _streak = streak;
          });

          sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
          
          if (sessions.isNotEmpty) {
            _latestSessionId = sessions.first.id;
            _fetchLatestReport(sessions.first.id);
          } else {
            setState(() => _isLoading = false);
          }
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchLatestReport(String sessionId) async {
    try {
      final env = await ApiService.getSessionReport(sessionId);
      if (mounted) {
        setState(() {
          _envelope = env;
          _isLoading = false;
        });

        if (env.reportStatus == 'processing' || env.reportStatus == 'pending') {
          _startPolling();
        } else {
          _pollTimer?.cancel();
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startPolling() {
    if (_pollTimer != null && _pollTimer!.isActive) return;
    _pollTicks = 0;
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _pollTicks++;
      if (_pollTicks >= 40) {
        timer.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Taking longer than usual. Please check back later.')));
        }
      } else if (_latestSessionId != null) {
        _fetchLatestReport(_latestSessionId!);
      }
    });
  }

  void _messageDoctor() {
    if (_assignedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No doctor assigned yet.')));
      return;
    }
    
    final name = _assignedDoctorName ?? "My Doctor";
    final init = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : "D";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationScreen(
          name: name,
          initials: init,
          receiverId: _assignedDoctorId,
          message: "",
        ),
      ),
    );
  }

  String _formatFriendlyDate(DateTime? dt) {
    if (dt == null) return "Recently";
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(dt.year, dt.month, dt.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
    }
  }

  String _getEncouragingNote() {
    final notes = [
      "Keep up the great work!",
      "Every session counts.",
      "You're making progress!",
      "Consistency is key!"
    ];
    notes.shuffle();
    return notes.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Progress', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Greeting Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Hi, $_firstName!", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                        const SizedBox(height: 4),
                        const Text("Here's how your last session went.", style: TextStyle(fontSize: 14, color: Color(0xFF1976D2))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Content Area
                  _buildContentArea(),
                  
                  const SizedBox(height: 24),
                  
                  // Streak row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("🔥 ", style: TextStyle(fontSize: 24)),
                        Text("$_streak sessions this week", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Message Doctor Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      children: [
                        const Text("Questions about your session?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text("Your doctor can give you personalized guidance.", style: TextStyle(color: Colors.grey[600], fontSize: 14), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _messageDoctor,
                            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                            label: const Text("Message Doctor", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildContentArea() {
    final env = _envelope;
    if (env == null) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text("Complete your first session to see your progress here!", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
      ));
    }

    if (env.reportStatus == 'processing' || env.reportStatus == 'pending') {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Your latest session is being analyzed...", style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey)),
          ],
        ),
      );
    }

    if (env.reportStatus == 'failed') {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: const Text("We're having trouble preparing your report. Please check back soon.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    final report = env.report;
    if (report == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatFriendlyDate(report.generatedAt), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                const SizedBox(height: 12),
                Text(report.summary, style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: PatientHighlightCard(text: "🏃 ${(report.metrics.duration.value / 60).round()} min session")),
                    const SizedBox(width: 12),
                    Expanded(child: PatientHighlightCard(text: "🎯 ${report.metrics.repetitionsCompleted} reps")),
                  ],
                ),
                const SizedBox(height: 12),
                const PatientHighlightCard(text: "✨ Good range of motion"),
                const SizedBox(height: 20),
                Text(_getEncouragingNote(), style: const TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF2196F3), fontWeight: FontWeight.w600)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
