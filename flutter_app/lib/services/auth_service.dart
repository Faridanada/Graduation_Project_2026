import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://10.0.2.2:5000/api";

  // REGISTER
static Future<Map<String, dynamic>> register({
  required String name,
  required String email,
  required String password,
  Map<String, dynamic>? profileData,
}) async {
  final Map<String, dynamic> requestBody = {
    "name": name,
    "email": email,
    "password": password,
  };

  if (profileData != null) {
    requestBody["profileData"] = profileData;
  }

  final response = await http.post(
    Uri.parse("$baseUrl/register"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(requestBody),
  );

  final data = jsonDecode(response.body);

  return {
    "statusCode": response.statusCode,
    "data": data,
  };
}

  // LOGIN
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );
    

    final data = jsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }
}