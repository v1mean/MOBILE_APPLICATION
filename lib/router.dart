import 'views/student/notifications_screen.dart';
import 'views/teacher/teacher_notifications_screen.dart';
import 'dart:async';
import 'dart:developer';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'package:provider/provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/booking_repository.dart';
import 'repositories/course_repository.dart';
import 'repositories/mentor_repository.dart';
import 'repositories/payment_repository.dart';
import 'repositories/student_notification_repository.dart';
import 'repositories/teacher_course_store.dart';
import 'repositories/user_repository.dart';
import 'services/guest_mode.dart';
import 'viewmodels/auth/forgot_password_view_model.dart';
import 'viewmodels/auth/login_view_model.dart';
import 'viewmodels/auth/register_view_model.dart';
import 'viewmodels/auth/reset_password_view_model.dart';
import 'viewmodels/student/course_listing_view_model.dart';
import 'viewmodels/student/home_view_model.dart';
import 'viewmodels/student/mentor_profile_view_model.dart';
import 'viewmodels/student/my_courses_view_model.dart';
import 'viewmodels/student/search_view_model.dart';
import 'viewmodels/teacher/teacher_home_view_model.dart';
import 'viewmodels/teacher/teacher_pc_request_view_model.dart';
import 'viewmodels/teacher/teacher_schedules_view_model.dart';
import 'viewmodels/teacher/teacher_students_view_model.dart';
import 'viewmodels/teacher/teacher_upload_course_view_model.dart';
export 'services/guest_mode.dart';
import 'views/auth/splash_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/student/home_screen.dart';
import 'views/student/search_screen.dart';
import 'views/student/mentor_profile_screen.dart';
import 'views/student/my_courses_screen.dart';
import 'views/settings/settings_screen.dart';
import 'views/auth/forgot_password_screen.dart';
import 'views/auth/reset_password_screen.dart';
import 'views/settings/edit_profile_screen.dart';
import 'views/settings/change_password_screen.dart';
import 'views/settings/privacy_security_screen.dart';
import 'views/settings/payment_methods_screen.dart';
import 'views/student/course_listing_screen.dart';
import 'views/auth/role_selection_screen.dart';
import 'views/auth/teacher_login_screen.dart';
import 'views/auth/teacher_register_screen.dart';
import 'views/auth/teacher_forgot_password_screen.dart';
import 'views/teacher/teacher_home_screen.dart';
import 'views/teacher/teacher_students_screen.dart';
import 'views/teacher/teacher_pc_request_screen.dart';
import 'views/teacher/teacher_schedules_screen.dart';
import 'views/teacher/teacher_upload_course_screen.dart';
import 'views/settings/teacher_settings_screen.dart';
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

final _authRefresh = GoRouterRefreshStream(JomnesDB.auth.onAuthStateChange);

bool _checkoutReturnHandled = false;

final GoRouter router = GoRouter(
  initialLocation: '/',
  refreshListenable: Listenable.merge([_authRefresh, guestModeNotifier]),
  redirect: (context, state) {
    final session = JomnesDB.auth.currentSession;
    final isGuest = isGuestMode;
    final loggedIn = session != null || isGuest;

    // Returning from Stripe Checkout reloads the web app with the paid session
    // in the page URL; send the student back to that mentor to pick a slot.
    if (kIsWeb && !_checkoutReturnHandled && session != null) {
      final params = Uri.base.queryParameters;
      final checkoutSessionId = params['checkout_session_id'];
      final tutorId = params['tutor_id'];
      if (checkoutSessionId != null && tutorId != null) {
        _checkoutReturnHandled = true;
        return '/mentor/$tutorId?checkout_session_id=$checkoutSessionId';
      }
    }
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
    GoRoute(
      path: '/teacher-home',
      pageBuilder: (c, s) => _instant(
        s,
        _screen(
          (c) => TeacherHomeViewModel(
            authRepository: c.read<AuthRepository>(),
            userRepository: c.read<UserRepository>(),
            courseRepository: c.read<CourseRepository>(),
            courseStore: c.read<TeacherCourseStore>(),
          )..load(),
          const TeacherHomeScreen(),
        ),
      ),
    ),
    GoRoute(
      path: '/teacher-students',
      pageBuilder: (c, s) => _instant(
        s,
        _screen(
          (c) => TeacherStudentsViewModel(
            authRepository: c.read<AuthRepository>(),
            userRepository: c.read<UserRepository>(),
            bookingRepository: c.read<BookingRepository>(),
          )..load(),
          const TeacherStudentsScreen(),
        ),
      ),
    ),
    GoRoute(
      path: '/teacher-pc-request',
      pageBuilder: (c, s) => _instant(
        s,
        _screen(
          (c) => TeacherPcRequestViewModel(
            authRepository: c.read<AuthRepository>(),
            userRepository: c.read<UserRepository>(),
            bookingRepository: c.read<BookingRepository>(),
          )..load(),
          const TeacherPcRequestScreen(),
        ),
      ),
    ),
    GoRoute(
      path: '/teacher-schedules',
      pageBuilder: (c, s) => _instant(
        s,
        _screen(
          (c) => TeacherSchedulesViewModel(
            authRepository: c.read<AuthRepository>(),
            userRepository: c.read<UserRepository>(),
            bookingRepository: c.read<BookingRepository>(),
          )..load(),
          const TeacherSchedulesScreen(),
        ),
      ),
    ),
    GoRoute(
      path: '/teacher-upload',
      pageBuilder: (c, s) => _instant(
        s,
        _screen(
          (c) => TeacherUploadCourseViewModel(
            authRepository: c.read<AuthRepository>(),
            userRepository: c.read<UserRepository>(),
            courseRepository: c.read<CourseRepository>(),
          )..loadHeader(),
          const TeacherUploadCourseScreen(),
        ),
      ),
    ),
    GoRoute(path: '/teacher-settings', pageBuilder: (c, s) => _instant(s, const TeacherSettingsScreen())),
    GoRoute(path: '/teacher-notifications', pageBuilder: (c, s) => _instant(s, const TeacherNotificationsScreen())),
    GoRoute(
      path: '/login',
      pageBuilder: (c, s) {
        final resetSuccess = s.uri.queryParameters['reset'] == 'success';
        final role = s.uri.queryParameters['role'] ?? 'student';
        return _instant(
          s,
          _screen(
            (c) => LoginViewModel(authRepository: c.read<AuthRepository>()),
            LoginScreen(passwordResetSuccess: resetSuccess, role: role),
          ),
        );
      },
    ),
    GoRoute(
      path: '/register', 
      pageBuilder: (c, s) {
        final role = s.uri.queryParameters['role'] ?? 'student';
        return _instant(
          s,
          _screen(
            (c) => RegisterViewModel(authRepository: c.read<AuthRepository>()),
            RegisterScreen(role: role),
          ),
        );
      }
    ),
    GoRoute(
      path: '/forgot-password',
      pageBuilder: (c, s) => _instant(
        s,
        _screen(
          (c) => ForgotPasswordViewModel(
            authRepository: c.read<AuthRepository>(),
          ),
          const ForgotPasswordScreen(),
        ),
      ),
    ),
    GoRoute(
      path: '/reset-password',
      pageBuilder: (c, s) {
        String token = s.uri.queryParameters['access_token'] ?? '';
        
        // Supabase often puts tokens in the URI fragment (e.g. #access_token=...)
        if (token.isEmpty && s.uri.fragment.isNotEmpty) {
          final uri = Uri.parse('http://dummy?${s.uri.fragment}');
          token = uri.queryParameters['access_token'] ?? '';
        }
        
        return _instant(
          s,
          _screen(
            (c) => ResetPasswordViewModel(
              authRepository: c.read<AuthRepository>(),
            ),
            ResetPasswordScreen(accessToken: token),
          ),
        );
      },
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (c, s) => _instant(
        s,
        _screen(
          (c) => HomeViewModel(
            authRepository: c.read<AuthRepository>(),
            userRepository: c.read<UserRepository>(),
            mentorRepository: c.read<MentorRepository>(),
            courseRepository: c.read<CourseRepository>(),
          )..load(),
          const HomeScreen(),
        ),
      ),
    ),
    GoRoute(
      path: '/search',
      pageBuilder: (c, s) => _instant(
        s,
        _screen(
          (c) => SearchViewModel(
            authRepository: c.read<AuthRepository>(),
            userRepository: c.read<UserRepository>(),
            mentorRepository: c.read<MentorRepository>(),
          )..load(),
          const SearchScreen(),
        ),
      ),
    ),
    GoRoute(
      path: '/courses',
      pageBuilder: (c, s) => _instant(
        s,
        _screen(
          (c) => MyCoursesViewModel(
            authRepository: c.read<AuthRepository>(),
            userRepository: c.read<UserRepository>(),
            courseRepository: c.read<CourseRepository>(),
            mentorRepository: c.read<MentorRepository>(),
          )..loadUserProfile(),
          const MyCoursesScreen(),
        ),
      ),
    ),
    GoRoute(path: '/notifications', pageBuilder: (c, s) => _instant(s, const NotificationsScreen())),
    GoRoute(path: '/profile', redirect: (c, s) => '/settings'),
    GoRoute(path: '/settings', pageBuilder: (c, s) => _instant(s, const SettingsScreen())),
    GoRoute(path: '/edit-profile', pageBuilder: (c, s) => _instant(s, const EditProfileScreen())),
    GoRoute(path: '/change-password', pageBuilder: (c, s) => _instant(s, const ChangePasswordScreen())),
    GoRoute(path: '/privacy-security', pageBuilder: (c, s) => _instant(s, const PrivacySecurityScreen())),
    GoRoute(path: '/payment-methods', pageBuilder: (c, s) => _instant(s, const PaymentMethodsScreen())),
    GoRoute(
      path: '/mentor/:id',
      pageBuilder: (c, s) {
        final id = s.pathParameters['id']!;
        final checkoutSessionId = s.uri.queryParameters['checkout_session_id'];
        return _instant(
          s,
          _screen(
            (c) => MentorProfileViewModel(
              mentorId: id,
              checkoutSessionId: checkoutSessionId,
              authRepository: c.read<AuthRepository>(),
              mentorRepository: c.read<MentorRepository>(),
              bookingRepository: c.read<BookingRepository>(),
              paymentRepository: c.read<PaymentRepository>(),
              notificationRepository: c.read<StudentNotificationRepository>(),
            ),
            const MentorProfileScreen(),
          ),
        );
      },
    ),
    GoRoute(
      path: '/course-listing',
      pageBuilder: (c, s) {
        final rawSubject = s.uri.queryParameters['subject'] ?? 'Courses';
        final subject = Uri.decodeComponent(rawSubject);
        return _instant(s, _courseListing(subject));
      },
    ),
    GoRoute(
      path: '/course-listing/:subject',
      pageBuilder: (c, s) {
        final rawSubject = s.pathParameters['subject'] ?? 'Courses';
        final subject = Uri.decodeComponent(rawSubject);
        return _instant(s, _courseListing(subject));
      },
    ),
  ],
);

Widget _courseListing(String subject) {
  return _screen(
    (c) => CourseListingViewModel(
      subject: subject,
      mentorRepository: c.read<MentorRepository>(),
      courseRepository: c.read<CourseRepository>(),
    )..load(),
    CourseListingScreen(subject: subject),
  );
}

/// Pairs a screen with the view model it listens to. The router is the one
/// place that knows which repositories each view model needs; the view model
/// lives as long as its page does.
Widget _screen<T extends ChangeNotifier>(
  T Function(BuildContext context) create,
  Widget view,
) {
  return ChangeNotifierProvider<T>(create: create, child: view);
}

NoTransitionPage<void> _instant(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(
    key: state.pageKey,
    child: child,
  );
}
