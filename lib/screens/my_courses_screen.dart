import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../models/user_profile.dart';
import '../models/mentor.dart';
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
  UserProfile? _userProfile;
  bool _isLoadingProfile = true;
  
  List<Course> _myCourses = [];
  bool _isLoadingCourses = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchMyCourses();
  }

  @override
  void reassemble() {
    super.reassemble();
    _fetchUserProfile();
    _fetchMyCourses();
  }

  Future<void> _fetchUserProfile() async {
    final session = JomnesDB.auth.currentSession;
    if (session == null) {
      if (mounted) setState(() => _isLoadingProfile = false);
      return;
    }
    try {
      final data = await JomnesDB.from('Users')
          .select()
          .eq('user_id', session.user.id)
          .maybeSingle();
      if (mounted) {
        setState(() {
          if (data != null) _userProfile = UserProfile.fromJson(data);
          _isLoadingProfile = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _fetchMyCourses() async {
    try {
      final data = await JomnesDB.from('courses')
          .select()
          .eq('is_featured', false)
          .limit(3);
          
      if (mounted) {
        setState(() {
          _myCourses = (data as List).map((e) => Course.fromJson(e)).toList();
          _isLoadingCourses = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCourses = false;
        });
      }
    }
  }

  String get _displayName {
    if (_userProfile?.name.isNotEmpty == true) return _userProfile!.name;
    final user = JomnesDB.auth.currentUser;
    return user?.userMetadata?['full_name'] ??
        user?.userMetadata?['name'] ??
        user?.email?.split('@').first ??
        'Student';
  }

  String get _displayRole {
    if (_userProfile?.role.isNotEmpty == true) return _userProfile!.role;
    return 'Student';
  }

  String? get _avatarUrl {
    if (_userProfile?.profileImage.isNotEmpty == true) return _userProfile!.profileImage;
    final user = JomnesDB.auth.currentUser;
    final dynamic pic = user?.userMetadata?['avatar_url'] ?? user?.userMetadata?['picture'];
    return pic is String && pic.isNotEmpty ? pic : null;
  }

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
    final name = _displayName;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final avatar = _avatarUrl;

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
                  // Current User Avatar & Info (clickable to Settings)
                  GestureDetector(
                    onTap: () => context.go('/settings'),
                    behavior: HitTestBehavior.opaque,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipOval(
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: _isLoadingProfile
                                  ? const CircularProgressIndicator(color: AppColors.accentBlue, strokeWidth: 2)
                                  : avatar != null
                                      ? Image.network(
                                          avatar,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => CircleAvatar(
                                            backgroundColor: const Color(0xFFFFD5DC),
                                            child: Text(initial,
                                                style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
                                          ),
                                        )
                                      : CircleAvatar(
                                          backgroundColor: const Color(0xFFFFD5DC),
                                          child: Text(initial,
                                              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
                                        ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _displayRole,
                                style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                child: RefreshIndicator(
                  color: AppColors.accentBlue,
                  onRefresh: () async {
                    await Future.wait([
                      _fetchUserProfile(),
                      _fetchMyCourses(),
                    ]);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                      if (_isLoadingCourses)
                        const Center(child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(color: AppColors.accentBlue),
                        ))
                      else if (_myCourses.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text('You have not enrolled in any courses yet.', style: GoogleFonts.inter(color: Colors.grey)),
                        )
                      else
                        ..._myCourses.map((c) => CourseCard(course: c)),
                    ],
                  ),
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