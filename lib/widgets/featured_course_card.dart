import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mentor.dart';

class FeaturedCourseCard extends StatelessWidget {
  final FeaturedCourse course;
  final VoidCallback? onTap;

  const FeaturedCourseCard({super.key, required this.course, this.onTap});

  @override
  Widget build(BuildContext context) {
    String assetImage = 'assets/images/featured_math.png';
    if (course.cardColor == 'teal') {
      assetImage = 'assets/images/featured_geography.png';
    } else if (course.cardColor == 'teal2') {
      assetImage = 'assets/images/featured_chemistry.png';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 124,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            assetImage,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFFE8820C),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.mentorName,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    course.subject,
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}