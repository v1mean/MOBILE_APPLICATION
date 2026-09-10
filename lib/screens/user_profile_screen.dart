import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../models/user_profile.dart';
import '../data/mock_data.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/course_card.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  int _navIndex = 3;
  UserProfile? _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
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

  String get _displayName {
    if (_userProfile?.name.isNotEmpty == true) return _userProfile!.name;
    final user = JomnesDB.auth.currentUser;
    return user?.userMetadata?['full_name'] ??
        user?.userMetadata?['name'] ??
        user?.email?.split('@').first ??
        'Student';
  }

  String? get _avatarUrl {
    if (_userProfile?.profileImage.isNotEmpty == true) return _userProfile!.profileImage;
    final user = JomnesDB.auth.currentUser;
    final dynamic pic = user?.userMetadata?['avatar_url'] ?? user?.userMetadata?['picture'];
    return pic is String && pic.isNotEmpty ? pic : null;
  }

  String get _joinedText {
    if (_userProfile?.createdAt != null) {
      final now = DateTime.now();
      final diff = now.difference(_userProfile!.createdAt);
      final days = diff.inDays;
      if (days < 30) return 'Joined Jomnes $days day${days == 1 ? '' : 's'} ago.';
      if (days < 365) {
        final months = (days / 30).round();
        return 'Joined Jomnes $months month${months == 1 ? '' : 's'} ago.';
      }
      final years = (days / 365).round();
      return 'Joined Jomnes $years year${years == 1 ? '' : 's'} ago.';
    }
    return 'Joined Jomnes recently.';
  }

  void _onNavTap(int i) {
    if (i == _navIndex) return;
    setState(() => _navIndex = i);
    switch (i) {
      case 0: context.go('/home'); break;
      case 1: context.go('/search'); break;
      case 2: context.go('/courses'); break;
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
      backgroundColor: const Color(0xFFF6F7F9),
      body: Column(
        children: [
          // Top Close Button
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => context.go('/home'),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(color: Colors.transparent),
                    child: const Icon(Icons.close_rounded, size: 22, color: Color(0xFF111827)),
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
                  const SizedBox(height: 10),
                  // Avatar
                  ClipOval(
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: _isLoadingProfile
                          ? const CircularProgressIndicator(color: Color(0xFF3B82F6))
                          : avatar != null
                              ? Image.network(
                                  avatar,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => CircleAvatar(
                                    radius: 45,
                                    backgroundColor: const Color(0xFFFFD5DC),
                                    child: Text(initial,
                                        style: const TextStyle(
                                            fontSize: 32, fontWeight: FontWeight.w700, color: Colors.black)),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 45,
                                  backgroundColor: const Color(0xFFFFD5DC),
                                  child: Text(initial,
                                      style: const TextStyle(
                                          fontSize: 32, fontWeight: FontWeight.w700, color: Colors.black)),
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _joinedText,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // My Courses Button Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'My Courses',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Course Cards
                  ...sampleCourses.map((c) => CourseCard(course: c)),
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