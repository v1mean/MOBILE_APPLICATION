import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TeacherCourse {
  final String id;
  final String title;
  final String description;
  final String category;
  final double rating;
  final String timeAgo;
  final Color color;
  final String? thumbnailUrl;
  final Uint8List? thumbnailBytes;
  final String? materialName;
  final String? materialSize;
  final String? videoName;
  final String? videoDuration;

  TeacherCourse({
    required this.id,
    required this.title,
    required this.description,
    this.category = 'Math',
    this.rating = 5.0,
    this.timeAgo = 'Just now',
    required this.color,
    this.thumbnailUrl,
    this.thumbnailBytes,
    this.materialName,
    this.materialSize,
    this.videoName,
    this.videoDuration,
  });
}

class TeacherCourseService extends ChangeNotifier {
  static final TeacherCourseService instance = TeacherCourseService._();
  TeacherCourseService._();

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

  void addCourse({
    required String title,
    required String description,
    String category = 'General',
    String? thumbnailUrl,
    Uint8List? thumbnailBytes,
    String? materialName,
    String? materialSize,
    String? videoName,
    String? videoDuration,
  }) {
    final colors = [
      AppColors.pastelPurple, // Pink
      const Color(0xFFBFEFFF), // Light Blue
      AppColors.successBgLight, // Light Green
      AppColors.tagYellow, // Light Yellow
      AppColors.indigoBgLight, // Indigo tint
    ];
    final color = colors[_courses.length % colors.length];

    _courses.insert(
      0,
      TeacherCourse(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description.trim().isEmpty ? 'Practice Exercise / Course material.' : description.trim(),
        category: category,
        rating: 5.0,
        timeAgo: 'Just now',
        color: color,
        thumbnailUrl: thumbnailUrl,
        thumbnailBytes: thumbnailBytes,
        materialName: materialName,
        materialSize: materialSize,
        videoName: videoName,
        videoDuration: videoDuration,
      ),
    );
    notifyListeners();
  }

  void removeCourse(String id) {
    _courses.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
