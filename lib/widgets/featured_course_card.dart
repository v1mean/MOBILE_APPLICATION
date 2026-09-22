import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mentor.dart';
import '../constants/course_categories.dart';

class FeaturedCourseCard extends StatelessWidget {
  final FeaturedCourse course;
  final VoidCallback? onTap;

  const FeaturedCourseCard({super.key, required this.course, this.onTap});

  @override
  Widget build(BuildContext context) {
    String? assetImage;
    if (course.cardColor == 'orange' || course.subject.toLowerCase() == 'math') {
      assetImage = 'assets/images/featured_math.png';
    } else if (course.cardColor == 'teal') {
      assetImage = 'assets/images/featured_geography.png';
    } else if (course.cardColor == 'teal2') {
      assetImage = 'assets/images/featured_chemistry.png';
    }

    final theme = getCategoryTheme(course.subject.isNotEmpty ? course.subject : course.cardColor);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        width: 125,
        height: 125,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: IgnorePointer(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image or Themed Gradient
                    if (assetImage != null)
                      Image.asset(
                        assetImage,
                        fit: BoxFit.cover,
                      )
                else
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: theme.gradient,
                      ),
                    ),
                  ),

                // Bottom-Right 3D Styled Graphic for non-asset cards
                if (assetImage == null)
                  Positioned(
                    right: -8,
                    bottom: -8,
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(35),
                        border: Border.all(
                          color: Colors.white.withAlpha(55),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 10,
                            offset: const Offset(-2, -2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        theme.icon,
                        color: Colors.white.withAlpha(235),
                        size: 34,
                      ),
                    ),
                  ),

                // Course Name Only (top-left)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 12, 10),
                  child: Text(
                    course.subject,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.25,
                      shadows: [
                        Shadow(
                          color: Colors.black.withAlpha(60),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
    );
  }
}