import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:5000/api";

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Map<String, String> _headers(String token) {
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
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

  // --- PATIENT ENDPOINTS ---

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
}
