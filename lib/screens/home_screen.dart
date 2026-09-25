import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../router.dart';
import '../main.dart';
import '../models/user_profile.dart';
import '../models/mentor.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/mentor_card.dart';
import '../widgets/featured_course_card.dart';
import '../widgets/user_avatar_header.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  UserProfile? _userProfile;
  bool _isLoadingProfile = true;
  
  List<Mentor> _popularMentors = [];
  bool _isLoadingMentors = true;
  
  List<FeaturedCourse> _featuredCourses = [];
  bool _isLoadingFeatured = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchPopularMentors();
    _fetchFeaturedCourses();
  }

  @override
  void reassemble() {
    super.reassemble();
    _fetchUserProfile();
    _fetchPopularMentors();
    _fetchFeaturedCourses();
  }

  Future<void> _fetchPopularMentors() async {
    try {
      final data = await JomnesDB.from('tutor_search_view')
          .select()
          .order('course_id', ascending: false);

      final Map<String, Mentor> uniqueMentors = {};
      for (var row in (data as List)) {
        final tutorId = row['tutor_id']?.toString() ?? '';
        if (tutorId.isEmpty || uniqueMentors.containsKey(tutorId)) continue;

        uniqueMentors[tutorId] = Mentor(
          id: tutorId,
          name: row['tutor_name'] ?? 'Mentor',
          subject: (row['subject']?.toString().isNotEmpty == true)
              ? row['subject'] as String
              : Mentor.inferMentorSubject(row['bio']?.toString() ?? '', null),
          experience: '${row['experience_years'] ?? 5} years experience',
          timeSlot: 'Flexible',
          avatarUrl: (row['tutor_avatar']?.toString().isNotEmpty == true)
              ? row['tutor_avatar'] as String
              : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&fit=crop',
          rating: (row['mentor_rating'] as num?)?.toDouble() ?? 4.9,
          students: 120,
          classes: 50,
          followers: 300,
          bookingPrice: (row['hourly_rate'] as num?)?.toDouble() ?? 35.0,
          bio: row['bio']?.toString() ?? 'Experienced mentor.',
          courses: [],
        );
      }

      if (mounted) {
        setState(() {
          _popularMentors = uniqueMentors.values.take(15).toList();
          _isLoadingMentors = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMentors = false;
        });
      }
    }
  }


  Future<void> _fetchFeaturedCourses() async {
    try {
      final data = await JomnesDB.from('courses')
          .select('*, Users!inner(name)')
          .eq('is_featured', true)
          .order('id', ascending: false);
          
      if (mounted) {
        setState(() {
          _featuredCourses = (data as List).map((e) => FeaturedCourse.fromJson(e)).toList();
          _isLoadingFeatured = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFeatured = false;
        });
      }
    }
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
          if (data != null) {
            _userProfile = UserProfile.fromJson(data);
          }
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  String get _displayName {
    if (_userProfile?.name != null && _userProfile!.name.isNotEmpty) {
      return _userProfile!.name;
    }
    final user = JomnesDB.auth.currentUser;
    final metaName = user?.userMetadata?['full_name'] ??
        user?.userMetadata?['name'] ??
        user?.email?.split('@').first;
    if (metaName != null && metaName.toString().isNotEmpty) {
      return metaName.toString();
    }
    return isGuestMode ? 'Guest' : (_isLoadingProfile ? 'Loading...' : 'Student');
  }

  String? get _displayAvatar {
    if (_userProfile?.profileImage != null && _userProfile!.profileImage.isNotEmpty) {
      return _userProfile!.profileImage;
    }
    final user = JomnesDB.auth.currentUser;
    final dynamic pic = user?.userMetadata?['avatar_url'] ?? user?.userMetadata?['picture'];
    final String? metaAvatar = pic is String ? pic : null;
    if (metaAvatar != null && metaAvatar.isNotEmpty) {
      return metaAvatar;
    }
    return null; // No avatar — show initial letter circle
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
        context.go('/profile');
        break;
      case 4:
        context.go('/settings');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    name: _displayName,
                    role: _userProfile?.role ?? 'Student',
                    avatarUrl: _displayAvatar,
                    onTap: () => context.go('/settings'),
                  ),
                  const Spacer(),
                  // Clean outline bell icon matching Figma
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // White Content Body
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
                      _fetchPopularMentors(),
                      _fetchFeaturedCourses(),
                    ]);
                  },
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
                              color: const Color(0xFFE5E7EB),
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
                                    color: Color(0xFF6B7280),
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
                                          color: const Color(0xFF374151),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.tune_rounded,
                                    color: Color(0xFF111827),
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
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _RecentChip(
                                    label: 'Chey Thavy',
                                    bg: const Color(0xFFF3E8FF),
                                    textColor: const Color(0xFF7E22CE),
                                  ),
                                  const SizedBox(width: 6),
                                  _RecentChip(
                                    label: 'Math',
                                    bg: const Color(0xFFDBEAFE),
                                    textColor: const Color(0xFF1D4ED8),
                                  ),
                                  const SizedBox(width: 6),
                                  _RecentChip(
                                    label: 'Chemistry',
                                    bg: const Color(0xFFDCFCE7),
                                    textColor: const Color(0xFF15803D),
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
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Featured Courses Horizontal List
                      if (_isLoadingFeatured)
                        const Center(child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(color: AppColors.accentBlue),
                        ))
                      else if (_featuredCourses.isEmpty)
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
                            itemCount: _featuredCourses.length,
                            itemBuilder: (context, i) => FeaturedCourseCard(
                              course: _featuredCourses[i],
                              onTap: () {
                                context.go(
                                  '/course-listing/${Uri.encodeComponent(_featuredCourses[i].subject)}',
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
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Popular Mentors List
                      if (_isLoadingMentors) 
                        const Center(child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(color: AppColors.accentBlue),
                        ))
                      else if (_popularMentors.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Text('No mentors available yet.', style: GoogleFonts.inter(color: Colors.grey)),
                        )
                      else
                        ..._popularMentors.map((m) => MentorCardWithButton(
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



