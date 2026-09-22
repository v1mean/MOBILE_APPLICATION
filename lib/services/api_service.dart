import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    if (kIsWeb) {
      return 'http://localhost:5005/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5005/api';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'http://localhost:5005/api';
    }
    return 'http://localhost:5005/api';
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
            ? 'http://localhost:5005/api'
            : 'http://10.0.2.2:5005/api';
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

  static Future<http.Response> _getWithFallback(
    String endpoint, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      return await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(timeout);
    } catch (e) {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final fallbackBase = baseUrl.contains('10.0.2.2')
            ? 'http://localhost:5005/api'
            : 'http://10.0.2.2:5005/api';
        try {
          return await http
              .get(Uri.parse('$fallbackBase$endpoint'), headers: headers)
              .timeout(timeout);
        } catch (_) {}
      }
      rethrow;
    }
  }

  static Future<http.Response> _patchWithFallback(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final defaultHeaders = {'Content-Type': 'application/json', ...?headers};

    try {
      return await http
          .patch(
            Uri.parse('$baseUrl$endpoint'),
            headers: defaultHeaders,
            body: body,
          )
          .timeout(timeout);
    } catch (e) {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final fallbackBase = baseUrl.contains('10.0.2.2')
            ? 'http://localhost:5005/api'
            : 'http://10.0.2.2:5005/api';
        try {
          return await http
              .patch(
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
    final response = await _postWithFallback(
      '/auth/update-password',
      headers: {'Authorization': 'Bearer $accessToken'},
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

  // ── Mentor Search ───────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> searchMentors({
    String? query,
    String? subject,
    double? minPrice,
    double? maxPrice,
    String? city,
    String? day,
  }) async {
    final params = <String, String>{};
    if (query != null && query.isNotEmpty) params['query'] = query;
    if (subject != null && subject.isNotEmpty) params['subject'] = subject;
    if (minPrice != null) params['minPrice'] = minPrice.toStringAsFixed(0);
    if (maxPrice != null) params['maxPrice'] = maxPrice.toStringAsFixed(0);
    if (city != null && city.isNotEmpty) params['city'] = city;
    if (day != null && day.isNotEmpty) params['day'] = day;

    final uri = Uri.parse(
      '$baseUrl/users/mentors/search',
    ).replace(queryParameters: params.isNotEmpty ? params : null);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      return jsonDecode(response.body);
    } catch (e) {
      // Android fallback
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final fallbackBase = baseUrl.contains('10.0.2.2')
            ? 'http://localhost:5005/api'
            : 'http://10.0.2.2:5005/api';
        final fallbackUri = Uri.parse(
          '$fallbackBase/users/mentors/search',
        ).replace(queryParameters: params.isNotEmpty ? params : null);
        final response = await http
            .get(fallbackUri)
            .timeout(const Duration(seconds: 10));
        return jsonDecode(response.body);
      }
      rethrow;
    }
  }

  // ── Fetch Subjects ────────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> fetchSubjects() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users/mentors/subjects'))
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body);
      final raw = body['subjects'] as List? ?? [];
      return raw.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  // ── Fetch Filtered Mentors (production endpoint) ─────────────────────────
  static Future<Map<String, dynamic>> fetchMentors({
    String? query,
    String? subjectId,
    double? minPrice,
    double? maxPrice,
    String? dayOfWeek,
    String? city,
  }) async {
    final params = <String, String>{};
    if (query != null && query.isNotEmpty) params['query'] = query;
    if (subjectId != null && subjectId.isNotEmpty)
      params['subject_id'] = subjectId;
    if (minPrice != null) params['minPrice'] = minPrice.toStringAsFixed(0);
    if (maxPrice != null) params['maxPrice'] = maxPrice.toStringAsFixed(0);
    if (dayOfWeek != null && dayOfWeek.isNotEmpty)
      params['day_of_week'] = dayOfWeek;
    if (city != null && city.isNotEmpty) params['city'] = city;

    final uri = Uri.parse(
      '$baseUrl/users/mentors',
    ).replace(queryParameters: params.isNotEmpty ? params : null);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      return jsonDecode(response.body);
    } catch (e) {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final fallbackBase = baseUrl.contains('10.0.2.2')
            ? 'http://localhost:5005/api'
            : 'http://10.0.2.2:5005/api';
        final fallbackUri = Uri.parse(
          '$fallbackBase/users/mentors',
        ).replace(queryParameters: params.isNotEmpty ? params : null);
        final response = await http
            .get(fallbackUri)
            .timeout(const Duration(seconds: 10));
        return jsonDecode(response.body);
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String accessToken,
    required String name,
    String? phone,
    String? location,
    String? role,
    String? profileImage,
  }) async {
    final body = jsonEncode({
      'name': name,
      'phone': phone ?? '',
      'location': location ?? '',
      'role': role ?? 'Student',
      if (profileImage != null && profileImage.isNotEmpty)
        'profileImage': profileImage,
    });

    final response = await _patchWithFallback(
      '/users/profile',
      headers: {'Authorization': 'Bearer $accessToken'},
      body: body,
    );
    return jsonDecode(response.body);
  }

  // ── Fetch My Courses ──────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> fetchMyCourses(
    String accessToken,
  ) async {
    try {
      final response = await _getWithFallback(
        '/users/my-courses',
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      final body = jsonDecode(response.body);
      final raw = body['courses'] as List? ?? [];
      return raw.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  // ── Create Booking ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> createBooking({
    required String accessToken,
    required String tutorId,
    String? courseId,
    String? startTime,
    String? endTime,
    double? hourlyRate,
    double? totalPrice,
  }) async {
    final body = jsonEncode({
      'tutor_id': tutorId,
      if (courseId != null) 'course_id': courseId,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (hourlyRate != null) 'hourly_rate': hourlyRate,
      if (totalPrice != null) 'total_price': totalPrice,
    });

    final response = await _postWithFallback(
      '/bookings/create',
      headers: {'Authorization': 'Bearer $accessToken'},
      body: body,
    );
    return jsonDecode(response.body);
  }

  // ── Submit Review ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> submitReview({
    required String accessToken,
    required String mentorId,
    required double rating,
    String? comment,
  }) async {
    final body = jsonEncode({
      'mentor_id': mentorId,
      'rating': rating,
      'comment': comment ?? '',
    });

    final response = await _postWithFallback(
      '/reviews',
      headers: {'Authorization': 'Bearer $accessToken'},
      body: body,
    );
    return jsonDecode(response.body);
  }

  // ── Fetch Mentor Reviews ─────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> fetchMentorReviews(String mentorId) async {
    try {
      final response = await _getWithFallback(
        '/reviews/mentor/$mentorId',
        headers: {},
      );
      final body = jsonDecode(response.body);
      final raw = body['reviews'] as List? ?? [];
      return raw.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> uploadAvatar(
    String filePath,
    String accessToken,
  ) async {
    final uri = Uri.parse('$baseUrl/users/upload-avatar');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..files.add(await http.MultipartFile.fromPath('avatar', filePath));

    try {
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);
      return jsonDecode(response.body);
    } catch (e) {
      // Android fallback
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final fallbackUri = Uri.parse(
          'http://10.0.2.2:5005/api/users/upload-avatar',
        );
        final fallbackRequest = http.MultipartRequest('POST', fallbackUri)
          ..headers['Authorization'] = 'Bearer $accessToken'
          ..files.add(await http.MultipartFile.fromPath('avatar', filePath));
        final streamedResponse = await fallbackRequest.send().timeout(
          const Duration(seconds: 30),
        );
        final response = await http.Response.fromStream(streamedResponse);
        return jsonDecode(response.body);
      }
      rethrow;
    }
  }
}
