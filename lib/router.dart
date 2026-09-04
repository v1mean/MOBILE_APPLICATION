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
    GoRoute(path: '/login', pageBuilder: (c, s) => _slide(s, const LoginScreen())),
    GoRoute(path: '/register', pageBuilder: (c, s) => _slide(s, const RegisterScreen())),
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