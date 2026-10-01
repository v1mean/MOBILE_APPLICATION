import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/app_notification.dart';
import '../services/api_service.dart';
import '../services/supabase_service.dart';

/// A teacher's notifications. Unlike the student's, these are stored on the
/// server (the `notifications` table) and created by the backend when a
/// student books a session or leaves a review.
class TeacherNotificationRepository {
  /// The latest notifications, or null when the backend reports a failure.
  Future<List<AppNotification>?> fetchNotifications(String accessToken) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/notifications'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    final body = jsonDecode(response.body);
    if (body['success'] != true) return null;

    final rows = (body['notifications'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    return rows.map(_fromRow).toList();
  }

  /// Live updates of the user's notifications, newest first.
  Stream<List<AppNotification>> watchNotifications(String userId) {
    return supabaseClient
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map(
          (rows) =>
              rows.map(_fromRow).toList()
                ..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
        );
  }

  Future<void> markRead(String id, String accessToken) async {
    await http.patch(
      Uri.parse('${ApiService.baseUrl}/notifications/$id/read'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<void> markAllRead(String accessToken) async {
    await http.patch(
      Uri.parse('${ApiService.baseUrl}/notifications/read-all'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  AppNotification _fromRow(Map<String, dynamic> row) {
    return AppNotification(
      id: row['id'].toString(),
      title: row['title']?.toString() ?? '',
      body: row['body']?.toString() ?? '',
      timestamp:
          DateTime.tryParse(row['created_at']?.toString() ?? '') ??
          DateTime.now(),
      isRead: row['is_read'] == true,
      type: _mapType(row['type']?.toString()),
    );
  }

  // The notification cards pick their icon from these type names.
  String _mapType(String? backendType) {
    switch (backendType) {
      case 'booking_new':
        return 'booking';
      case 'review_new':
        return 'reminder';
      default:
        return 'system';
    }
  }
}
