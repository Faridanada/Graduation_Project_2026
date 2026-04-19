import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' as io;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    if (io.Platform.isAndroid) {
      return "http://10.0.2.2:5000/api";
    } else {
      return "http://localhost:5000/api";
    }
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
  // --- DOCTOR ENDPOINTS ---

  static Future<Map<String, dynamic>> getDoctorStats() async {
    final token = await _getToken();
    if (token == null) return {};

    final response = await http.get(
      Uri.parse("$baseUrl/doctor/stats"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
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
      return jsonDecode(response.body)['data'] ?? [];
    }
    return [];
  }

  static Future<List<dynamic>> getDoctorTodayAppointments() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse("$baseUrl/doctor/appointments/today"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'] ?? [];
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

  // --- PATIENT & REQUEST ENDPOINTS (NEW) ---

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

  static Future<List<dynamic>> getDoctorRequests() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse("$baseUrl/doctor/requests"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'] ?? [];
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

    final response = await http.get(
      Uri.parse("$baseUrl/patient/exercises/today"),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'] ?? [];
    }
    return [];
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

  // --- WOUND ENDPOINTS ---

  /// Patient submits a wound report. [imageFile] is optional.
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

  /// Doctor fetches their notifications.
  static Future<List<dynamic>> getNotifications() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/doctor/notifications'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'] ?? [];
    }
    return [];
  }

  /// Mark a single notification as read.
  static Future<void> markNotificationRead(String notifId) async {
    final token = await _getToken();
    if (token == null) return;

    await http.put(
      Uri.parse('$baseUrl/doctor/notifications/$notifId/read'),
      headers: _headers(token),
    );
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
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['user'];
      }
    } catch (_) {}
    return null;
  }

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
      return response.statusCode == 200;
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
}
