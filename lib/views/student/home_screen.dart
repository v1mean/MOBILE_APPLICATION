import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/student/home_view_model.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/mentor_card.dart';
import '../../widgets/featured_course_card.dart';
import '../../widgets/user_avatar_header.dart';
import '../../widgets/notification_bell.dart';
import '../../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  late final HomeViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = context.read<HomeViewModel>();
  }

  @override
  void reassemble() {
    super.reassemble();
    _vm.load();
  }

  void _onNavTap(int i) {
    if (i == _navIndex) return;
    setState(() => _navIndex = i);
    switch (i) {
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/courses');
        break;
      case 3:
        context.go('/settings');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<HomeViewModel>();
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Column(
        children: [
          // Dark Header
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              child: Row(
                children: [
                  // Current User Avatar & Info (clickable to Settings)
                  UserAvatarHeader(
                    name: _vm.displayName,
                    role: _vm.role,
                    avatarUrl: _vm.displayAvatar,
                    onTap: () => context.go('/settings'),
                  ),
                  const Spacer(),
                  // Clean outline bell icon matching Figma
                  const NotificationBell(),
                ],
              ),
            ),
          ),
          // White Content Body
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.pageBg,
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
                child: RefreshIndicator(
                  color: AppColors.accentBlue,
                  onRefresh: _vm.load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 18),
                      // Combined Search & Recent Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(6),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Search Input Row
                              Row(
                                children: [
                                  const Icon(
                                    Icons.search_rounded,
                                    color: AppColors.textSecondary,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => context.go('/search'),
                                      behavior: HitTestBehavior.opaque,
                                      child: Text(
                                        'Search Mentors',
                                        style: GoogleFonts.inter(
                                          color: AppColors.borderDark,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.tune_rounded,
                                    color: AppColors.textPrimary,
                                    size: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              // Recent Tags Row
                              Row(
                                children: [
                                  Text(
                                    'Recent',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _RecentChip(
                                    label: 'Chey Thavy',
                                    bg: AppColors.purpleBgLight,
                                    textColor: const Color(0xFF7E22CE),
                                  ),
                                  const SizedBox(width: 6),
                                  _RecentChip(
                                    label: 'Math',
                                    bg: const Color(0xFFDBEAFE),
                                    textColor: AppColors.accentBlueDark,
                                  ),
                                  const SizedBox(width: 6),
                                  _RecentChip(
                                    label: 'Chemistry',
                                    bg: AppColors.successBgLight,
                                    textColor: AppColors.successTextDark,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Featured Courses Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Text(
                          'Featured Courses',
                          style: GoogleFonts.inter(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Featured Courses Horizontal List
                      if (_vm.isLoadingFeatured)
                        const Center(child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(color: AppColors.accentBlue),
                        ))
                      else if (_vm.featuredCourses.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Text('No featured courses available yet.', style: GoogleFonts.inter(color: Colors.grey)),
                        )
                      else
                        SizedBox(
                          height: 135,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _vm.featuredCourses.length,
                            itemBuilder: (context, i) => FeaturedCourseCard(
                              course: _vm.featuredCourses[i],
                              onTap: () {
                                context.go(
                                  '/course-listing/${Uri.encodeComponent(_vm.featuredCourses[i].subject)}',
                                );
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      // Popular Mentors Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Text(
                          'Popular Mentors',
                          style: GoogleFonts.inter(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Popular Mentors List
                      if (_vm.isLoadingMentors) 
                        const Center(child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(color: AppColors.accentBlue),
                        ))
                      else if (_vm.popularMentors.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Text('No mentors available yet.', style: GoogleFonts.inter(color: Colors.grey)),
                        )
                      else
                        ..._vm.popularMentors.map((m) => MentorCardWithButton(
                          mentor: m,
                          onCheckOut: () => context.push('/mentor/${m.id}'),
                        )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

class _RecentChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;

  const _RecentChip({
    required this.label,
    required this.bg,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}



