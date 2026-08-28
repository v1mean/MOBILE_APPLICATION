import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/mentor_profile_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/my_courses_screen.dart';
import 'screens/settings_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
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
      pageBuilder: (c, s) {
        final id = int.tryParse(s.pathParameters['id'] ?? '1') ?? 1;
        return _slide(s, MentorProfileScreen(mentorId: id));
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