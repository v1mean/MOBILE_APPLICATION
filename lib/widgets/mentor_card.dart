import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mentor.dart';
import '../constants/course_categories.dart';
import '../theme/app_colors.dart';
import 'category_theme_widgets.dart';

/// Shared layout for [MentorCard] and [MentorCardWithButton] — the two only
/// differ in avatar size/border radius and whether a trailing action button
/// is shown, so both delegate here instead of duplicating the whole card.
class _MentorCardBase extends StatelessWidget {
  final Mentor mentor;
  final VoidCallback? onTap;
  final double avatarSize;
  final double cardBorderRadius;
  final double avatarBorderRadius;
  final Widget? trailing;

  const _MentorCardBase({
    required this.mentor,
    required this.avatarSize,
    required this.cardBorderRadius,
    required this.avatarBorderRadius,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = getCategoryTheme(mentor.subject);

    final card = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GradientInitialAvatar(
            imageUrl: mentor.avatarUrl,
            fallbackText: mentor.name,
            theme: theme,
            size: avatarSize,
            borderRadius: avatarBorderRadius,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CategoryPillBadge(theme: theme, label: mentor.subject),
                const SizedBox(height: 5),
                Text(
                  mentor.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: AppColors.warningAmber),
                    const SizedBox(width: 3),
                    Text(
                      mentor.rating.toStringAsFixed(1),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '(${mentor.students}+ students)',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      '\$${mentor.bookingPrice.toInt()}/hr',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.tealDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '• ${mentor.experience}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (trailing != null) ...[
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerRight, child: trailing!),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return onTap == null ? card : GestureDetector(onTap: onTap, child: card);
  }
}

class MentorCard extends StatelessWidget {
  final Mentor mentor;
  final VoidCallback? onTap;

  const MentorCard({super.key, required this.mentor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return _MentorCardBase(
      mentor: mentor,
      onTap: onTap,
      avatarSize: 95,
      cardBorderRadius: 22,
      avatarBorderRadius: 18,
    );
  }
}

class MentorCardWithButton extends StatelessWidget {
  final Mentor mentor;
  final VoidCallback? onCheckOut;

  const MentorCardWithButton({super.key, required this.mentor, this.onCheckOut});

  @override
  Widget build(BuildContext context) {
    return _MentorCardBase(
      mentor: mentor,
      avatarSize: 105,
      cardBorderRadius: 24,
      avatarBorderRadius: 20,
      trailing: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onCheckOut,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.slateDark,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Check out',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 13, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
