import 'package:flutter/material.dart';
import '../../models/teacher_course.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/course_repository.dart';
import '../../repositories/teacher_course_store.dart';
import '../../repositories/user_repository.dart';
import '../../theme/app_colors.dart';
import '../base_view_model.dart';
import 'teacher_header.dart';

class TeacherHomeViewModel extends BaseViewModel with TeacherHeader {
  TeacherHomeViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required CourseRepository courseRepository,
    required TeacherCourseStore courseStore,
  }) : _auth = authRepository,
       _users = userRepository,
       _courseRepo = courseRepository,
       _store = courseStore {
    _store.addListener(notifyListeners);
  }

  final AuthRepository _auth;
  final UserRepository _users;
  final CourseRepository _courseRepo;
  final TeacherCourseStore _store;

  List<TeacherCourse> _courses = [];
  bool _isLoadingCourses = true;

  /// The teacher's own uploaded courses.
  List<TeacherCourse> get courses => _courses;
  bool get isLoadingCourses => _isLoadingCourses;

  /// The sample courses listed under the teacher's own.
  List<TeacherCourse> get sampleCourses => _store.courses;

  void load() {
    loadHeader();
    loadCourses();
  }

  Future<void> loadHeader() async {
    try {
      final userId = _auth.currentUserId;
      if (userId == null) return;
      if (await loadHeaderFromUsers(_users, userId)) return;
      await loadHeaderFromProfiles(_users, userId);
    } catch (_) {}
  }

  Future<void> loadCourses() async {
    try {
      final userId = _auth.currentUserId;
      if (userId == null) return;
      final data = await _courseRepo.fetchTeacherCourseRows(userId);

      _courses = data
          .map(
            (c) => TeacherCourse(
              id: c['id']?.toString() ?? '',
              title: c['title'] ?? 'Course Title',
              description: c['description'] ?? 'No description',
              category: c['category']?.toString() ?? 'General',
              rating: (c['rating'] as num?)?.toDouble() ?? 5.0,
              timeAgo: _formatTimeAgo(c['created_at']),
              color: _parseColor(c['card_color']),
            ),
          )
          .toList();
      _isLoadingCourses = false;
      notifyListeners();
    } catch (_) {
      _isLoadingCourses = false;
      notifyListeners();
    }
  }

  void deleteCourse(String id) => _store.removeCourse(id);

  String _formatTimeAgo(String? dateStr) {
    if (dateStr == null) return 'Just now';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return 'Just now';
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago';
    }
    if (diff.inMinutes > 0) {
      return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
    }
    return 'Just now';
  }

  Color _parseColor(String? colorStr) {
    switch (colorStr) {
      case 'pink':
        return AppColors.pastelPurple;
      case 'blue':
        return const Color(0xFFE0F2FE);
      case 'green':
        return AppColors.successBgLight;
      case 'orange':
        return const Color(0xFFFFEDD5);
      case 'slate':
        return AppColors.slateBorderLight;
      case 'cyan':
        return const Color(0xFFCFFAFE);
      default:
        return AppColors.pastelPurple;
    }
  }

  @override
  void dispose() {
    _store.removeListener(notifyListeners);
    super.dispose();
  }
}
