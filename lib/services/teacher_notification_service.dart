import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../models/app_notification.dart';
import 'api_service.dart';

/// Backend-synced notifications for the teacher role, mirroring the shape of
/// StudentNotificationService but backed by the real `notifications` table
/// instead of local-only device storage.
class TeacherNotificationService {
  static final ValueNotifier<List<AppNotification>> notificationsNotifier =
      ValueNotifier<List<AppNotification>>([]);

  static final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  static StreamSubscription? _subscription;

  static AppNotification _fromRow(Map<String, dynamic> row) {
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

  static String _mapType(String? backendType) {
    switch (backendType) {
      case 'booking_new':
        return 'booking';
      case 'review_new':
        return 'reminder';
      default:
        return 'system';
    }
  }

  static Future<void> init() async {
    final session = JomnesDB.auth.currentSession;
    if (session == null) return;

    await refresh();

    await _subscription?.cancel();
    _subscription = JomnesDB
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', session.user.id)
        .listen((rows) {
          final list = rows.map(_fromRow).toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          notificationsNotifier.value = list;
          _updateUnreadCount();
        });
  }

  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  static void _updateUnreadCount() {
    unreadCountNotifier.value =
        notificationsNotifier.value.where((n) => !n.isRead).length;
  }

  static Future<void> refresh() async {
    try {
      final session = JomnesDB.auth.currentSession;
      if (session == null) return;

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/notifications'),
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final rows = (body['notifications'] as List? ?? [])
            .cast<Map<String, dynamic>>();
        notificationsNotifier.value = rows.map(_fromRow).toList();
        _updateUnreadCount();
      }
    } catch (e) {
      debugPrint('Error fetching teacher notifications: $e');
    }
  }

  static Future<void> markAsRead(String id) async {
    final current = List<AppNotification>.from(notificationsNotifier.value);
    final idx = current.indexWhere((n) => n.id == id);
    if (idx != -1 && !current[idx].isRead) {
      current[idx].isRead = true;
      notificationsNotifier.value = current;
      _updateUnreadCount();
    }

    try {
      final session = JomnesDB.auth.currentSession;
      if (session == null) return;
      await http.patch(
        Uri.parse('${ApiService.baseUrl}/notifications/$id/read'),
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );
    } catch (e) {
      debugPrint('Error marking teacher notification read: $e');
    }
  }

  static Future<void> markAllAsRead() async {
    final current = List<AppNotification>.from(notificationsNotifier.value);
    for (final n in current) {
      n.isRead = true;
    }
    notificationsNotifier.value = current;
    _updateUnreadCount();

    try {
      final session = JomnesDB.auth.currentSession;
      if (session == null) return;
      await http.patch(
        Uri.parse('${ApiService.baseUrl}/notifications/read-all'),
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );
    } catch (e) {
      debugPrint('Error marking all teacher notifications read: $e');
    }
  }
}
