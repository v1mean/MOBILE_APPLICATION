import '../../models/mentor.dart';
import '../../models/user_profile.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/course_repository.dart';
import '../../repositories/mentor_repository.dart';
import '../../repositories/user_repository.dart';
import '../base_view_model.dart';

class MyCoursesViewModel extends BaseViewModel {
  MyCoursesViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required CourseRepository courseRepository,
    required MentorRepository mentorRepository,
  }) : _auth = authRepository,
       _users = userRepository,
       _courses = courseRepository,
       _mentors = mentorRepository {
    coursesFuture = _fetchMyCourses();
  }

  final AuthRepository _auth;
  final UserRepository _users;
  final CourseRepository _courses;
  final MentorRepository _mentors;

  UserProfile? _userProfile;

  /// The enrolled courses; replaced on every reload so the list shows its
  /// loading state again.
  late Future<List<Course>> coursesFuture;

  String get displayName {
    if (_userProfile?.name != null && _userProfile!.name.isNotEmpty) {
      return _userProfile!.name;
    }
    return _auth.metadataName ?? 'Student';
  }

  String get displayRole {
    if (_userProfile?.role != null && _userProfile!.role.isNotEmpty) {
      return _userProfile!.role;
    }
    return 'Student';
  }

  String? get avatarUrl {
    if (_userProfile?.profileImage != null &&
        _userProfile!.profileImage.isNotEmpty) {
      return _userProfile!.profileImage;
    }
    final metaAvatar = _auth.metadataAvatar;
    return metaAvatar != null && metaAvatar.isNotEmpty ? metaAvatar : null;
  }

  Future<List<Course>> _fetchMyCourses() async {
    final accessToken = _auth.accessToken;
    if (accessToken == null) return [];
    try {
      return await _courses.fetchMyCourses(accessToken);
    } catch (e) {
      return [];
    }
  }

  Future<void> loadUserProfile() async {
    final userId = _auth.currentUserId;
    if (userId == null) return;

    try {
      final data = await _users.fetchProfileRow(userId);
      if (data != null) {
        _userProfile = UserProfile(
          userId: data['id'],
          createdAt: data['created_at'] != null
              ? DateTime.tryParse(data['created_at']) ?? DateTime.now()
              : DateTime.now(),
          name: data['full_name'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'] ?? '',
          role: data['role'] ?? 'Student',
          profileImage: data['avatar_url'] ?? '',
          location: data['city'] ?? '',
        );
      }
      notifyListeners();
    } catch (_) {}
  }

  /// Pull-to-refresh: reloads the courses and the header profile.
  Future<void> refresh() async {
    coursesFuture = _fetchMyCourses();
    notifyListeners();
    await Future.wait([loadUserProfile(), coursesFuture]);
  }

  /// Sends a review for the course's mentor. Completes with false when there
  /// is nothing to send it to (no session, or the course has no mentor).
  Future<bool> submitReview({
    required Course course,
    required double rating,
    required String comment,
  }) async {
    final accessToken = _auth.accessToken;
    if (accessToken == null || course.tutorId == null) return false;

    await _mentors.submitReview(
      accessToken: accessToken,
      mentorId: course.tutorId!,
      rating: rating,
      comment: comment,
    );
    return true;
  }
}
