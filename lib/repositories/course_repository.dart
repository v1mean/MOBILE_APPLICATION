import '../constants/mock_data.dart';
import '../models/mentor.dart';
import '../services/api_service.dart';
import '../services/supabase_service.dart';

/// Courses: the featured list, the catalogue, a student's enrolled courses
/// and a teacher's own uploads.
class CourseRepository {
  /// Courses flagged as featured, newest first.
  Future<List<FeaturedCourse>> fetchFeaturedCourses() async {
    final data = await supabaseClient
        .from('courses')
        .select('*, Users(name)')
        .eq('is_featured', true)
        .order('id', ascending: false);
    return data.map((e) => FeaturedCourse.fromJson(e)).toList();
  }

  /// Every course in the database, followed by the mock courses whose titles
  /// aren't already present. Falls back to the mock courses alone when
  /// combining them fails.
  Future<List<Map<String, dynamic>>> fetchCatalogue() async {
    try {
      List<Map<String, dynamic>> dbCourses = [];
      try {
        final data = await supabaseClient
            .from('courses')
            .select('*, Users(name)')
            .order('id', ascending: true);
        dbCourses = List<Map<String, dynamic>>.from(data);
      } catch (_) {}

      // Combine real uploaded courses from DB with mock courses
      final combinedCourses = <Map<String, dynamic>>[...dbCourses];
      final seenTitles = dbCourses
          .map((c) => (c['title'] ?? '').toString().toLowerCase().trim())
          .toSet();
      for (final mc in getMockCoursesAsJson()) {
        final title = (mc['title'] ?? '').toString().toLowerCase().trim();
        if (seenTitles.add(title)) {
          combinedCourses.add(mc);
        }
      }

      return combinedCourses;
    } catch (e) {
      return getMockCoursesAsJson();
    }
  }

  /// The courses the signed-in student is enrolled in.
  Future<List<Course>> fetchMyCourses(String accessToken) async {
    final data = await ApiService.fetchMyCourses(accessToken);
    return data.map((e) => Course.fromJson(e)).toList();
  }

  /// A teacher's uploaded courses, newest first, as raw rows.
  Future<List<Map<String, dynamic>>> fetchTeacherCourseRows(
    String tutorId,
  ) async {
    final data = await supabaseClient
        .from('courses')
        .select()
        .eq('tutor_id', tutorId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<bool> uploadCourse({
    required String title,
    required String description,
    required String category,
    String? thumbnailPath,
    String? materialPath,
    String? videoPath,
  }) => ApiService.uploadCourse(
    title: title,
    description: description,
    category: category,
    thumbnailPath: thumbnailPath,
    materialPath: materialPath,
    videoPath: videoPath,
  );
}
