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
        width: 120,
        height: 125,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image with 3D elements
              Image.asset(
                assetImage,
                fit: BoxFit.cover,
              ),
              // Text overlay top-left
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.mentorName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      course.subject,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withAlpha(220),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}