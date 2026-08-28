import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_data.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/course_card.dart';
import '../theme/app_colors.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  int _navIndex = 3;

  void _onNavTap(int i) {
    if (i == _navIndex) return;
    setState(() => _navIndex = i);
    switch (i) {
      case 0: context.go('/home'); break;
      case 1: context.go('/search'); break;
      case 2: context.go('/courses'); break;
      default: break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: Column(
        children: [
          // Top close/back button (like Figma)
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => context.go('/home'),
                  child: Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Avatar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 80, height: 80,
                      color: AppColors.tagPurple,
                      child: Image.network(
                        'https://api.dicebear.com/9.x/avataaars/png?seed=JessicaCarl&backgroundColor=ffd5dc',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text('J',
                              style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.accentBlue)),
                        ),
                      ),
                    ),
                  ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 16),
                  Text('Jessica Carl',
                      style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800))
                      .animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),
                  const SizedBox(height: 4),
                  Text('Join Jomnes 2 years ago.',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary))
                      .animate(delay: 150.ms).fadeIn(),
                  const SizedBox(height: 20),
                  // My Courses button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.go('/courses'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('My Courses',
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
                  const SizedBox(height: 20),
                  // Course cards
                  ...sampleCourses.map((c) => CourseCard(course: c).animate().fadeIn().slideY(begin: 0.1)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _navIndex, onTap: _onNavTap),
    );
  }
}
