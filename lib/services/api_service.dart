import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:http/http.dart' as http;
class ApiService {
  static final String baseUrl = Platform.isAndroid ? 'http://10.0.2.2:5000/api' : 'http://localhost:5000/api';

  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> registerUser(String email, String password, String fullName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'fullName': fullName,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updatePassword(String newPassword, String accessToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/update-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'newPassword': newPassword}),
    );

    return jsonDecode(response.body);
  }

  static Future<void> syncGoogleUser(String accessToken) async {
    // This hits a backend endpoint to ensure the user profile is created
    // if they logged in via Google for the first time.
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/google-sync'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
    } catch (e) {
      // Ignore sync errors or handle them appropriately
      log('Google sync error: $e');
    }
  }
}
