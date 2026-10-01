import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_application/repositories/student_notification_repository.dart';
import 'package:mobile_application/viewmodels/student/student_notifications_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StudentNotificationRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = StudentNotificationRepository();
    await repository.init();
  });

  test('a new install starts with the welcome notifications', () {
    expect(repository.notifications.length, 3);
    expect(repository.unreadCount, 2);
  });

  test('marking one as read lowers the unread count', () async {
    await repository.markAsRead('seed_welcome');

    expect(repository.unreadCount, 1);
  });

  test('marking all as read clears the badge', () async {
    await repository.markAllAsRead();

    expect(repository.unreadCount, 0);
  });

  test('a new notification goes to the top, unread', () async {
    await repository.add(title: 'Booking Confirmed!', body: 'See you soon.');

    expect(repository.notifications.first.title, 'Booking Confirmed!');
    expect(repository.unreadCount, 3);
  });

  test('deleting removes it from the list', () async {
    await repository.delete('seed_courses');

    expect(repository.notifications.map((n) => n.id), [
      'seed_welcome',
      'seed_reminder',
    ]);
  });

  test('saved notifications survive a restart', () async {
    await repository.markAllAsRead();

    final restarted = StudentNotificationRepository();
    await restarted.init();

    expect(restarted.notifications.length, 3);
    expect(restarted.unreadCount, 0);
  });

  test('the view model follows the repository', () async {
    final vm = StudentNotificationsViewModel(repository: repository);
    addTearDown(vm.dispose);
    var notified = 0;
    vm.addListener(() => notified++);

    await vm.markAsRead('seed_welcome');

    expect(vm.unreadCount, 1);
    expect(notified, greaterThan(0));
  });
}
