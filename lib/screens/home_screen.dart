import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_data.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/mentor_card.dart';
import '../widgets/featured_course_card.dart';
import '../widgets/tag_chip.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  void _onNavTap(int i) {
    if (i == _navIndex) return;
    setState(() => _navIndex = i);
    switch (i) {
      case 1: context.go('/search'); break;
      case 2: context.go('/courses'); break;
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
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accentBlue, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        'https://api.dicebear.com/9.x/avataaars/png?seed=Jessica&backgroundColor=ffd5dc',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const ColoredBox(
                          color: AppColors.tagPurple,
                          child: Center(child: Text('J', style: TextStyle(fontWeight: FontWeight.w700))),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Jessica Carl',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.white)),
                      Text('Student',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textWhite70)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(12)),
                    child: Stack(
                      children: [
                        const Center(child: Icon(Icons.notifications_outlined, color: AppColors.white, size: 22)),
                        Positioned(
                          top: 8, right: 9,
                          child: Container(
                            width: 7, height: 7,
                            decoration: const BoxDecoration(color: AppColors.liveRed, shape: BoxShape.circle),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.lightBg,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 14),
                              const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  onTap: () => context.go('/search'),
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    hintText: 'Search Mentors',
                                    hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
                                    border: InputBorder.none, enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none, filled: false,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: AppColors.lightBg, borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.tune_rounded, size: 18, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Text('Recent', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                              const SizedBox(width: 12),
                              const TagChip(label: 'Chey Thavy', color: AppColors.tagYellow),
                              const SizedBox(width: 8),
                              const TagChip(label: 'Math', color: AppColors.tagGreen),
                              const SizedBox(width: 8),
                              const TagChip(label: 'Chemistry', color: AppColors.tagPurple),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Featured Courses', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 145,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: featuredCourses.length,
                          itemBuilder: (context, i) => FeaturedCourseCard(
                            course: featuredCourses[i],
                            onTap: () => context.push('/mentor/${mentors[i % mentors.length].id}'),
                          ).animate(delay: (i * 100).ms).fadeIn().slideX(begin: 0.2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Popular Mentors', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(height: 8),
                      ...mentors.map((m) => MentorCardWithButton(
                        mentor: m,
                        onCheckOut: () => context.push('/mentor/${m.id}'),
                      ).animate().fadeIn().slideY(begin: 0.15)),
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
