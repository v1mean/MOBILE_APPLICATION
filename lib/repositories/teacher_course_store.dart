import 'package:flutter/material.dart';
import '../models/teacher_course.dart';
import '../theme/app_colors.dart';

/// Sample courses shown under a teacher's own uploads. They live in memory
/// for as long as the app runs, so a deleted sample stays deleted until the
/// app restarts.
class TeacherCourseStore extends ChangeNotifier {
  final List<TeacherCourse> _courses = [
    TeacherCourse(
      id: '1',
      title: 'Master Math Formular /\nBac II Preparation Course',
      description: 'Practice Exercise/ understand\nmore about formula.',
      category: 'Math',
      rating: 4.8,
      timeAgo: '1 day ago',
      color: AppColors.pastelPurple,
    ),
    TeacherCourse(
      id: '2',
      title: 'Physic Grade 12 Most\nPractice Exercises',
      description: 'Practice Exercise/ understand\nmore about formula.',
      category: 'Physic',
      rating: 4.7,
      timeAgo: '10hrs ago',
      color: const Color(0xFFBFEFFF),
    ),
  ];

  List<TeacherCourse> get courses => List.unmodifiable(_courses);

  void removeCourse(String id) {
    _courses.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
