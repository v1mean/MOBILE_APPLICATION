import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../models/mentor.dart';
import '../models/user_profile.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/mentor_card.dart';
import '../theme/app_colors.dart';
import '../data/mock_data.dart';
import '../main.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _navIndex = 1;
  String _filter = 'Mentors';
  final _controller = TextEditingController();
  String _query = '';
  
  List<Mentor> _allMentors = [];
  bool _isLoading = true;

  UserProfile? _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _fetchMentors();
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

  Future<void> _fetchMentors() async {
    try {
      final data = await JomnesDB.from('tutor_profiles')
          .select('*, Users(name, profile_image)');
      if (mounted && data.isNotEmpty) {
        setState(() {
          _allMentors = (data as List).map((e) => Mentor.fromJson(e)).toList();
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _allMentors = defaultMentors;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _allMentors.where((m) =>
        m.name.toLowerCase().contains(_query.toLowerCase()) ||
        m.subject.toLowerCase().contains(_query.toLowerCase())).toList();

    void onNavTap(int i) {
      if (i == _navIndex) return;
      setState(() => _navIndex = i);
      switch (i) {
        case 0: context.go('/home'); break;
        case 2: context.go('/courses'); break;
        case 3: context.go('/profile'); break;
        case 4: context.go('/settings'); break;
        default: break;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Column(
        children: [
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
                              child: () {
                                final avatar = _avatarUrl;
                                final initial = _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'U';
                                if (_isLoadingProfile) {
                                  return const CircularProgressIndicator(
                                      color: AppColors.accentBlue, strokeWidth: 2);
                                }
                                if (avatar != null) {
                                  return Image.network(
                                    avatar,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => CircleAvatar(
                                      backgroundColor: const Color(0xFFFFD5DC),
                                      child: Text(initial,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700, color: Colors.black)),
                                    ),
                                  );
                                }
                                return CircleAvatar(
                                  backgroundColor: const Color(0xFFFFD5DC),
                                  child: Text(initial,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700, color: Colors.black)),
                                );
                              }(),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _displayName,
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
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF6F7F9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  // Search Row with Filter Dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Filter Dropdown
                        GestureDetector(
                          onTap: () {
                            setState(() => _filter = _filter == 'Mentors' ? 'Courses' : 'Mentors');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _filter,
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF111827)),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF111827)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Search Bar
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                            ),
                            child: TextField(
                              controller: _controller,
                              onChanged: (v) => setState(() => _query = v),
                              decoration: InputDecoration(
                                hintText: 'Search Mentors',
                                hintStyle: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 14),
                                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6B7280), size: 20),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Search history',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF6B7280)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _isLoading 
                      ? const Center(child: CircularProgressIndicator(color: AppColors.accentBlue))
                      : filtered.isEmpty 
                        ? Center(child: Text('No mentors found.', style: GoogleFonts.inter(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) => MentorCard(
                              mentor: filtered[i],
                              onTap: () => context.push('/mentor/${filtered[i].id}'),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _navIndex, onTap: onNavTap),
    );
  }
}