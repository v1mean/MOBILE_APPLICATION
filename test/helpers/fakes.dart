import 'package:mobile_application/models/mentor.dart';
import 'package:mobile_application/repositories/auth_repository.dart';
import 'package:mobile_application/repositories/booking_repository.dart';
import 'package:mobile_application/repositories/course_repository.dart';
import 'package:mobile_application/repositories/mentor_repository.dart';
import 'package:mobile_application/repositories/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositories that answer from memory, so view models can be tested
/// without Supabase or the backend.

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository({
    this.userId,
    this.token,
    this.name,
    this.avatar,
    this.guest = false,
    this.loginResponse,
    this.loginError,
    this.storedRole,
  });

  final String? userId;
  final String? token;
  final String? name;
  final String? avatar;
  final bool guest;
  final Map<String, dynamic>? loginResponse;
  final Object? loginError;
  final String? storedRole;

  @override
  Session? get currentSession => null;

  @override
  String? get currentUserId => userId;

  @override
  String? get accessToken => token;

  @override
  String? get currentEmail => null;

  @override
  String? get metadataName => name;

  @override
  String? get metadataAvatar => avatar;

  @override
  bool get isGuest => guest;

  @override
  Future<Map<String, dynamic>> loginWithEmail(
    String email,
    String password,
    String role,
  ) async {
    if (loginError != null) throw loginError!;
    return loginResponse!;
  }

  @override
  Future<String> resolveRole({required String fallback}) async =>
      storedRole ?? fallback;
}

class FakeUserRepository extends UserRepository {
  FakeUserRepository({this.userRow, this.profileRow});

  final Map<String, dynamic>? userRow;
  final Map<String, dynamic>? profileRow;

  @override
  Future<Map<String, dynamic>?> fetchUserRow(
    String userId, {
    String columns = '*',
  }) async => userRow;

  @override
  Future<Map<String, dynamic>?> fetchProfileRow(
    String userId, {
    String columns = '*',
  }) async => profileRow;
}

class FakeMentorRepository extends MentorRepository {
  FakeMentorRepository(this.mentors);

  final List<Mentor> mentors;

  @override
  Future<List<Mentor>> fetchMentorDirectory() async => mentors;
}

class FakeCourseRepository extends CourseRepository {
  FakeCourseRepository({this.featured = const [], this.featuredError});

  final List<FeaturedCourse> featured;
  final Object? featuredError;

  @override
  Future<List<FeaturedCourse>> fetchFeaturedCourses() async {
    if (featuredError != null) throw featuredError!;
    return featured;
  }
}

class FakeBookingRepository extends BookingRepository {
  FakeBookingRepository({this.bookings = const [], this.error});

  final List<Map<String, dynamic>> bookings;
  final Object? error;

  @override
  Future<List<Map<String, dynamic>>> fetchTeacherBookings(
    String accessToken,
  ) async {
    if (error != null) throw error!;
    return bookings;
  }
}

Mentor mentor({
  required String id,
  required String name,
  String subject = 'Math',
  double price = 20,
  String bio = '',
}) {
  return Mentor(
    id: id,
    name: name,
    subject: subject,
    experience: '1 years experience',
    timeSlot: 'Flexible',
    avatarUrl: '',
    rating: 5,
    students: 0,
    classes: 0,
    followers: 0,
    bookingPrice: price,
    bio: bio,
    courses: const [],
  );
}
