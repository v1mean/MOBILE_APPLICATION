import 'package:flutter/material.dart';
import '../widgets/user_avatar_header.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../models/user_profile.dart';
import '../models/mentor.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/course_card.dart';
import '../theme/app_colors.dart';
import '../main.dart';
import '../services/api_service.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  int _navIndex = 2;
  UserProfile? _userProfile;
  late Future<List<Course>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _coursesFuture = _fetchMyCourses();
  }

  Future<List<Course>> _fetchMyCourses() async {
    final session = JomnesDB.auth.currentSession;
    if (session == null) return [];
    try {
      final data = await ApiService.fetchMyCourses(session.accessToken);
      return data.map((e) => Course.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _fetchUserProfile() async {
    final session = JomnesDB.auth.currentSession;
    if (session == null) {
      return;
    }

    try {
      final data = await JomnesDB.from(
        'profiles',
      ).select().eq('id', session.user.id).maybeSingle();
      if (mounted) {
        setState(() {
          if (data != null) {
            _userProfile = UserProfile(
              userId: data['id'],
              createdAt: data['created_at'] != null
                  ? DateTime.tryParse(data['created_at']) ?? DateTime.now()
                  : DateTime.now(),
              name: data['full_name'] ?? '',
              email: data['email'] ?? '',
              phone: data['phone'] ?? '',
              role: data['role'] ?? 'Student',
              profileImage: data['avatar_url'] ?? '',
              location: data['city'] ?? '',
            );
          }
        });
      }
    } catch (_) {
    }
  }

  String get _displayName {
    if (_userProfile?.name != null && _userProfile!.name.isNotEmpty)
      return _userProfile!.name;
    final user = JomnesDB.auth.currentUser;
    return user?.userMetadata?['full_name'] ??
        user?.userMetadata?['name'] ??
        user?.email?.split('@').first ??
        'Student';
  }

  String get _displayRole {
    if (_userProfile?.role != null && _userProfile!.role.isNotEmpty)
      return _userProfile!.role;
    return 'Student';
  }

  String? get _avatarUrl {
    if (_userProfile?.profileImage != null &&
        _userProfile!.profileImage.isNotEmpty)
      return _userProfile!.profileImage;
    final user = JomnesDB.auth.currentUser;
    final dynamic pic =
        user?.userMetadata?['avatar_url'] ?? user?.userMetadata?['picture'];
    return pic is String && pic.isNotEmpty ? pic : null;
  }

  void _onNavTap(int i) {
    if (i == _navIndex) return;
    setState(() => _navIndex = i);
    switch (i) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/search');
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

  void _showRatingSheet(BuildContext context, Course course) {
    double rating = 5.0;
    final TextEditingController commentController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateSB) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Rate Lesson',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 40,
                        ),
                        onPressed: () {
                          setStateSB(() => rating = index + 1.0);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Write a review (optional)...',
                      hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setStateSB(() => isSubmitting = true);
                              try {
                                final session = JomnesDB.auth.currentSession;
                                if (session != null && course.tutorId != null) {
                                  await ApiService.submitReview(
                                    accessToken: session.accessToken,
                                    mentorId: course.tutorId!,
                                    rating: rating,
                                    comment: commentController.text,
                                  );
                                  if (mounted) {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Review submitted!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                setStateSB(() => isSubmitting = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Submit Review',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _displayName;
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
                  UserAvatarHeader(
                    name: name,
                    role: _displayRole,
                    avatarUrl: avatar,
                    onTap: () => context.go('/settings'),
                  ),
                  const Spacer(),
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
                    setState(() {
                      _coursesFuture = _fetchMyCourses();
                    });
                    await Future.wait([_fetchUserProfile(), _coursesFuture]);
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
                        FutureBuilder<List<Course>>(
                          future: _coursesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(
                                    color: AppColors.accentBlue,
                                  ),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Text(
                                  'Error loading courses',
                                  style: GoogleFonts.inter(color: Colors.red),
                                ),
                              );
                            }
                            final courses = snapshot.data ?? [];
                            if (courses.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 40,
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.menu_book,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No courses enrolled',
                                        style: GoogleFonts.inter(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: courses
                                  .map((c) => CourseCard(
                                        course: c,
                                        onRateLesson: () => _showRatingSheet(context, c),
                                      ))
                                  .toList(),
                            );
                          },
                        ),
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

