import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';

/// Reusable avatar widget used in home, settings, teacher home, teacher
/// schedules, and teacher settings screens.
///
/// Replaces the duplicated ClipOval + CircleAvatar + name + role column
/// pattern that appeared in 6+ screen files.
///
/// Example:
///   UserAvatarHeader(
///     name: _displayName,
///     role: 'Student',
///     avatarUrl: _avatarUrl,
///   )
class UserAvatarHeader extends StatelessWidget {
  final String name;
  final String role;
  final String? avatarUrl;
  /// Avatar circle diameter. Default matches Figma spec (48 px).
  final double size;
  /// Called when the avatar / name row is tapped (optional).
  final VoidCallback? onTap;

  const UserAvatarHeader({
    super.key,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.size = 48,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    Widget avatar = ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: avatarUrl != null && avatarUrl!.isNotEmpty
            ? Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallbackAvatar(initial),
              )
            : _fallbackAvatar(initial),
      ),
    );

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        avatar,
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name, style: AppTextStyles.userHeaderName),
            const SizedBox(height: 2),
            Text(role, style: AppTextStyles.userHeaderRole),
          ],
        ),
      ],
    );

    if (onTap == null) return row;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: row,
    );
  }

  static Widget _fallbackAvatar(String initial) => CircleAvatar(
        backgroundColor: AppColors.pastelPink,
        child: Text(
          initial,
          style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
        ),
      );
}
