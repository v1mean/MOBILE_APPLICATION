import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodels/student/student_notifications_view_model.dart';
import '../theme/app_colors.dart';

class NotificationBell extends StatelessWidget {
  final Color color;
  final double size;
  final VoidCallback? onTap;

  /// Unread count for the badge. Leave null to show the student's own
  /// notifications.
  final int? unreadCount;

  const NotificationBell({
    super.key,
    this.color = Colors.white,
    this.size = 26,
    this.onTap,
    this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final unreadCount =
        this.unreadCount ??
        context.watch<StudentNotificationsViewModel>().unreadCount;
    return Builder(
      builder: (context) {
        return IconButton(
          onPressed: onTap ?? () => context.push('/notifications'),
          splashRadius: 24,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                unreadCount > 0
                    ? Icons.notifications_rounded
                    : Icons.notifications_none_rounded,
                color: color,
                size: size,
              ),
              if (unreadCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.liveRed, // AppColors.liveRed
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.darkBg, // AppColors.darkBg
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.liveRed.withAlpha(120),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    alignment: Alignment.center,
                    child: unreadCount > 1
                        ? Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              height: 1.0,
                            ),
                          )
                        : const SizedBox(width: 4, height: 4),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
