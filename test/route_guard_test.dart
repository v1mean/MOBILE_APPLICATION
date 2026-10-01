import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_application/route_guard.dart';

void main() {
  String? visit(
    String location, {
    bool hasSession = false,
    bool isGuest = false,
    String? appRole,
  }) {
    return guardRoute(
      location: location,
      hasSession: hasSession,
      isGuest: isGuest,
      appRole: appRole,
    );
  }

  const teacherPages = [
    '/teacher-home',
    '/teacher-students',
    '/teacher-pc-request',
    '/teacher-schedules',
    '/teacher-upload',
    '/teacher-settings',
    '/teacher-notifications',
  ];

  test('the sign-in pages are open to everyone', () {
    for (final page in [
      '/',
      '/role-select',
      '/login',
      '/register',
      '/forgot-password',
      '/reset-password',
      '/teacher-login',
      '/teacher-register',
      '/teacher-forgot-password',
    ]) {
      expect(visit(page), isNull, reason: page);
    }
  });

  test('a visitor who is not signed in is sent to the login screen', () {
    for (final page in ['/home', '/search', '/courses', '/settings']) {
      expect(visit(page), '/login', reason: page);
    }
    expect(visit('/mentor/abc'), '/login');
    expect(visit('/course-listing/Math'), '/login');
  });

  test('the teacher area needs a signed-in account', () {
    for (final page in teacherPages) {
      expect(visit(page), '/login?role=teacher', reason: page);
      expect(visit(page, hasSession: true, appRole: 'mentor'), isNull);
    }
  });

  test('a guest browses the student side but not the teacher area', () {
    expect(visit('/home', isGuest: true), isNull);
    expect(visit('/mentor/abc', isGuest: true), isNull);

    for (final page in teacherPages) {
      expect(visit(page, isGuest: true), '/login?role=teacher', reason: page);
    }
    // ...and from that login screen a guest goes back to the student home.
    expect(visit('/login', isGuest: true), '/home');
  });

  test('a signed-in user skips the login and register screens', () {
    expect(visit('/login', hasSession: true, appRole: 'student'), '/home');
    expect(visit('/register', hasSession: true), '/home');
    expect(
      visit('/login', hasSession: true, appRole: 'mentor'),
      '/teacher-home',
    );
    expect(
      visit('/login', hasSession: true, appRole: 'teacher'),
      '/teacher-home',
    );
  });

  test('a signed-in user reaches every other page', () {
    for (final page in ['/home', '/search', '/settings', '/mentor/abc']) {
      expect(visit(page, hasSession: true), isNull, reason: page);
    }
  });
}
