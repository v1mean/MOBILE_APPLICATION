import 'dart:async';
import 'dart:developer';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/mentor_profile_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/my_courses_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/privacy_security_screen.dart';
import 'screens/payment_methods_screen.dart';
import 'screens/course_listing_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/teacher_login_screen.dart';
import 'screens/teacher_register_screen.dart';
import 'screens/teacher_forgot_password_screen.dart';
import 'screens/teacher_home_screen.dart';
import 'screens/teacher_students_screen.dart';
import 'screens/teacher_pc_request_screen.dart';
import 'screens/teacher_schedules_screen.dart';
import 'screens/teacher_upload_course_screen.dart';
import 'screens/teacher_settings_screen.dart';
import 'services/api_service.dart';

void setupDeepLinkListener() {
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final AuthChangeEvent event = data.event;
    final Session? session = data.session;

    log('DEBUG: onAuthStateChange fired — event=$event, hasSession=${session != null}');
    // ignore: avoid_print
    if (kDebugMode) debugPrint('AUTH_EVENT: $event hasSession=${session != null}');

    if (event == AuthChangeEvent.passwordRecovery && session != null) {
      router.go('/reset-password?access_token=${session.accessToken}');
    } else if (event == AuthChangeEvent.signedIn && session != null) {
      // Fetch role from SharedPreferences
      SharedPreferences.getInstance().then((prefs) async {
        final role = prefs.getString('pending_role') ?? 'student';
        await ApiService.syncSocialUser(session.accessToken, role);
        await prefs.remove('pending_role');

        String finalRole = role;
        try {
          final data = await JomnesDB.from('profiles').select('role').eq('id', session.user.id).maybeSingle();
          if (data != null && data['role'] != null) {
            finalRole = data['role'];
          }
        } catch (_) {}

        if (finalRole == 'mentor' || finalRole == 'teacher') {
          router.go('/teacher-home');
        } else {
          router.go('/home');
        }
      });
    } else if (event == AuthChangeEvent.signedOut) {
      router.go('/');
    }
  });
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// A ChangeNotifier that tracks guest mode so GoRouter re-evaluates redirects.
class GuestModeNotifier extends ChangeNotifier {
  bool _isGuest = false;
  bool get isGuest => _isGuest;

  void setGuest(bool value) {
    if (_isGuest != value) {
      _isGuest = value;
      notifyListeners();
    }
  }
}

final guestModeNotifier = GuestModeNotifier();

// Keep a top-level getter for convenience across the app
bool get isGuestMode => guestModeNotifier.isGuest;
set isGuestMode(bool value) => guestModeNotifier.setGuest(value);

final _authRefresh = GoRouterRefreshStream(JomnesDB.auth.onAuthStateChange);

final GoRouter router = GoRouter(
  initialLocation: '/',
  refreshListenable: Listenable.merge([_authRefresh, guestModeNotifier]),
  redirect: (context, state) {
    final session = JomnesDB.auth.currentSession;
    final isGuest = isGuestMode;
    final loggedIn = session != null || isGuest;
    final isGoingToLogin = state.matchedLocation == '/login';
    final isGoingToRegister = state.matchedLocation == '/register';
    final isGoingToSplash = state.matchedLocation == '/';
    final isGoingToForgotPassword = state.matchedLocation == '/forgot-password';
    final isGoingToResetPassword = state.matchedLocation == '/reset-password';
    final isGoingToRoleSelect = state.matchedLocation == '/role-select';
    final isGoingToTeacherLogin = state.matchedLocation == '/teacher-login';
    final isGoingToTeacherRegister = state.matchedLocation == '/teacher-register';
    final isGoingToTeacherForgotPassword = state.matchedLocation == '/teacher-forgot-password';
    final isGoingToTeacherHome = state.matchedLocation == '/teacher-home';
    final isGoingToTeacherStudents = state.matchedLocation == '/teacher-students';
    final isGoingToTeacherPcRequest = state.matchedLocation == '/teacher-pc-request';
    final isGoingToTeacherSchedules = state.matchedLocation == '/teacher-schedules';
    final isGoingToTeacherUpload = state.matchedLocation == '/teacher-upload';
    final isGoingToTeacherSettings = state.matchedLocation == '/teacher-settings';

    final isAuthPage = isGoingToLogin ||
        isGoingToRegister ||
        isGoingToSplash ||
        isGoingToForgotPassword ||
        isGoingToResetPassword ||
        isGoingToRoleSelect ||
        isGoingToTeacherLogin ||
        isGoingToTeacherRegister ||
        isGoingToTeacherForgotPassword ||
        isGoingToTeacherHome ||
        isGoingToTeacherStudents ||
        isGoingToTeacherPcRequest ||
        isGoingToTeacherSchedules ||
        isGoingToTeacherUpload ||
        isGoingToTeacherSettings;

    // If unauthenticated (and not guest) and trying to access a protected route
    if (!loggedIn && !isAuthPage) {
      return '/login';
    }
    // If logged in (real session OR guest) and on student login/register -> go home
    if (loggedIn && (isGoingToLogin || isGoingToRegister)) {
      final appRole = session?.user.appMetadata['role'];
      if (appRole == 'mentor' || appRole == 'teacher') {
        return '/teacher-home';
      }
      return '/home';
    }
    return null; // No redirection needed
  },
  routes: [
    GoRoute(path: '/', pageBuilder: (c, s) => _instant(s, const SplashScreen())),
    GoRoute(path: '/role-select', pageBuilder: (c, s) => _instant(s, const RoleSelectionScreen())),
    GoRoute(path: '/teacher-login', pageBuilder: (c, s) => _instant(s, const TeacherLoginScreen())),
    GoRoute(path: '/teacher-register', pageBuilder: (c, s) => _instant(s, const TeacherRegisterScreen())),
    GoRoute(path: '/teacher-forgot-password', pageBuilder: (c, s) => _instant(s, const TeacherForgotPasswordScreen())),
    GoRoute(path: '/teacher-home', pageBuilder: (c, s) => _instant(s, const TeacherHomeScreen())),
    GoRoute(path: '/teacher-students', pageBuilder: (c, s) => _instant(s, const TeacherStudentsScreen())),
    GoRoute(path: '/teacher-pc-request', pageBuilder: (c, s) => _instant(s, const TeacherPcRequestScreen())),
    GoRoute(path: '/teacher-schedules', pageBuilder: (c, s) => _instant(s, const TeacherSchedulesScreen())),
    GoRoute(path: '/teacher-upload', pageBuilder: (c, s) => _instant(s, const TeacherUploadCourseScreen())),
    GoRoute(path: '/teacher-settings', pageBuilder: (c, s) => _instant(s, const TeacherSettingsScreen())),
    GoRoute(
      path: '/login',
      pageBuilder: (c, s) {
        final resetSuccess = s.uri.queryParameters['reset'] == 'success';
        final role = s.uri.queryParameters['role'] ?? 'student';
        return _instant(s, LoginScreen(passwordResetSuccess: resetSuccess, role: role));
      },
    ),
    GoRoute(
      path: '/register', 
      pageBuilder: (c, s) {
        final role = s.uri.queryParameters['role'] ?? 'student';
        return _instant(s, RegisterScreen(role: role));
      }
    ),
    GoRoute(path: '/forgot-password', pageBuilder: (c, s) => _instant(s, const ForgotPasswordScreen())),
    GoRoute(
      path: '/reset-password',
      pageBuilder: (c, s) {
        String token = s.uri.queryParameters['access_token'] ?? '';
        
        // Supabase often puts tokens in the URI fragment (e.g. #access_token=...)
        if (token.isEmpty && s.uri.fragment.isNotEmpty) {
          final uri = Uri.parse('http://dummy?${s.uri.fragment}');
          token = uri.queryParameters['access_token'] ?? '';
        }
        
        return _instant(s, ResetPasswordScreen(accessToken: token));
      },
    ),
    GoRoute(path: '/home', pageBuilder: (c, s) => _instant(s, const HomeScreen())),
    GoRoute(path: '/search', pageBuilder: (c, s) => _instant(s, const SearchScreen())),
    GoRoute(path: '/courses', pageBuilder: (c, s) => _instant(s, const MyCoursesScreen())),
    GoRoute(path: '/profile', pageBuilder: (c, s) => _instant(s, const UserProfileScreen())),
    GoRoute(path: '/settings', pageBuilder: (c, s) => _instant(s, const SettingsScreen())),
    GoRoute(path: '/edit-profile', pageBuilder: (c, s) => _instant(s, const EditProfileScreen())),
    GoRoute(path: '/change-password', pageBuilder: (c, s) => _instant(s, const ChangePasswordScreen())),
    GoRoute(path: '/privacy-security', pageBuilder: (c, s) => _instant(s, const PrivacySecurityScreen())),
    GoRoute(path: '/payment-methods', pageBuilder: (c, s) => _instant(s, const PaymentMethodsScreen())),
    GoRoute(
      path: '/mentor/:id',
      pageBuilder: (c, s) {
        final id = s.pathParameters['id']!;
        return _instant(s, MentorProfileScreen(mentorId: id));
      },
    ),
    GoRoute(
      path: '/course-listing',
      pageBuilder: (c, s) {
        final rawSubject = s.uri.queryParameters['subject'] ?? 'Courses';
        final subject = Uri.decodeComponent(rawSubject);
        return _instant(s, CourseListingScreen(subject: subject));
      },
    ),
    GoRoute(
      path: '/course-listing/:subject',
      pageBuilder: (c, s) {
        final rawSubject = s.pathParameters['subject'] ?? 'Courses';
        final subject = Uri.decodeComponent(rawSubject);
        return _instant(s, CourseListingScreen(subject: subject));
      },
    ),
  ],
);

NoTransitionPage<void> _instant(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(
    key: state.pageKey,
    child: child,
  );
}
