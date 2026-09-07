import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;
class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5005/api';
    return defaultTargetPlatform == TargetPlatform.android ? 'http://10.0.2.2:5005/api' : 'http://localhost:5005/api';
  }

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

  static Future<void> syncSocialUser(String accessToken) async {
    // Ensures the backend creates/updates a profile with the 'student' role
    // for any social sign-in (Google, Apple). Fire-and-forget.
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/social-sync'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
    } catch (e) {
      log('Social sync error: $e');
    }
  }
}
