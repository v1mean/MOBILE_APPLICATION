import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_notification.dart';
import '../services/student_notification_service.dart';
import '../theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All'; // 'All', 'Unread', 'Bookings', 'Updates'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            _buildFilterChips(),
            Expanded(
              child: ValueListenableBuilder<List<AppNotification>>(
                valueListenable:
                    StudentNotificationService.notificationsNotifier,
                builder: (context, notifications, _) {
                  final filtered = _filterNotifications(notifications);

                  if (filtered.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _buildNotificationCard(context, item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.darkBg,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF1E1E2A),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.darkBorder,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Title
          Expanded(
            child: Row(
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                ValueListenableBuilder<int>(
                  valueListenable:
                      StudentNotificationService.unreadCountNotifier,
                  builder: (context, count, _) {
                    if (count == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.galaxyPurple.withAlpha(60),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.galaxyPurple.withAlpha(120),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$count new',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFD8B4FE),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Mark all read button
          IconButton(
            tooltip: 'Mark all as read',
            onPressed: () {
              StudentNotificationService.markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'All notifications marked as read',
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                  backgroundColor: AppColors.darkCard,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(
              Icons.done_all_rounded,
              color: Colors.white70,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Unread', 'Bookings', 'Updates'];

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final filter = filters[i];
          final isSelected = _selectedFilter == filter;

          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedFilter = filter);
              }
            },
            backgroundColor: AppColors.darkCard,
            selectedColor: AppColors.galaxyPurple.withAlpha(80),
            side: BorderSide(
              color: isSelected
                  ? AppColors.galaxyPurple
                  : const Color(0xFF262636),
              width: 1,
            ),
            labelStyle: GoogleFonts.inter(
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  List<AppNotification> _filterNotifications(
      List<AppNotification> notifications) {
    switch (_selectedFilter) {
      case 'Unread':
        return notifications.where((n) => !n.isRead).toList();
      case 'Bookings':
        return notifications.where((n) => n.type == 'booking').toList();
      case 'Updates':
        return notifications
            .where((n) => n.type == 'system' || n.type == 'course')
            .toList();
      default:
        return notifications;
    }
  }

  Widget _buildNotificationCard(
      BuildContext context, AppNotification item) {
    final isUnread = !item.isRead;

    // Type configuration
    Color iconBg;
    Color iconColor;
    IconData icon;

    switch (item.type) {
      case 'booking':
        iconBg = const Color(0xFF065F46).withAlpha(120);
        iconColor = const Color(0xFF34D399);
        icon = Icons.calendar_month_rounded;
        break;
      case 'reminder':
        iconBg = const Color(0xFF78350F).withAlpha(120);
        iconColor = const Color(0xFFFBBF24);
        icon = Icons.alarm_rounded;
        break;
      case 'course':
        iconBg = const Color(0xFF1E3A8A).withAlpha(120);
        iconColor = const Color(0xFF60A5FA);
        icon = Icons.menu_book_rounded;
        break;
      default:
        iconBg = AppColors.galaxyPurple.withAlpha(90);
        iconColor = const Color(0xFFC084FC);
        icon = Icons.auto_awesome_rounded;
    }

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626).withAlpha(200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        StudentNotificationService.deleteNotification(item.id);
      },
      child: GestureDetector(
        onTap: () {
          StudentNotificationService.markAsRead(item.id);
          if (item.route != null && item.route!.isNotEmpty) {
            context.push(item.route!);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUnread
                ? const Color(0xFF191924)
                : AppColors.darkCard.withAlpha(180),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnread
                  ? AppColors.galaxyPurple.withAlpha(120)
                  : AppColors.darkBorder,
              width: 1,
            ),
            boxShadow: isUnread
                ? [
                    BoxShadow(
                      color: AppColors.galaxyPurple.withAlpha(30),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: iconColor.withAlpha(80),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF38BDF8),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTime(item.timestamp),
                          style: GoogleFonts.inter(
                            color: Colors.white38,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (item.route != null && item.route!.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View',
                                style: GoogleFonts.inter(
                                  color: AppColors.accentBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColors.accentBlue,
                                size: 10,
                              ),
                            ],
                          ),
                      ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.darkBorder,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.notifications_off_outlined,
                color: Colors.white38,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Notifications',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You are all caught up! When you book classes or receive reminders, they will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white54,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.month}/${time.day}/${time.year}';
  }
}
