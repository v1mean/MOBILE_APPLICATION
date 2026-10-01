import '../../models/app_notification.dart';
import '../../repositories/student_notification_repository.dart';
import '../base_view_model.dart';

/// The student's notification list and unread badge. App-wide, because the
/// bell appears on several screens.
class StudentNotificationsViewModel extends BaseViewModel {
  StudentNotificationsViewModel({
    required StudentNotificationRepository repository,
  }) : _store = repository {
    _store.addListener(notifyListeners);
  }

  final StudentNotificationRepository _store;

  List<AppNotification> get notifications => _store.notifications;
  int get unreadCount => _store.unreadCount;

  Future<void> markAsRead(String id) => _store.markAsRead(id);
  Future<void> markAllAsRead() => _store.markAllAsRead();
  Future<void> delete(String id) => _store.delete(id);

  @override
  void dispose() {
    _store.removeListener(notifyListeners);
    super.dispose();
  }
}
