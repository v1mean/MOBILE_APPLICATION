import 'package:flutter/foundation.dart';
import '../../constants/course_categories.dart';
import '../../models/mentor.dart';
import '../../models/user_profile.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/course_repository.dart';
import '../../repositories/mentor_repository.dart';
import '../../repositories/user_repository.dart';
import '../base_view_model.dart';

class HomeViewModel extends BaseViewModel {
  HomeViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required MentorRepository mentorRepository,
    required CourseRepository courseRepository,
  }) : _auth = authRepository,
       _users = userRepository,
       _mentors = mentorRepository,
       _courses = courseRepository;

  final AuthRepository _auth;
  final UserRepository _users;
  final MentorRepository _mentors;
  final CourseRepository _courses;

  UserProfile? _userProfile;
  bool _isLoadingProfile = true;

  List<Mentor> _popularMentors = [];
  bool _isLoadingMentors = true;

  List<FeaturedCourse> _featuredCourses = [];
  bool _isLoadingFeatured = true;

  List<Mentor> get popularMentors => _popularMentors;
  bool get isLoadingMentors => _isLoadingMentors;
  List<FeaturedCourse> get featuredCourses => _featuredCourses;
  bool get isLoadingFeatured => _isLoadingFeatured;

  String get role => _userProfile?.role ?? 'Student';

  String get displayName {
    if (_userProfile?.name != null && _userProfile!.name.isNotEmpty) {
      return _userProfile!.name;
    }
    final metaName = _auth.metadataName;
    if (metaName != null && metaName.isNotEmpty) {
      return metaName;
    }
    return _auth.isGuest
        ? 'Guest'
        : (_isLoadingProfile ? 'Loading...' : 'Student');
  }

  String? get displayAvatar {
    if (_userProfile?.profileImage != null &&
        _userProfile!.profileImage.isNotEmpty) {
      return _userProfile!.profileImage;
    }
    final metaAvatar = _auth.metadataAvatar;
    if (metaAvatar != null && metaAvatar.isNotEmpty) {
      return metaAvatar;
    }
    return null; // No avatar — show initial letter circle
  }

  /// Loads the three sections side by side; each one appears as soon as its
  /// own data arrives. Also used for pull-to-refresh.
  Future<void> load() {
    return Future.wait([
      loadUserProfile(),
      loadPopularMentors(),
      loadFeaturedCourses(),
    ]);
  }

  Future<void> loadUserProfile() async {
    final userId = _auth.currentUserId;
    if (userId == null) {
      _isLoadingProfile = false;
      notifyListeners();
      return;
    }

    try {
      final data = await _users.fetchUserRow(userId);
      if (data != null) {
        _userProfile = UserProfile.fromJson(data);
      }
      _isLoadingProfile = false;
      notifyListeners();
    } catch (e) {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  Future<void> loadPopularMentors() async {
    _popularMentors = await _mentors.fetchMentorDirectory();
    _isLoadingMentors = false;
    notifyListeners();
  }

  Future<void> loadFeaturedCourses() async {
    try {
      List<FeaturedCourse> dbCourses = [];
      try {
        dbCourses = await _courses.fetchFeaturedCourses();
      } catch (err) {
        debugPrint('Error fetching db courses: $err');
      }

      // Map any uploaded course from DB by subject/category
      final coursesBySubject = <String, FeaturedCourse>{};
      for (final c in dbCourses) {
        final key = c.subject.trim().toLowerCase();
        if (key.isNotEmpty && !coursesBySubject.containsKey(key)) {
          coursesBySubject[key] = c;
        }
      }

      // Display ALL standard featured course categories even if there are no mentors yet
      final allFeatured = <FeaturedCourse>[];
      final addedKeys = <String>{};

      for (final cat in kCourseCategories) {
        final key = cat.trim().toLowerCase();
        if (coursesBySubject.containsKey(key)) {
          allFeatured.add(coursesBySubject[key]!);
        } else {
          allFeatured.add(_placeholderFor(cat));
        }
        addedKeys.add(key);
      }

      // Also include any other unique categories from the database not in kCourseCategories
      for (final c in dbCourses) {
        final key = c.subject.trim().toLowerCase();
        if (key.isNotEmpty && addedKeys.add(key)) {
          allFeatured.add(c);
        }
      }

      _featuredCourses = allFeatured;
      _isLoadingFeatured = false;
      notifyListeners();
    } catch (e) {
      _featuredCourses = kCourseCategories.map(_placeholderFor).toList();
      _isLoadingFeatured = false;
      notifyListeners();
    }
  }

  /// A card for a category that has no featured course yet.
  FeaturedCourse _placeholderFor(String category) {
    final theme = getCategoryTheme(category);
    return FeaturedCourse(
      id: -1,
      mentorName: 'Expert Mentor',
      subject: category,
      cardColor: theme.cardColorKey,
      imageUrl: '',
    );
  }
}
