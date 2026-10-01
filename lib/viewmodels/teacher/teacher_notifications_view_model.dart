import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/app_notification.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/teacher_notification_repository.dart';
import '../base_view_model.dart';

/// The teacher's notification list and unread badge. App-wide, so the badge
/// on the home screen and the notifications screen share one live list.
class TeacherNotificationsViewModel extends BaseViewModel {
  TeacherNotificationsViewModel({
    required AuthRepository authRepository,
    required TeacherNotificationRepository notificationRepository,
  }) : _auth = authRepository,
       _notificationRepo = notificationRepository;

  final AuthRepository _auth;
  final TeacherNotificationRepository _notificationRepo;

  List<AppNotification> _notifications = [];
  StreamSubscription? _subscription;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Loads the notifications and starts listening for new ones. Safe to call
  /// again: it replaces the previous subscription.
  Future<void> init() async {
    final userId = _auth.currentUserId;
    if (userId == null) return;

    await refresh();

    await _subscription?.cancel();
    _subscription = _notificationRepo.watchNotifications(userId).listen((
      list,
    ) {
      _notifications = list;
      notifyListeners();
    });
  }

  Future<void> refresh() async {
    try {
      final accessToken = _auth.accessToken;
      if (accessToken == null) return;

      final list = await _notificationRepo.fetchNotifications(accessToken);
      if (list != null) {
        _notifications = list;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching teacher notifications: $e');
    }
  }

  /// Marks one notification read straight away, then tells the backend.
  Future<void> markAsRead(String id) async {
    final current = List<AppNotification>.from(_notifications);
    final idx = current.indexWhere((n) => n.id == id);
    if (idx != -1 && !current[idx].isRead) {
      current[idx].isRead = true;
      _notifications = current;
      notifyListeners();
    }

    try {
      final accessToken = _auth.accessToken;
      if (accessToken == null) return;
      await _notificationRepo.markRead(id, accessToken);
    } catch (e) {
      debugPrint('Error marking teacher notification read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    final current = List<AppNotification>.from(_notifications);
    for (final n in current) {
      n.isRead = true;
    }
    _notifications = current;
    notifyListeners();

    try {
      final accessToken = _auth.accessToken;
      if (accessToken == null) return;
      await _notificationRepo.markAllRead(accessToken);
    } catch (e) {
      debugPrint('Error marking all teacher notifications read: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
