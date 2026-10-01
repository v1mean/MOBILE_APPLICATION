// Which pages need which kind of visitor. Kept apart from the router so the
// rules can be tested without Supabase.

/// Pages anyone can open.
const _publicPages = {
  '/',
  '/role-select',
  '/login',
  '/register',
  '/forgot-password',
  '/reset-password',
  '/teacher-login',
  '/teacher-register',
  '/teacher-forgot-password',
};

/// The teacher area. It needs a signed-in account: guest mode only browses
/// the student side.
const _teacherPages = {
  '/teacher-home',
  '/teacher-students',
  '/teacher-pc-request',
  '/teacher-schedules',
  '/teacher-upload',
  '/teacher-settings',
  '/teacher-notifications',
};

bool _isTeacher(String? role) => role == 'mentor' || role == 'teacher';

/// Where a navigation to [location] should be sent instead, or null to let it
/// through.
///
/// [hasSession] is a signed-in account, [isGuest] is guest mode, and
/// [appRole] is the role on the session, when it carries one.
String? guardRoute({
  required String location,
  required bool hasSession,
  required bool isGuest,
  String? appRole,
}) {
  final loggedIn = hasSession || isGuest;

  if (_teacherPages.contains(location) && !hasSession) {
    return '/login?role=teacher';
  }

  if (!loggedIn && !_publicPages.contains(location)) {
    return '/login';
  }

  // Already in: skip the login and register screens.
  if (loggedIn && (location == '/login' || location == '/register')) {
    return _isTeacher(appRole) ? '/teacher-home' : '/home';
  }

  return null;
}
