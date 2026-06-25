import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:rehabilitation_app/services/webrtc_service.dart';

class SensorDataService {
  static final SensorDataService _instance = SensorDataService._internal();
  factory SensorDataService() => _instance;

  SensorDataService._internal() {
    _subscription = WebRTCService().socketMessageStream.listen(_onMessage);
  }

  StreamSubscription? _subscription;

  // State Notifiers
  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);
  final ValueNotifier<bool> hasData = ValueNotifier<bool>(false);
  
  final ValueNotifier<double> kneeAngle = ValueNotifier<double>(0.0);
  final ValueNotifier<int> repCount = ValueNotifier<int>(0);
  final ValueNotifier<double> emg1 = ValueNotifier<double>(0.0);
  final ValueNotifier<double> emg2 = ValueNotifier<double>(0.0);
  final ValueNotifier<int> on1 = ValueNotifier<int>(0);
  final ValueNotifier<int> on2 = ValueNotifier<int>(0);

  // Throttling
  DateTime _lastUpdate = DateTime.now();
  static const int _throttleMs = 100; // ~10Hz max update rate to UI

  void _onMessage(Map<String, dynamic> payload) {
    if (payload['kind'] == 'bundle') {
      final data = payload['data'];
      if (data == null) return;

      if (!isConnected.value) isConnected.value = true;
      if (!hasData.value) hasData.value = true;

      final now = DateTime.now();
      if (now.difference(_lastUpdate).inMilliseconds >= _throttleMs) {
        _lastUpdate = now;

        if (data['kneeAngle'] != null) kneeAngle.value = (data['kneeAngle'] as num).toDouble();
        if (data['repCount'] != null) repCount.value = (data['repCount'] as num).toInt();
        if (data['emg1'] != null) emg1.value = (data['emg1'] as num).toDouble();
        if (data['emg2'] != null) emg2.value = (data['emg2'] as num).toDouble();
        if (data['on1'] != null) on1.value = (data['on1'] as num).toInt();
        if (data['on2'] != null) on2.value = (data['on2'] as num).toInt();
      }
    }
  }

  void reset() {
    hasData.value = false;
    kneeAngle.value = 0.0;
    repCount.value = 0;
    emg1.value = 0.0;
    emg2.value = 0.0;
    on1.value = 0;
    on2.value = 0;
  }

  void dispose() {
    _subscription?.cancel();
    isConnected.dispose();
    hasData.dispose();
    kneeAngle.dispose();
    repCount.dispose();
    emg1.dispose();
    emg2.dispose();
    on1.dispose();
    on2.dispose();
  }
}
