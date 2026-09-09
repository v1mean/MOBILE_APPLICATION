import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');

    if (envUrl.isNotEmpty) return envUrl;

    if (kIsWeb) {
      return 'http://localhost:5050/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5050/api';
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'http://localhost:5050/api';
    }

    return 'http://localhost:5050/api';
  }

  static Future<http.Response> _postWithFallback(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final defaultHeaders = {'Content-Type': 'application/json', ...?headers};

    try {
      return await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: defaultHeaders,
            body: body,
          )
          .timeout(timeout);
    } catch (e) {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final fallbackBase = baseUrl.contains('10.0.2.2')
            ? 'http://localhost:5050/api'
            : 'http://10.0.2.2:5050/api';

        try {
          return await http
              .post(
                Uri.parse('$fallbackBase$endpoint'),
                headers: defaultHeaders,
                body: body,
              )
              .timeout(timeout);
        } catch (_) {}
      }

      rethrow;
    }
  }

  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    final response = await _postWithFallback(
      '/auth/login',
      body: jsonEncode({'email': email, 'password': password}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> registerUser(
    String email,
    String password,
    String fullName,
  ) async {
    final response = await _postWithFallback(
      '/auth/register',
      body: jsonEncode({
        'email': email,
        'password': password,
        'fullName': fullName,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    final response = await _postWithFallback(
      '/auth/forgot-password',
      body: jsonEncode({'email': email}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updatePassword(
    String newPassword,
    String accessToken,
  ) async {
    final response = await http.patch(
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
    try {
      final response = await _postWithFallback(
        '/auth/social-sync',
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      log('Social sync completed. Status: ${response.statusCode}');
    } catch (e) {
      log('Social sync error: $e');
    }
  }
}
