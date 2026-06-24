import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' as io;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:rehabilitation_app/models/session_report.dart';

class ApiService {
  static dynamic _normalizeJsonValue(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.fromEntries(
        value.entries.map(
          (entry) => MapEntry(
            entry.key.toString(),
            _normalizeJsonValue(entry.value),
          ),
        ),
      );
    }

    if (value is List) {
      return value.map(_normalizeJsonValue).toList();
    }

    return value;
  }

  static String get baseUrl {
    return "https://flexio-rehab.duckdns.org/api";
    // return "http://10.0.2.2:5000/api";
  }

  static const String _tokenKey = 'jwt_token';

  static String? currentToken;

  /// Call this once at app startup (e.g., in main.dart) to restore the token.
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    currentToken = prefs.getString(_tokenKey);
  }

  /// Saves the token both in memory and to disk.
  static Future<void> setToken(String token) async {
    currentToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Clears the token from memory and disk (logout).
  static Future<void> clearToken() async {
    currentToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<String?> _getToken() async {
    return currentToken;
  }

  static Map<String, String> _headers(String token) {
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // --- USER ENDPOINTS ---

  static Future<bool> checkEmailUsage(String email) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/check-email?email=$email"),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return !data['available']; // Returns true if email IS used
      }
    } catch (_) {}
    return false;
  }

  // --- SESSION REPORTS ---

  static Future<List<SessionListItem>> getPatientSessions(String patientId, {DateTime? start, DateTime? end}) async {
    final token = await _getToken();
    if (token == null) return [];

    String query = '';
    if (start != null) query += '?start=${start.toIso8601String()}';
    if (end != null) query += (query.isEmpty ? '?' : '&') + 'end=${end.toIso8601String()}';

    final urlStr = "$baseUrl/sessions/patient/$patientId$query";

    final response = await http.get(
      Uri.parse(urlStr),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['sessions'] ?? [];
      return (data as List)
          .map((x) => SessionListItem.fromJson(x))
          .where((s) => s.status == 'completed')
          .toList();
    }
    return [];
  }

  static Future<SessionReportEnvelope> getSessionReport(String sessionId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token');

    final response = await http.get(
      Uri.parse("$baseUrl/sessions/$sessionId/report"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return SessionReportEnvelope.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load report');
  }

  static Future<void> regenerateReport(String sessionId) async {
    final token = await _getToken();
    if (token == null) return;

    final response = await http.post(
      Uri.parse("$baseUrl/sessions/$sessionId/regenerate-report"),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to regenerate report');
    }
  }

  // --- DOCTOR ENDPOINTS ---

  static Future<Map<String, dynamic>> getDoctorStats() async {
    final token = await _getToken();
    if (token == null) return {};

    final response = await http.get(
      Uri.parse("$baseUrl/doctor/stats"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      if (data != null && data['unreadNotifications'] != null) {
        unreadNotificationsNotifier.value = data['unreadNotifications'] as int;
      }
      return data ?? {};
    }
    return {};
  }

  static Future<List<dynamic>> getDoctorPatients() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse("$baseUrl/doctor/patients"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] ?? [];
      return _normalizeJsonValue(data) as List<dynamic>;
    }
    return [];
  }

  static Future<List<dynamic>> getAllPatientsForDoctor({String? name}) async {
    final token = await _getToken();
    if (token == null) return [];

    final query = (name != null && name.trim().isNotEmpty)
        ? '?name=${Uri.encodeQueryComponent(name.trim())}'
        : '';

    final response = await http.get(
      Uri.parse("$baseUrl/doctor/patients/all$query"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] ?? [];
      return _normalizeJsonValue(data) as List<dynamic>;
    }
    return [];
  }

  static Future<bool> assignExistingPatient(String patientId) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse("$baseUrl/doctor/patients/assign"),
      headers: _headers(token),
      body: jsonEncode({'patientId': patientId}),
    );

    return response.statusCode == 200;
  }

  static Future<List<dynamic>> getAllDoctorsForDoctor({String? name}) async {
    final token = await _getToken();
    if (token == null) return [];

    final query = (name != null && name.trim().isNotEmpty)
        ? '?name=${Uri.encodeQueryComponent(name.trim())}'
        : '';

    final response = await http.get(
      Uri.parse("$baseUrl/patient/doctors$query"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] ?? [];
      return _normalizeJsonValue(data) as List<dynamic>;
    }
    return [];
  }

  static Future<List<dynamic>> getDoctorTodayAppointments() async {
    final token = await _getToken();
    if (token == null) return [];

    // Fetch all appointments and filter locally to avoid UTC vs Local timezone issues
    final response = await http.get(
      Uri.parse("$baseUrl/appointments"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] ?? [];
      final allApts = _normalizeJsonValue(data) as List<dynamic>;
      
      final now = DateTime.now();
      return allApts.where((apt) {
        final dateStr = apt['date']?.toString() ?? '';
        final aptDate = DateTime.tryParse(dateStr);
        if (aptDate == null) return false;
        return aptDate.year == now.year &&
               aptDate.month == now.month &&
               aptDate.day == now.day;
      }).toList();
    }
    return [];
  }

  static Future<List<dynamic>> getAllAppointments() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse("$baseUrl/appointments"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'] ?? [];
    }
    return [];
  }

  static Future<bool> assignExercise({
    required String patientId,
    required String title,
    required int estimatedTimeMin,
    required int repsTotal,
    required String dateAssigned,
  }) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse("$baseUrl/doctor/exercises/assign"),
      headers: _headers(token),
      body: jsonEncode({
        "patientId": patientId,
        "title": title,
        "estimatedTimeMin": estimatedTimeMin,
        "repsTotal": repsTotal,
        "dateAssigned": dateAssigned,
      }),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }

  // --- PATIENT & REQUEST ENDPOINTS  ---

  static Future<bool> createRecoveryPlan(Map<String, dynamic> planData) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse("$baseUrl/doctor/recovery-plan"),
      headers: _headers(token),
      body: jsonEncode(planData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<bool> deleteRecoveryPlan(String planId) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/doctor/recovery-plan/$planId"),
        headers: _headers(token),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Delete recovery plan error: $e");
      return false;
    }
  }

  static Future<bool> addDoctorPatient(Map<String, dynamic> patientData) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse("$baseUrl/doctor/patients/add"),
      headers: _headers(token),
      body: jsonEncode(patientData),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }

  static Future<bool> removePatient(String patientId) async {
    final token = await _getToken();
    if (token == null) return false;
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/doctor/patients/$patientId"),
        headers: _headers(token),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("API Error (removePatient): $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getPatientDetails(
      String patientId) async {
    final token = await _getToken();
    if (token == null) return null;

    if (patientId.trim().isEmpty) {
      print("Error: API getPatientDetails called with empty patientId");
      return null;
    }

    final url = "$baseUrl/doctor/patients/$patientId";
    print("Calling API: $url");

    final response = await http.get(
      Uri.parse(url),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'];
      if (data is Map) {
        return _normalizeJsonValue(data) as Map<String, dynamic>;
      }

      print(
          "Error: Expected Map for patient details but got ${data.runtimeType}");
      return null;
    }
    return null;
  }

  static Future<List<dynamic>> getDoctorRequests() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse("$baseUrl/doctor/requests"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] ?? [];
      return _normalizeJsonValue(data) as List<dynamic>;
    }
    return [];
  }

  static Future<bool> respondToDoctorRequest(
      String requestId, bool accept) async {
    final token = await _getToken();
    if (token == null) return false;

    final endpoint = accept ? "accept" : "reject";

    final response = await http.put(
      Uri.parse("$baseUrl/doctor/requests/$requestId/$endpoint"),
      headers: _headers(token),
    );

    return response.statusCode == 200;
  }

  // --- PATIENT ENDPOINTS ---

  static Future<Map<String, dynamic>?> getRecoveryPlan() async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse("$baseUrl/patient/recovery-plan"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data']; // Might be null
    }
    return null;
  }

  static Future<bool> markExerciseComplete(
      {required String planId, required String exerciseId, required bool done}) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/patient/completions'),
        headers: _headers(token),
        body: jsonEncode({
          'planId': planId,
          'exerciseId': exerciseId,
          'done': done,
        }),
      );
      return response.statusCode == 201;
    } catch (_) {}
    return false;
  }

  static Future<bool> notifyDoctorSessionStart({
    required String exerciseTitle,
    required String patientName,
    required String sessionChannel,
  }) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/patient/notify-session-start'),
        headers: _headers(token),
        body: jsonEncode({
          'exerciseTitle': exerciseTitle,
          'patientName': patientName,
          'sessionChannel': sessionChannel,
        }),
      );
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<List<dynamic>> getCompletions({String? planId}) async {
    final token = await _getToken();
    if (token == null) return [];

    final query = planId != null ? "?planId=$planId" : "";
    final response = await http.get(
      Uri.parse("$baseUrl/patient/completions$query"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] ?? [];
      return _normalizeJsonValue(data) as List<dynamic>;
    }
    return [];
  }

  static Future<bool> markPhaseCompleted(String planId, int phaseIndex) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse("$baseUrl/patient/recovery-plan/$planId/phases/$phaseIndex/complete"),
      headers: _headers(token),
    );

    return response.statusCode == 200;
  }

  static Future<bool> remindDoctorToCreatePlan() async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse("$baseUrl/patient/remind-doctor"),
      headers: _headers(token),
    );

    return response.statusCode == 200;
  }

  static Future<List<dynamic>> getAllDoctors() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse("$baseUrl/patient/doctors"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'] ?? [];
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getMyDoctor() async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse("$baseUrl/patient/doctor"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    return null;
  }

  static Future<bool> sendPatientRequest(String doctorId) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse("$baseUrl/patient/request"),
      headers: _headers(token),
      body: jsonEncode({"doctorId": doctorId}),
    );

    return response.statusCode == 201;
  }

  static Future<List<dynamic>> getPatientTodayExercises() async {
    final token = await _getToken();
    if (token == null) return [];

    final dateStr = DateTime.now().toIso8601String().split('T')[0];
    final response = await http.get(
      Uri.parse("$baseUrl/patient/exercises/today?date=$dateStr"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'] ?? [];
    }
    return [];
  }

  static Future<List<dynamic>> getPatientExercises() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse("$baseUrl/patient/exercises"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'] ?? [];
    }
    return [];
  }

  static Future<Map<String, dynamic>> getPatientDashboardStats() async {
    final token = await _getToken();
    if (token == null) return {};

    final response = await http.get(
      Uri.parse("$baseUrl/patient/stats"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] ?? {};
      if (data['unreadNotifications'] != null) {
        unreadNotificationsNotifier.value = data['unreadNotifications'] as int;
      }
      return data;
    }
    return {};
  }

  static Future<Map<String, dynamic>?> getPatientNextAppointment() async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse("$baseUrl/patient/appointments/next"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    return null;
  }

  static Future<List<dynamic>> getPatientReminders() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse("$baseUrl/patient/reminders"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'] ?? [];
    }
    return [];
  }

  static Future<bool> createReminder(String text, String type) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse("$baseUrl/patient/reminders"),
      headers: _headers(token),
      body: jsonEncode({"text": text, "type": type}),
    );

    return response.statusCode == 201;
  }

  // --- WOUND ENDPOINTS ---

  // /// Patient submits a wound report. [imageFile] is optional.
  // static Future<List<dynamic>> getMyWounds() async {
  //   final token = await _getToken();
  //   if (token == null) return [];
  //   try {
  //     final response = await http.get(
  //       Uri.parse("$baseUrl/wounds"),
  //       headers: _headers(token),
  //     );
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       return _normalizeJsonValue(data['data'] ?? []);
  //     }
  //     return [];
  //   } catch (e) {
  //     debugPrint("API Error (getMyWounds): $e");
  //     return [];
  //   }
  // }

  static Future<bool> submitWoundReport({
    required String woundArea,
    required String painLevel,
    String description = '',
    String notes = '',
    io.File? imageFile,
  }) async {
    final token = await _getToken();
    if (token == null) {
      developer.log(
        '[WoundSubmit] ERROR: No token found - user may not be logged in',
        name: 'ApiService.submitWoundReport',
      );
      return false;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/wounds'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['woundArea'] = woundArea;
      request.fields['painLevel'] = painLevel;
      request.fields['description'] = description;
      request.fields['notes'] = notes;

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('woundImage', imageFile.path),
        );
      }

      final streamed = await request.send();
      final responseBody = await streamed.stream.bytesToString();
      developer.log(
        '[WoundSubmit] Status: ${streamed.statusCode}, Body: $responseBody',
        name: 'ApiService.submitWoundReport',
      );
      return streamed.statusCode == 201;
    } catch (e) {
      developer.log(
        '[WoundSubmit] Exception: $e',
        name: 'ApiService.submitWoundReport',
      );
      return false;
    }
  }

  /// Patient gets their own wound history.
  static Future<List<dynamic>> getMyWounds() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/wounds'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'] ?? [];
    }
    return [];
  }

  /// Doctor gets all wounds from their patients.
  static Future<List<dynamic>> getDoctorWounds() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/doctor/wounds'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'] ?? [];
    }
    return [];
  }

  /// Doctor marks a wound as reviewed or healed.
  static Future<bool> updateWoundStatus(
      String woundId, String status, String patientId) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$baseUrl/wounds/$woundId/status'),
      headers: _headers(token),
      body: jsonEncode({'status': status, 'patientId': patientId}),
    );
    return response.statusCode == 200;
  }

  // --- NOTIFICATION ENDPOINTS ---

  static Future<List<dynamic>> getNotifications() async {
    final token = await _getToken();
    if (token == null) return [];

    // Check user profile for role to determine correct endpoint
    final profile = await getUserProfile();
    final role = profile?['role'] ?? 'patient';
    final endpoint = role == 'doctor' ? 'doctor' : 'patient';

    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint/notifications'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body)['data'] ?? [];
      int unreadCount = 0;
      for (var item in list) {
        if (item['isRead'] == false || item['isRead'] == 'false') {
          unreadCount++;
        }
      }
      unreadNotificationsNotifier.value = unreadCount;
      return list;
    }
    return [];
  }

  /// Mark a single notification as read.
  static Future<void> markNotificationRead(String notifId) async {
    final token = await _getToken();
    if (token == null) return;

    final profile = await getUserProfile();
    final role = profile?['role'] ?? 'patient';
    final endpoint = role == 'doctor' ? 'doctor' : 'patient';

    await http.put(
      Uri.parse('$baseUrl/$endpoint/notifications/$notifId/read'),
      headers: _headers(token),
    );
    unreadNotificationsNotifier.value = (unreadNotificationsNotifier.value - 1).clamp(0, 999999);
  }

  /// Mark all notifications as read.
  static Future<void> markAllNotificationsRead() async {
    final token = await _getToken();
    if (token == null) return;

    final profile = await getUserProfile();
    final role = profile?['role'] ?? 'patient';
    final endpoint = role == 'doctor' ? 'doctor' : 'patient';

    await http.put(
      Uri.parse('$baseUrl/$endpoint/notifications/read-all'),
      headers: _headers(token),
    );
    unreadNotificationsNotifier.value = 0;
  }

  // --- APPOINTMENTS & AVAILABILITY ENDPOINTS ---

  /// Get appointments for the current user (auto-filters for doctor or patient)
  static Future<List<dynamic>> getAppointments() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/appointments'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'] ?? [];
    }
    return [];
  }

  /// Book a new appointment
  static Future<bool> createAppointment({
    String doctorId = '',
    String patientId = '',
    required String date,
    required String time,
    String type = 'Consultation',
    String notes = '',
  }) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/appointments'),
      headers: _headers(token),
      body: jsonEncode({
        if (doctorId.isNotEmpty) 'doctorId': doctorId,
        if (patientId.isNotEmpty) 'patientId': patientId,
        'date': date,
        'time': time,
        'type': type,
        'notes': notes,
      }),
    );
    return response.statusCode == 201;
  }

  /// Change appointment status (scheduled, completed, cancelled)
  static Future<bool> updateAppointmentStatus(String id, String status) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$baseUrl/appointments/$id/status'),
      headers: _headers(token),
      body: jsonEncode({'status': status}),
    );
    return response.statusCode == 200;
  }

  /// Get a doctor's own availability
  static Future<List<dynamic>> getMyAvailability() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/doctor/availability'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'] ?? [];
    }
    return [];
  }

  /// Patient fetching a specific doctor's availability
  static Future<List<dynamic>> getDoctorAvailability(String doctorId) async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/patient/doctors/$doctorId/availability'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'] ?? [];
    }
    return [];
  }

  /// Doctor sets their availability
  static Future<bool> setMyAvailability(List<dynamic> availability) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$baseUrl/doctor/availability'),
      headers: _headers(token),
      body: jsonEncode({'availability': availability}),
    );
    return response.statusCode == 200;
  }

  /// Get listing of conversations for the current user
  static Future<List<dynamic>> getConversations() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/chat'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'] ?? [];
    }
    return [];
  }

  /// Get current user profile
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final token = await _getToken();
    if (token == null) {
      developer.log('getUserProfile: No token available');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: _headers(token),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        developer
            .log('getUserProfile: Success - Role: ${data['user']?['role']}');
        return data['user'];
      } else {
        developer.log(
            'getUserProfile: Failed with status ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      developer.log('getUserProfile: Exception - $e');
    }
    return null;
  }

  /// Get current user profile, throwing an exception on network errors
  static Future<Map<String, dynamic>?> getUserProfileOrThrow() async {
    final token = await _getToken();
    if (token == null) {
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: _headers(token),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['user'];
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      return null;
    } else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  }

  /// Global notifier for profile updates
  static final ValueNotifier<int> profileUpdateNotifier = ValueNotifier<int>(0);

  /// Global notifier for unread notifications count
  static final ValueNotifier<int> unreadNotificationsNotifier = ValueNotifier<int>(0);

  /// Update user profile
  static Future<bool> updateProfile(Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: _headers(token),
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        profileUpdateNotifier.value++;
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Update user profile picture
  static Future<bool> updateProfileImage(io.File imageFile) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/profile'));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });
      request.files.add(
        await http.MultipartFile.fromPath('profileImage', imageFile.path),
      );

      final streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        profileUpdateNotifier.value++;
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Change password
  static Future<bool> changePassword(
      String oldPassword, String newPassword) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/change-password'),
        headers: _headers(token),
        body: jsonEncode(
            {'oldPassword': oldPassword, 'newPassword': newPassword}),
      );
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  /// Toggle 2FA
  static Future<bool> toggle2FA(bool enabled) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/2fa'),
        headers: _headers(token),
        body: jsonEncode({'enabled': enabled}),
      );
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  /// Get chat history between current user and another user
  static Future<List<dynamic>> getChatHistory(String otherUserId) async {
    final token = await _getToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/$otherUserId'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'] ?? [];
      }
    } catch (_) {}
    return [];
  }

  /// Send a chat message
  static Future<bool> sendChatMessage(String receiverId, String text) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: _headers(token),
        body: jsonEncode({
          'receiverId': receiverId,
          'messageText': text,
        }),
      );
      return response.statusCode == 201;
    } catch (_) {}
    return false;
  }

  /// Complete an exercise
  static Future<bool> completeExercise(String exerciseId, int repsCompleted) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/patient/exercises/$exerciseId/complete'),
        headers: _headers(token),
        body: jsonEncode({'repsCompleted': repsCompleted}),
      );
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  /// Save a completed session
  static Future<bool> saveSession(Map<String, dynamic> sessionData) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/patient/sessions'),
        headers: _headers(token),
        body: jsonEncode(sessionData),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  /// Get Session History for Patient
  static Future<List<dynamic>> getSessionHistory() async {
    final token = await _getToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/patient/sessions'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return _normalizeJsonValue(decoded['data']) ?? [];
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> notifyDoctorSessionCompleted() async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/patient/notify-session-completed"),
        headers: _headers(token),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("API Error (notifyDoctorSessionCompleted): $e");
      return false;
    }
  }
}
