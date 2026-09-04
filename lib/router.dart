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
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'services/api_service.dart';

void setupDeepLinkListener() {
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final AuthChangeEvent event = data.event;
    final Session? session = data.session;
    
    if (event == AuthChangeEvent.passwordRecovery && session != null) {
      router.go('/reset-password?access_token=${session.accessToken}');
    } else if (event == AuthChangeEvent.signedIn && session != null) {
      // Ensure backend profile is created/synced
      ApiService.syncGoogleUser(session.accessToken);
      
      // Navigate to home screen after sign in.
      router.go('/home');
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

final GoRouter router = GoRouter(
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(JomnesDB.auth.onAuthStateChange),
  redirect: (context, state) {
    final session = JomnesDB.auth.currentSession;
    final loggedIn = session != null;
    final isGoingToLogin = state.matchedLocation == '/login';
    final isGoingToRegister = state.matchedLocation == '/register';
    final isGoingToSplash = state.matchedLocation == '/';

    // If unauthenticated and trying to access a protected route
    if (!loggedIn && !isGoingToLogin && !isGoingToRegister && !isGoingToSplash) {
      return '/login';
    }
    // If authenticated and trying to access an auth page
    if (loggedIn && (isGoingToLogin || isGoingToRegister || isGoingToSplash)) {
      return '/home';
    }
    return null; // No redirection needed
  },
  routes: [
    GoRoute(path: '/', pageBuilder: (c, s) => _slide(s, const SplashScreen())),
    GoRoute(
      path: '/login',
      pageBuilder: (c, s) {
        final resetSuccess = s.uri.queryParameters['reset'] == 'success';
        return _slide(s, LoginScreen(passwordResetSuccess: resetSuccess));
      },
    ),
    GoRoute(path: '/register', pageBuilder: (c, s) => _slide(s, const RegisterScreen())),
    GoRoute(path: '/forgot-password', pageBuilder: (c, s) => _slide(s, const ForgotPasswordScreen())),
    GoRoute(
      path: '/reset-password',
      pageBuilder: (c, s) {
        String token = s.uri.queryParameters['access_token'] ?? '';
        
        // Supabase often puts tokens in the URI fragment (e.g. #access_token=...)
        if (token.isEmpty && s.uri.fragment.isNotEmpty) {
          final uri = Uri.parse('http://dummy?${s.uri.fragment}');
          token = uri.queryParameters['access_token'] ?? '';
        }
        
        return _slide(s, ResetPasswordScreen(accessToken: token));
      },
    ),
    GoRoute(path: '/home', pageBuilder: (c, s) => _slide(s, const HomeScreen())),
    GoRoute(path: '/search', pageBuilder: (c, s) => _slide(s, const SearchScreen())),
    GoRoute(path: '/courses', pageBuilder: (c, s) => _slide(s, const MyCoursesScreen())),
    GoRoute(path: '/profile', pageBuilder: (c, s) => _slide(s, const UserProfileScreen())),
    GoRoute(path: '/settings', pageBuilder: (c, s) => _slide(s, const SettingsScreen())),
    GoRoute(
      path: '/mentor/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return MentorProfileScreen(mentorId: id);
      },
    ),
  ],
);

CustomTransitionPage<void> _slide(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}