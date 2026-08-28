import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_data.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/course_card.dart';
import '../theme/app_colors.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  int _navIndex = 2;

  void _onNavTap(int i) {
    if (i == _navIndex) return;
    setState(() => _navIndex = i);
    switch (i) {
      case 0: context.go('/home'); break;
      case 1: context.go('/search'); break;
      case 3: context.go('/profile'); break;
      case 4: context.go('/settings'); break;
      default: break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Column(
        children: [
          // Dark Top Header
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Image.asset(
                        'assets/images/jessica_avatar.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jessica Carl',
                        style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Student',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26),
                  ),
                ],
              ),
            ),
          ),
          // White Rounded Content Body
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF6F7F9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 22),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'My Courses',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF111827),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...sampleCourses.map((c) => CourseCard(course: c)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _navIndex, onTap: _onNavTap),
    );
  }
}