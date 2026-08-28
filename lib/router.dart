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

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _slidePage(state, const SplashScreen()),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _slidePage(state, const LoginScreen()),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => _slidePage(state, const RegisterScreen()),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => _slidePage(state, const HomeScreen()),
    ),
    GoRoute(
      path: '/search',
      pageBuilder: (context, state) => _slidePage(state, const SearchScreen()),
    ),
    GoRoute(
      path: '/courses',
      pageBuilder: (context, state) => _slidePage(state, const MyCoursesScreen()),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => _slidePage(state, const UserProfileScreen()),
    ),
    GoRoute(
      path: '/mentor/:id',
      pageBuilder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
        return _slidePage(state, MentorProfileScreen(mentorId: id));
      },
    ),
  ],
);

CustomTransitionPage<void> _slidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
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
