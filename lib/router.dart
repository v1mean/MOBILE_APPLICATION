import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
import 'services/api_service.dart';

void setupDeepLinkListener() {
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final AuthChangeEvent event = data.event;
    final Session? session = data.session;
    
    if (event == AuthChangeEvent.passwordRecovery && session != null) {
      router.go('/reset-password?access_token=${session.accessToken}');
    } else if (event == AuthChangeEvent.signedIn && session != null) {
      // Ensure backend profile is created/synced for social logins
      ApiService.syncSocialUser(session.accessToken);
      
      // Navigate to home screen after sign in.
      router.go('/home');
    } else if (event == AuthChangeEvent.signedOut) {
      router.go('/login');
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

    final isAuthPage = isGoingToLogin ||
        isGoingToRegister ||
        isGoingToSplash ||
        isGoingToForgotPassword ||
        isGoingToResetPassword;

    // If unauthenticated (and not guest) and trying to access a protected route
    if (!loggedIn && !isAuthPage) {
      return '/login';
    }
    // If logged in (real session OR guest) and on an auth/splash page → go home
    if (loggedIn && (isGoingToLogin || isGoingToRegister || isGoingToSplash)) {
      return '/home';
    }
    return null; // No redirection needed
  },
  routes: [
    GoRoute(path: '/', pageBuilder: (c, s) => _instant(s, const SplashScreen())),
    GoRoute(
      path: '/login',
      pageBuilder: (c, s) {
        final resetSuccess = s.uri.queryParameters['reset'] == 'success';
        return _instant(s, LoginScreen(passwordResetSuccess: resetSuccess));
      },
    ),
    GoRoute(path: '/register', pageBuilder: (c, s) => _instant(s, const RegisterScreen())),
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