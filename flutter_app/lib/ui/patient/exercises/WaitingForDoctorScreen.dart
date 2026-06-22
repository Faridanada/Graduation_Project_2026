import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/webrtc_service.dart';
import 'package:rehabilitation_app/ui/exercises/active_exercice_screen.dart';

class WaitingForDoctorScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final String patientId;
  final String patientName;
  final String doctorId;

  const WaitingForDoctorScreen({
    Key? key,
    required this.exercise,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
  }) : super(key: key);

  @override
  State<WaitingForDoctorScreen> createState() => _WaitingForDoctorScreenState();
}

class _WaitingForDoctorScreenState extends State<WaitingForDoctorScreen> {
  final WebRTCService _webRTC = WebRTCService();
  late StreamSubscription _signalingSub;
  
  String _statusMessage = "Waiting for your doctor to accept the session...";
  bool _doctorAccepted = false;
  late String _sessionChannel;

  @override
  void initState() {
    super.initState();
    _sessionChannel = 'session_${widget.patientId}_${widget.exercise['id'] ?? DateTime.now().millisecondsSinceEpoch}';
    _setupConnection();
  }

  Future<void> _setupConnection() async {
    // 1. Connect and subscribe to our session channel
    await _webRTC.initConnection(_sessionChannel, isPatient: true);

    // 2. Listen for events
    _signalingSub = _webRTC.signalingStream.listen((data) {
      if (!mounted) return;
      
      final webrtcType = data['webrtc_type'];
      if (webrtcType == 'doctor_accepted') {
        setState(() {
          _doctorAccepted = true;
          _statusMessage = "Doctor accepted! Waiting for them to set the machine angles...";
        });
      } else if (webrtcType == 'angles_set') {
        final minDegree = data['min'] as int?;
        final maxDegree = data['max'] as int?;
        
        // Update the exercise with the live angles
        final updatedExercise = Map<String, dynamic>.from(widget.exercise);
        updatedExercise['minAngle'] = minDegree;
        updatedExercise['maxAngle'] = maxDegree;

        // Navigate to the active exercise screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ActiveExerciseScreen(exercise: updatedExercise),
          ),
        );
      }
    });

    // 3. Page the doctor on their channel
    _webRTC.sendCustomSignaling(
      targetSessionId: 'doctor_${widget.doctorId}',
      data: {
        'webrtc_type': 'patient_waiting',
        'patientId': widget.patientId,
        'patientName': widget.patientName,
        'exerciseId': widget.exercise['id'] ?? '',
        'exerciseTitle': widget.exercise['title'] ?? 'Passive-Monitored Session',
        'sessionChannel': _sessionChannel,
      },
    );
  }

  @override
  void dispose() {
    _signalingSub.cancel();
    _webRTC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Session Setup'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _doctorAccepted
                  ? const Icon(Icons.settings_suggest, size: 80, color: Colors.blue)
                  : const CircularProgressIndicator(strokeWidth: 3),
              const SizedBox(height: 32),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please keep this screen open.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
