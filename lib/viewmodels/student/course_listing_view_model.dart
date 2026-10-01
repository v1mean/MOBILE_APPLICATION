import '../../models/mentor.dart';
import '../../repositories/course_repository.dart';
import '../../repositories/mentor_repository.dart';
import '../base_view_model.dart';

/// Courses and mentors for one subject.
class CourseListingViewModel extends BaseViewModel {
  CourseListingViewModel({
    required this.subject,
    required MentorRepository mentorRepository,
    required CourseRepository courseRepository,
  }) : _mentorRepo = mentorRepository,
       _courseRepo = courseRepository;

  final String subject;
  final MentorRepository _mentorRepo;
  final CourseRepository _courseRepo;

  List<Mentor> _allMentors = [];
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  Future<void> load() async {
    await Future.wait([_loadMentors(), _loadCourses()]);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadMentors() async {
    _allMentors = await _mentorRepo.fetchMentorsByRole();
    notifyListeners();
  }

  Future<void> _loadCourses() async {
    _courses = await _courseRepo.fetchCatalogue();
    notifyListeners();
  }

  /// Mentors teaching this subject, or every mentor as recommendations when
  /// none match.
  List<Mentor> get filteredMentors {
    final sub = subject.toLowerCase().trim();
    final list = _allMentors.where((m) {
      final mSub = m.subject.toLowerCase().trim();
      return mSub == sub ||
          mSub.contains(sub) ||
          sub.contains(mSub) ||
          m.name.toLowerCase().contains(sub);
    }).toList();

    // If no exact match, show all mentors as recommendations
    if (list.isEmpty) return _allMentors;
    return list;
  }

  /// Courses whose category or title matches this subject.
  List<Map<String, dynamic>> get filteredCourses {
    final sub = subject.toLowerCase().trim();

    return _courses.where((c) {
      final cat = (c['category'] as String? ?? '').toLowerCase().trim();
      final title = (c['title'] as String? ?? '').toLowerCase().trim();
      return cat == sub ||
          cat.contains(sub) ||
          sub.contains(cat) ||
          title.contains(sub);
    }).toList();
  }
}
