import 'package:flutter/foundation.dart';
import '../../constants/course_categories.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/course_repository.dart';
import '../../repositories/user_repository.dart';
import '../base_view_model.dart';
import 'teacher_header.dart';

class TeacherUploadCourseViewModel extends BaseViewModel with TeacherHeader {
  TeacherUploadCourseViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required CourseRepository courseRepository,
  }) : _auth = authRepository,
       _users = userRepository,
       _courses = courseRepository;

  final AuthRepository _auth;
  final UserRepository _users;
  final CourseRepository _courses;

  String _selectedCategory = kCourseCategories[0]; // Default: 'Math'
  String? _thumbnailPath;
  String? _materialPath;
  String? _videoPath;

  List<String> get categories => kCourseCategories;
  String get selectedCategory => _selectedCategory;
  bool get hasThumbnail => _thumbnailPath != null;
  bool get hasMaterial => _materialPath != null;
  bool get hasVideo => _videoPath != null;

  Future<void> loadHeader() async {
    try {
      final userId = _auth.currentUserId;
      if (userId == null) return;
      await loadHeaderFromUsers(_users, userId);
    } catch (_) {}
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setThumbnail(String path) {
    _thumbnailPath = path;
    notifyListeners();
  }

  void setMaterial(String path) {
    _materialPath = path;
    notifyListeners();
  }

  void setVideo(String path) {
    _videoPath = path;
    notifyListeners();
  }

  /// Uploads the course with the chosen files. Returns an error message to
  /// show, or null when the upload succeeded.
  Future<String?> upload({
    required String title,
    required String description,
  }) async {
    setBusy(true);

    // The backend handles both the file uploads and the database insert.
    try {
      final success = await _courses.uploadCourse(
        title: title,
        description: description.isEmpty
            ? 'Practice exercise and course materials.'
            : description,
        category: _selectedCategory,
        thumbnailPath: _thumbnailPath,
        materialPath: _materialPath,
        videoPath: _videoPath,
      );

      if (!success) {
        setBusy(false);
        return 'Upload failed. Please try again.';
      }
    } catch (e) {
      debugPrint('Backend upload error: $e');
      setBusy(false);
      return e.toString().replaceAll('Exception: ', '');
    }

    setBusy(false);
    return null;
  }
}
