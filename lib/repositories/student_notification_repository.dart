import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';

/// The student's in-app notifications. They are kept on the device (not on
/// the server), so this repository is the single source of truth for them
/// and notifies listeners when they change.
class StudentNotificationRepository extends ChangeNotifier {
  static const String _storageKey = 'jomnes_student_notifications_v1';

  List<AppNotification> _notifications = [];
  bool _initialized = false;

  List<AppNotification> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Loads saved notifications, or seeds the default ones on first run.
  Future<void> init() async {
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
        _notifications = list;
      } else {
        // Seed default initial notifications so student has a welcoming experience
        final now = DateTime.now();
        _notifications = [
          AppNotification(
            id: 'seed_welcome',
            title: 'Welcome to Jomnes! 👋',
            body:
                'Discover top mentors and book one-on-one sessions in academic subjects, languages, and sports.',
            timestamp: now.subtract(const Duration(hours: 1)),
            isRead: false,
            type: 'system',
            route: '/home',
          ),
          AppNotification(
            id: 'seed_courses',
            title: 'Explore Featured Courses 🚀',
            body:
                'Check out newly added courses in Math, Chinese, English, and Football coaching.',
            timestamp: now.subtract(const Duration(hours: 3)),
            isRead: false,
            type: 'course',
            route: '/course-listing',
          ),
          AppNotification(
            id: 'seed_reminder',
            title: 'Learning Reminder 💡',
            body:
                'Consistency is key! Find a mentor who matches your schedule and boost your skills today.',
            timestamp: now.subtract(const Duration(days: 1)),
            isRead: true,
            type: 'reminder',
            route: '/search',
          ),
        ];
        await _save();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing StudentNotificationRepository: $e');
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stringList = _notifications.map((n) => n.toJson()).toList();
      await prefs.setStringList(_storageKey, stringList);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  /// Adds a notification to the list and shows it as a device notification.
  Future<void> add({
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

    _notifications = [notif, ..._notifications];
    notifyListeners();
    await _save();

    // Trigger local push notification alert if possible
    try {
      await showDeviceNotification(title: title, body: body);
    } catch (_) {}
  }

  /// Shows a notification in the device's notification tray.
  Future<void> showDeviceNotification({
    required String title,
    required String body,
  }) => NotificationService.showInstantNotification(title: title, body: body);

  Future<void> markAsRead(String id) async {
    final current = List<AppNotification>.from(_notifications);
    final idx = current.indexWhere((n) => n.id == id);
    if (idx != -1 && !current[idx].isRead) {
      current[idx].isRead = true;
      _notifications = current;
      notifyListeners();
      await _save();
    }
  }

  Future<void> markAllAsRead() async {
    final current = List<AppNotification>.from(_notifications);
    bool changed = false;
    for (var n in current) {
      if (!n.isRead) {
        n.isRead = true;
        changed = true;
      }
    }
    if (changed) {
      _notifications = current;
      notifyListeners();
      await _save();
    }
  }

  Future<void> delete(String id) async {
    final current = List<AppNotification>.from(_notifications);
    current.removeWhere((n) => n.id == id);
    _notifications = current;
    notifyListeners();
    await _save();
  }
}
