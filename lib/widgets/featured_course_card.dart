import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mentor.dart';

class FeaturedCourseCard extends StatelessWidget {
  final FeaturedCourse course;
  final VoidCallback? onTap;

  const FeaturedCourseCard({super.key, required this.course, this.onTap});

  @override
  Widget build(BuildContext context) {
    String? assetImage;
    if (course.cardColor == 'orange') {
      assetImage = 'assets/images/featured_math.png';
    } else if (course.cardColor == 'teal') {
      assetImage = 'assets/images/featured_geography.png';
    } else if (course.cardColor == 'teal2') {
      assetImage = 'assets/images/featured_chemistry.png';
    }

    final theme = _getCourseTheme(course.cardColor);

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

  _CourseTheme _getCourseTheme(String color) {
    switch (color) {
      case 'purple': // Physic
        return const _CourseTheme(
          gradient: [Color(0xFF581C87), Color(0xFF7E22CE)],
          icon: Icons.science_rounded,
        );
      case 'amber': // Khmer
        return const _CourseTheme(
          gradient: [Color(0xFF92400E), Color(0xFFD97706)],
          icon: Icons.menu_book_rounded,
        );
      case 'red': // English
        return const _CourseTheme(
          gradient: [Color(0xFF991B1B), Color(0xFFDC2626)],
          icon: Icons.translate_rounded,
        );
      case 'slate': // Gym Trainer
        return const _CourseTheme(
          gradient: [Color(0xFF1E293B), Color(0xFF475569)],
          icon: Icons.fitness_center_rounded,
        );
      case 'blue': // Volleyball coach
        return const _CourseTheme(
          gradient: [Color(0xFF0369A1), Color(0xFF0284C7)],
          icon: Icons.sports_volleyball_rounded,
        );
      case 'green': // Badminton coach
        return const _CourseTheme(
          gradient: [Color(0xFF065F46), Color(0xFF059669)],
          icon: Icons.sports_tennis_rounded,
        );
      case 'cyan': // Swimming Coach
        return const _CourseTheme(
          gradient: [Color(0xFF155E75), Color(0xFF0891B2)],
          icon: Icons.pool_rounded,
        );
      case 'crimson': // Chinese teacher
        return const _CourseTheme(
          gradient: [Color(0xFF9F1239), Color(0xFFE11D48)],
          icon: Icons.draw_rounded,
        );
      default:
        return const _CourseTheme(
          gradient: [Color(0xFF1E293B), Color(0xFF3B82F6)],
          icon: Icons.school_rounded,
        );
    }
  }
}

class _CourseTheme {
  final List<Color> gradient;
  final IconData icon;
  const _CourseTheme({required this.gradient, required this.icon});
}