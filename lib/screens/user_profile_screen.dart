import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../models/user_profile.dart';
import '../models/mentor.dart';
import '../services/api_service.dart';
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
  bool _isUploadingAvatar = false;

  List<Course> _myCourses = [];
  bool _isLoadingCourses = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchMyCourses();
  }

  Future<void> _pickAndUploadAvatar() async {
    final session = JomnesDB.auth.currentSession;
    if (session == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
    );
    if (picked == null) return;

    if (!mounted) return;
    setState(() => _isUploadingAvatar = true);

    try {
      final result = await ApiService.uploadAvatar(
        picked.path,
        session.accessToken,
      );
      if (result['success'] == true && mounted) {
        // Refresh profile from Supabase to pick up the new URL and bust cache
        _avatarTimestamp = DateTime.now().millisecondsSinceEpoch;
        await _fetchUserProfile();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo updated!')),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result['message'] ?? 'Upload failed. Try again.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
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

  int _avatarTimestamp = DateTime.now().millisecondsSinceEpoch;

  String? get _avatarUrl {
    String? url;
    if (_userProfile?.profileImage.isNotEmpty == true) {
      url = _userProfile!.profileImage;
    } else {
      final user = JomnesDB.auth.currentUser;
      final dynamic pic = user?.userMetadata?['avatar_url'] ?? user?.userMetadata?['picture'];
      if (pic is String && pic.isNotEmpty) url = pic;
    }
    
    if (url != null) {
      // Bust cache using timestamp
      return url.contains('?') ? url : '$url?t=$_avatarTimestamp';
    }
    return null;
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
                  // Avatar with Edit Button
                  Stack(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 90,
                          height: 90,
                          child: _isLoadingProfile || _isUploadingAvatar
                              ? Container(
                                  color: const Color(0xFFFFD5DC),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF3B82F6)),
                                  ))
                              : avatar != null
                                  ? Image.network(
                                      avatar,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => CircleAvatar(
                                        radius: 45,
                                        backgroundColor:
                                            const Color(0xFFFFD5DC),
                                        child: Text(initial,
                                            style: const TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black)),
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 45,
                                      backgroundColor:
                                          const Color(0xFFFFD5DC),
                                      child: Text(initial,
                                          style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black)),
                                    ),
                        ),
                      ),
                      // Edit icon overlay
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _isUploadingAvatar
                              ? null
                              : _pickAndUploadAvatar,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.edit,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
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
                  if (_isLoadingCourses)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
                    ))
                  else if (_myCourses.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('No courses enrolled.', style: GoogleFonts.inter(color: Colors.grey)),
                    )
                  else
                    ..._myCourses.map((c) => CourseCard(course: c)),
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