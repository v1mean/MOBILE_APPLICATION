import 'dart:typed_data';
import 'package:flutter/material.dart';

/// A course as shown on the teacher's home screen.
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
