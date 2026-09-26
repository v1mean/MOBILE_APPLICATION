import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/course_categories.dart';

/// Small icon+label pill using a category's theme gradient.
/// Shared by mentor and course cards to avoid repeating the same
/// gradient-container-with-icon-and-text block in every card widget.
class CategoryPillBadge extends StatelessWidget {
  final CategoryTheme theme;
  final String label;
  final double fontSize;

  const CategoryPillBadge({
    super.key,
    required this.theme,
    required this.label,
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(theme.icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular avatar that shows [imageUrl] and falls back to a themed
/// gradient circle with the first letter of [fallbackText] when the image
/// is missing or fails to load. Shared by mentor and course cards.
class GradientInitialAvatar extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;
  final CategoryTheme theme;
  final double size;
  final double borderRadius;
  final double fontSize;

  const GradientInitialAvatar({
    super.key,
    required this.imageUrl,
    required this.fallbackText,
    required this.theme,
    required this.size,
    this.borderRadius = 18,
    this.fontSize = 32,
  });

  Widget _fallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: (imageUrl == null || imageUrl!.isEmpty)
            ? _fallback()
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(),
              ),
      ),
    );
  }
}
