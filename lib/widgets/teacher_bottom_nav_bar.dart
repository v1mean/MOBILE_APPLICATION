import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

enum TeacherNavTab { course, students, pcRequest, schedules, settings }

class TeacherBottomNavBar extends StatelessWidget {
  final TeacherNavTab currentTab;
  const TeacherBottomNavBar({super.key, required this.currentTab});

  void _onTap(BuildContext context, TeacherNavTab tab) {
    switch (tab) {
      case TeacherNavTab.course:
        context.go('/teacher-home');
      case TeacherNavTab.students:
        context.go('/teacher-students');
      case TeacherNavTab.pcRequest:
        context.go('/teacher-pc-request');
      case TeacherNavTab.schedules:
        context.go('/teacher-schedules');
      case TeacherNavTab.settings:
        context.go('/teacher-settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.ondemand_video_outlined,
            label: 'Courses',
            tab: TeacherNavTab.course,
            currentTab: currentTab,
            onTap: () => _onTap(context, TeacherNavTab.course),
          ),
          _NavItem(
            icon: Icons.group_outlined,
            label: 'Students',
            tab: TeacherNavTab.students,
            currentTab: currentTab,
            onTap: () => _onTap(context, TeacherNavTab.students),
          ),
          _NavItem(
            icon: Icons.star_border_rounded,
            label: 'PC Request',
            tab: TeacherNavTab.pcRequest,
            currentTab: currentTab,
            onTap: () => _onTap(context, TeacherNavTab.pcRequest),
          ),
          _NavItem(
            icon: Icons.calendar_month_outlined,
            label: 'Schedules',
            tab: TeacherNavTab.schedules,
            currentTab: currentTab,
            onTap: () => _onTap(context, TeacherNavTab.schedules),
          ),
          _NavItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            tab: TeacherNavTab.settings,
            currentTab: currentTab,
            onTap: () => _onTap(context, TeacherNavTab.settings),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final TeacherNavTab tab;
  final TeacherNavTab currentTab;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.tab,
    required this.currentTab,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = tab == currentTab;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 14 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
          border: isActive
              ? null
              : Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : const Color(0xFF1F2937),
              size: 20,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
