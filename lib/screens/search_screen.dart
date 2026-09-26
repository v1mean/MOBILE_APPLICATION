import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../models/mentor.dart';
import '../models/user_profile.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/mentor_card.dart';
import '../widgets/notification_bell.dart';
import '../theme/app_colors.dart';
import '../constants/course_categories.dart';
import '../constants/mock_data.dart';
import '../main.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _navIndex = 1;
  final _controller = TextEditingController();
  String _query = '';

  // ── Filter State ──────────────────────────────────────────────────────────
  String? _selectedSubjectId;
  String? _selectedSubjectName;
  String? _filterDay; // full day name e.g. 'Monday'
  String? _filterCity;
  RangeValues _priceRange = const RangeValues(0, 200);

  // ── Data ──────────────────────────────────────────────────────────────────
  List<Mentor> _allMentors = [];
  List<Mentor> _mentors = [];
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoading = false;
  bool _isLoadingSubjects = true;

  UserProfile? _userProfile;
  Timer? _debounce;

  static const _days = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _loadSubjects();
    _initialLoad();
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    final session = JomnesDB.auth.currentSession;
    if (session == null) return;

    try {
      final data = await JomnesDB.from('Users')
          .select()
          .eq('user_id', session.user.id)
          .maybeSingle();
      if (mounted && data != null) {
        setState(() {
          _userProfile = UserProfile.fromJson(data);
        });
        return;
      }
    } catch (_) {}

    try {
      final data2 = await JomnesDB.from('profiles')
          .select()
          .eq('id', session.user.id)
          .maybeSingle();
      if (mounted && data2 != null) {
        setState(() {
          _userProfile = UserProfile(
            userId: data2['id'],
            createdAt: DateTime.now(),
            name: data2['full_name'] ?? '',
            email: data2['email'] ?? '',
            phone: data2['phone'] ?? '',
            role: data2['role'] ?? 'Student',
            profileImage: data2['avatar_url'] ?? '',
            location: data2['city'] ?? '',
          );
        });
      }
    } catch (_) {}
  }

  String? get _displayAvatar {
    if (_userProfile?.profileImage != null &&
        _userProfile!.profileImage.isNotEmpty) {
      return _userProfile!.profileImage;
    }
    final user = JomnesDB.auth.currentUser;
    final dynamic pic =
        user?.userMetadata?['avatar_url'] ?? user?.userMetadata?['picture'];
    final String? metaAvatar = pic is String ? pic : null;
    if (metaAvatar != null && metaAvatar.isNotEmpty) {
      return metaAvatar;
    }
    return null;
  }

  String get _displayName {
    if (_userProfile?.name != null && _userProfile!.name.isNotEmpty) {
      return _userProfile!.name;
    }
    final user = JomnesDB.auth.currentUser;
    return user?.userMetadata?['full_name'] ??
        user?.userMetadata?['name'] ??
        user?.email?.split('@').first ??
        'User';
  }

  Future<void> _loadSubjects() async {
    // Populate all course categories as subject filter chips
    final list = <Map<String, dynamic>>[
      {'name': 'All', 'id': null},
      ...kCourseCategories.map((c) => {'name': c, 'id': c}),
    ];

    if (mounted) {
      setState(() {
        _subjects = list;
        _isLoadingSubjects = false;
      });
    }
  }

  Future<void> _initialLoad() async {
    setState(() => _isLoading = true);
    _allMentors = await _fetchMentorsFromSource();
    _applyFilter();
  }

  Future<List<Mentor>> _fetchMentorsFromSource() async {
    final Map<String, Mentor> uniqueMentors = {};

    try {
      final data = await JomnesDB.from('tutor_search_view')
          .select()
          .order('course_id', ascending: false);

      for (var row in data) {
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
    } catch (err) {
      debugPrint('Error fetching db mentors in search: $err');
    }

    // Merge with mock mentors to guarantee every subject is present
    for (final m in kMockMentors) {
      if (!uniqueMentors.containsKey(m.id)) {
        uniqueMentors[m.id] = m;
      }
    }

    return uniqueMentors.values.toList();
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _applyFilter);
  }

  void _applyFilter() {
    if (!mounted) return;

    final q = _query.trim().toLowerCase();
    final filtered = _allMentors.where((m) {
      // 1. Text Search: name, subject, or bio
      if (q.isNotEmpty) {
        final nameMatch = m.name.toLowerCase().contains(q);
        final subjectMatch = m.subject.toLowerCase().contains(q);
        final bioMatch = m.bio.toLowerCase().contains(q);
        if (!nameMatch && !subjectMatch && !bioMatch) {
          return false;
        }
      }

      // 2. Subject filter
      if (_selectedSubjectName != null &&
          _selectedSubjectName != 'All' &&
          _selectedSubjectName!.isNotEmpty) {
        final selSub = _selectedSubjectName!.toLowerCase();
        final mSub = m.subject.toLowerCase();
        if (!mSub.contains(selSub) && !selSub.contains(mSub)) {
          return false;
        }
      }

      // 3. Price filter
      if (m.bookingPrice < _priceRange.start ||
          m.bookingPrice > _priceRange.end) {
        return false;
      }

      return true;
    }).toList();

    setState(() {
      _mentors = filtered;
      _isLoading = false;
    });
  }

  Future<void> _refresh() async {
    _allMentors = await _fetchMentorsFromSource();
    _applyFilter();
  }

  bool get _hasActiveFilters =>
      (_selectedSubjectId != null) ||
      (_filterDay != null) ||
      (_filterCity?.isNotEmpty ?? false) ||
      _priceRange.start > 0 ||
      _priceRange.end < 200;

  void _clearAllFilters() {
    setState(() {
      _selectedSubjectId = null;
      _selectedSubjectName = null;
      _filterDay = null;
      _filterCity = null;
      _priceRange = const RangeValues(0, 200);
      _controller.clear();
      _query = '';
    });
    _applyFilter();
  }

  void _onNavTap(int i) {
    if (i == _navIndex) return;
    setState(() => _navIndex = i);
    switch (i) {
      case 0:
        context.go('/home');
        break;
      case 2:
        context.go('/courses');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top Header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Find Mentors',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Search by mentor name, subject or price',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const NotificationBell(size: 24),
                  const SizedBox(width: 12),
                  // User Avatar Header
                  GestureDetector(
                    onTap: () => context.go('/settings'),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withAlpha(50),
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: _displayAvatar != null
                            ? Image.network(
                                _displayAvatar!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildInitialAvatar(),
                              )
                            : _buildInitialAvatar(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Body (White / Light Canvas) ───────────────────────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.pageBg,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Search text field with explicit light styling ──
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.border,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(8),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _controller,
                              onChanged: _onQueryChanged,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary, // Clearly visible dark text
                              ),
                              cursorColor: AppColors.accentBlue,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'Search mentors by name (e.g. Ms.Gooooo)...',
                                hintStyle: GoogleFonts.inter(
                                  color: AppColors.textMuted,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                                suffixIcon: _query.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 18,
                                          color: AppColors.textSecondary,
                                        ),
                                        onPressed: () {
                                          _controller.clear();
                                          _onQueryChanged('');
                                        },
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: AppColors.accentBlue,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Subject chips ────────────────────────────────
                          Text(
                            'Subject',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 34,
                            child: _isLoadingSubjects
                                ? const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.accentBlue,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _subjects.length,
                                    itemBuilder: (ctx, i) {
                                      final s = _subjects[i];
                                      return _subjectChip(
                                        s['name'] as String,
                                        s['id'] as String?,
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(height: 12),

                          // ── Day of week filter ───────────────────────────
                          Text(
                            'Availability',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 34,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _days.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (ctx, i) {
                                final day = _days[i];
                                final isSelected = _filterDay == day;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _filterDay = isSelected ? null : day;
                                    });
                                    _applyFilter();
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.accentBlue
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.accentBlue
                                            : AppColors.border,
                                      ),
                                    ),
                                    child: Text(
                                      day,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.borderDark,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── Price Range ──────────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Price Range',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '\$${_priceRange.start.toInt()} – \$${_priceRange.end.toInt()}/hr',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accentBlue,
                                ),
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.accentBlue,
                              inactiveTrackColor: AppColors.border,
                              thumbColor: AppColors.accentBlue,
                              overlayColor:
                                  AppColors.accentBlue.withAlpha(30),
                              trackHeight: 3,
                            ),
                            child: RangeSlider(
                              values: _priceRange,
                              min: 0,
                              max: 200,
                              divisions: 20,
                              onChanged: (vals) {
                                setState(() => _priceRange = vals);
                                _applyFilter();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Active filters bar ─────────────────────────────────
                    if (_hasActiveFilters)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  if (_selectedSubjectName != null &&
                                      _selectedSubjectName != 'All')
                                    _filterChip('Subject: $_selectedSubjectName',
                                        () {
                                      setState(() {
                                        _selectedSubjectId = null;
                                        _selectedSubjectName = null;
                                      });
                                      _applyFilter();
                                    }),
                                  if (_filterDay != null)
                                    _filterChip('Day: $_filterDay', () {
                                      setState(() => _filterDay = null);
                                      _applyFilter();
                                    }),
                                  if (_priceRange.start > 0 ||
                                      _priceRange.end < 200)
                                    _filterChip(
                                        '\$${_priceRange.start.toInt()}–\$${_priceRange.end.toInt()}/hr',
                                        () {
                                      setState(() => _priceRange =
                                          const RangeValues(0, 200));
                                      _applyFilter();
                                    }),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: _clearAllFilters,
                              child: Text(
                                'Clear all',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accentBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ── Result count ──────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            _isLoading
                                ? 'Searching…'
                                : '${_mentors.length} mentor${_mentors.length == 1 ? '' : 's'} found',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Results List ──────────────────────────────────────
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.accentBlue,
                        onRefresh: _refresh,
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.accentBlue,
                                ),
                              )
                            : _mentors.isEmpty
                                ? ListView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    children: [
                                      const SizedBox(height: 60),
                                      Center(
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.people_outline_rounded,
                                              size: 56,
                                              color: Colors.grey.shade300,
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'No mentors found\nfor these filters.',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                color: Colors.grey.shade400,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            if (_hasActiveFilters)
                                              TextButton(
                                                onPressed: _clearAllFilters,
                                                child: Text(
                                                  'Clear filters',
                                                  style: GoogleFonts.inter(
                                                    color: AppColors.accentBlue,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding:
                                        const EdgeInsets.only(bottom: 24),
                                    itemCount: _mentors.length,
                                    itemBuilder: (ctx, i) => MentorCard(
                                      mentor: _mentors[i],
                                      onTap: () => context
                                          .push('/mentor/${_mentors[i].id}'),
                                    ),
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          BottomNavBar(currentIndex: _navIndex, onTap: _onNavTap),
    );
  }

  Widget _buildInitialAvatar() {
    final initial =
        _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'U';
    return Container(
      color: AppColors.pastelPink,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _subjectChip(String label, String? id) {
    final isSelected = id == null
        ? (_selectedSubjectId == null || _selectedSubjectId == 'All')
        : _selectedSubjectId == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSubjectId = id;
          _selectedSubjectName = id == null ? null : label;
        });
        _applyFilter();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.accentBlue
                : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.borderDark,
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentBlue.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.accentBlue,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 13, color: AppColors.accentBlue),
          ),
        ],
      ),
    );
  }
}
