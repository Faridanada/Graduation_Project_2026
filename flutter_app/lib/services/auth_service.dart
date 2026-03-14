import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class AuthService {
  static const String baseUrl = "http://10.0.2.2:5000/api";

  // REGISTER
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    Map<String, dynamic>? profileData,
    File? imageFile,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl/register");
      var request = http.MultipartRequest('POST', uri);

      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;

      if (profileData != null) {
        request.fields['profileData'] = jsonEncode(profileData);
      }

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('profileImage', imageFile.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);

      return {
        "statusCode": response.statusCode,
        "data": data,
      };
    } catch (e) {
      return {
        "statusCode": 500,
        "data": {"message": "Server error. Could not decode response."},
      };
    }
  }

  // LOGIN
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
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
    } catch (e) {
      return {
        "statusCode": 500,
        "data": {"message": "Server error. Could not decode response."},
      };
    }
  }
}