import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_notification.dart';
import 'notification_service.dart';

class StudentNotificationService {
  static const String _storageKey = 'jomnes_student_notifications_v1';

  static final ValueNotifier<List<AppNotification>> notificationsNotifier =
      ValueNotifier<List<AppNotification>>([]);

  static final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  static bool _initialized = false;

  /// Initialize service, load saved notifications, or load default seed items.
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_storageKey);

      if (rawList != null && rawList.isNotEmpty) {
        final list = rawList
            .map((item) {
              try {
                return AppNotification.fromJson(item);
              } catch (_) {
                return null;
              }
            })
            .whereType<AppNotification>()
            .toList();

        // Sort descending by timestamp
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        notificationsNotifier.value = list;
      } else {
        // Seed default initial notifications so student has a welcoming experience
        final now = DateTime.now();
        final seedNotifications = [
          AppNotification(
            id: 'seed_welcome',
            title: 'Welcome to Jomnes! 👋',
            body: 'Discover top mentors and book one-on-one sessions in academic subjects, languages, and sports.',
            timestamp: now.subtract(const Duration(hours: 1)),
            isRead: false,
            type: 'system',
            route: '/home',
          ),
          AppNotification(
            id: 'seed_courses',
            title: 'Explore Featured Courses 🚀',
            body: 'Check out newly added courses in Math, Chinese, English, and Football coaching.',
            timestamp: now.subtract(const Duration(hours: 3)),
            isRead: false,
            type: 'course',
            route: '/course-listing',
          ),
          AppNotification(
            id: 'seed_reminder',
            title: 'Learning Reminder 💡',
            body: 'Consistency is key! Find a mentor who matches your schedule and boost your skills today.',
            timestamp: now.subtract(const Duration(days: 1)),
            isRead: true,
            type: 'reminder',
            route: '/search',
          ),
        ];
        notificationsNotifier.value = seedNotifications;
        await _save();
      }
      _updateUnreadCount();
    } catch (e) {
      debugPrint('Error initializing StudentNotificationService: $e');
    }
  }

  static void _updateUnreadCount() {
    final count = notificationsNotifier.value.where((n) => !n.isRead).length;
    unreadCountNotifier.value = count;
  }

  static Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stringList =
          notificationsNotifier.value.map((n) => n.toJson()).toList();
      await prefs.setStringList(_storageKey, stringList);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  /// Add a new notification
  static Future<void> addNotification({
    required String title,
    required String body,
    String type = 'system',
    String? route,
  }) async {
    final notif = AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      timestamp: DateTime.now(),
      isRead: false,
      type: type,
      route: route,
    );

    final current = List<AppNotification>.from(notificationsNotifier.value);
    current.insert(0, notif);
    notificationsNotifier.value = current;
    _updateUnreadCount();
    await _save();

    // Trigger local push notification alert if possible
    try {
      await NotificationService.showInstantNotification(
        title: title,
        body: body,
      );
    } catch (_) {}
  }

  /// Mark specific notification as read
  static Future<void> markAsRead(String id) async {
    final current = List<AppNotification>.from(notificationsNotifier.value);
    final idx = current.indexWhere((n) => n.id == id);
    if (idx != -1 && !current[idx].isRead) {
      current[idx].isRead = true;
      notificationsNotifier.value = current;
      _updateUnreadCount();
      await _save();
    }
  }

  /// Mark all notifications as read
  static Future<void> markAllAsRead() async {
    final current = List<AppNotification>.from(notificationsNotifier.value);
    bool changed = false;
    for (var n in current) {
      if (!n.isRead) {
        n.isRead = true;
        changed = true;
      }
    }
    if (changed) {
      notificationsNotifier.value = current;
      _updateUnreadCount();
      await _save();
    }
  }

  /// Delete a single notification
  static Future<void> deleteNotification(String id) async {
    final current = List<AppNotification>.from(notificationsNotifier.value);
    current.removeWhere((n) => n.id == id);
    notificationsNotifier.value = current;
    _updateUnreadCount();
    await _save();
  }

  /// Clear all notifications
  static Future<void> clearAll() async {
    notificationsNotifier.value = [];
    unreadCountNotifier.value = 0;
    await _save();
  }
}
