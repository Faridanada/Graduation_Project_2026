import 'dart:convert';
import 'dart:io' as io;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:5000/api";
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
  
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final token = await _getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/profile"),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['user'];
      }
    } catch (e) {
      return null;
    }
    return null;
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

  static Future<bool> respondToDoctorRequest(String requestId, bool accept) async {
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
      print('[WoundSubmit] ERROR: No token found — user may not be logged in');
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
      print('[WoundSubmit] Status: ${streamed.statusCode}, Body: $responseBody');
      return streamed.statusCode == 201;
    } catch (e) {
      print('[WoundSubmit] Exception: $e');
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
  static Future<bool> updateWoundStatus(String woundId, String status, String patientId) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$baseUrl/wounds/$woundId/status'),
      headers: _headers(token),
      body: jsonEncode({'status': status, 'patientId': patientId}),
    );
    return response.statusCode == 200;
  }
}
