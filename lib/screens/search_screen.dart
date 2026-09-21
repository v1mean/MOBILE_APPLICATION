import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../models/mentor.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/mentor_card.dart';
import '../theme/app_colors.dart';
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
  String? _filterDay;          // full day name e.g. 'Monday'
  String? _filterCity;
  RangeValues _priceRange = const RangeValues(0, 200);

  // ── Data ──────────────────────────────────────────────────────────────────
  List<Mentor> _mentors = [];
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoading = false;
  bool _isLoadingSubjects = true;
  String? _error;

  UserProfile? _userProfile;
  Timer? _debounce;

  static const _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _loadSubjects();
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    final subjects = await ApiService.fetchSubjects();
    if (mounted) {
      setState(() {
        _subjects = subjects;
        _isLoadingSubjects = false;
      });
      _search(); // initial load after subjects ready
    }
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _search);
  }

  Future<void> _search() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final result = await ApiService.fetchMentors(
        query: _query.isEmpty ? null : _query,
        subjectId: _selectedSubjectId,
        minPrice: _priceRange.start > 0 ? _priceRange.start : null,
        maxPrice: _priceRange.end < 200 ? _priceRange.end : null,
        dayOfWeek: _filterDay,
        city: (_filterCity?.isEmpty ?? true) ? null : _filterCity,
      );
      if (!mounted) return;
      final raw = result['mentors'] as List? ?? [];
      setState(() {
        _mentors = raw.map((e) => Mentor.fromJson(e as Map<String, dynamic>)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _error = 'Could not connect. Check backend.'; });
    }
  }

  Future<void> _fetchUserProfile() async {
    final session = JomnesDB.auth.currentSession;
    if (session == null) return;
    try {
      final data = await JomnesDB.from('Users').select().eq('user_id', session.user.id).maybeSingle();
      if (mounted && data != null) setState(() => _userProfile = UserProfile.fromJson(data));
    } catch (_) {}
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
    });
    _search();
  }

  void _onNavTap(int i) {
    if (i == _navIndex) return;
    setState(() => _navIndex = i);
    switch (i) {
      case 0: context.go('/home'); break;
      case 2: context.go('/courses'); break;
      case 3: context.go('/profile'); break;
      case 4: context.go('/settings'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _userProfile?.name ?? JomnesDB.auth.currentUser?.userMetadata?['full_name'] ?? 'User';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final avatarUrl = _userProfile?.profileImage.isNotEmpty == true ? _userProfile!.profileImage : null;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Find Mentors',
                            style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        Text('Search by subject, day or price',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white60)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/profile'),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFFFD5DC),
                      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null
                          ? Text(initial,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black))
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Body (white card) ──────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F7F9),
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
                          // ── Search bar ──────────────────────────────────
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withAlpha(10),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2))
                              ],
                            ),
                            child: TextField(
                              controller: _controller,
                              onChanged: _onQueryChanged,
                              style: GoogleFonts.inter(
                                  fontSize: 14, color: const Color(0xFF111827)),
                              decoration: InputDecoration(
                                hintText: 'Search mentors, subjects...',
                                hintStyle: GoogleFonts.inter(
                                    color: const Color(0xFF9CA3AF), fontSize: 14),
                                prefixIcon: const Icon(Icons.search_rounded,
                                    color: Color(0xFF9CA3AF), size: 20),
                                suffixIcon: _query.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.close,
                                            size: 18, color: Color(0xFF9CA3AF)),
                                        onPressed: () {
                                          _controller.clear();
                                          _onQueryChanged('');
                                        })
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Subject chips ────────────────────────────────
                          Text('Subject',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF6B7280))),
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
                                          color: AppColors.accentBlue),
                                    ))
                                : ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      _subjectChip('All', null),
                                      ..._subjects.map((s) =>
                                          _subjectChip(
                                              s['name'] as String,
                                              s['id'] as String)),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 14),

                          // ── Day chips ────────────────────────────────────
                          Text('Availability',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF6B7280))),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 34,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _days.length,
                              separatorBuilder: (_, _) => const SizedBox(width: 6),
                              itemBuilder: (_, i) {
                                final day = _days[i];
                                final label = day.substring(0, 3);
                                final isSelected = _filterDay == day;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() =>
                                        _filterDay = isSelected ? null : day);
                                    _search();
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
                                              : const Color(0xFFE5E7EB)),
                                    ),
                                    child: Text(
                                      label,
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF374151)),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 14),

                          // ── Price range ──────────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Price Range',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF6B7280))),
                              Text(
                                '\$${_priceRange.start.toInt()} – \$${_priceRange.end.toInt()}/hr',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accentBlue),
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: SliderThemeData(
                              rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 8),
                              trackHeight: 3,
                              activeTrackColor: AppColors.accentBlue,
                              inactiveTrackColor: const Color(0xFFE5E7EB),
                              thumbColor: AppColors.accentBlue,
                              overlayColor: AppColors.accentBlue.withAlpha(30),
                            ),
                            child: RangeSlider(
                              values: _priceRange,
                              min: 0,
                              max: 200,
                              divisions: 40,
                              onChanged: (v) => setState(() => _priceRange = v),
                              onChangeEnd: (_) => _search(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Active filter chips ──────────────────────────────
                    if (_hasActiveFilters)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                children: [
                                  if (_selectedSubjectName != null)
                                    _filterChip('Subject: $_selectedSubjectName', () {
                                      setState(() {
                                        _selectedSubjectId = null;
                                        _selectedSubjectName = null;
                                      });
                                      _search();
                                    }),
                                  if (_filterDay != null)
                                    _filterChip('Day: ${_filterDay!.substring(0, 3)}', () {
                                      setState(() => _filterDay = null);
                                      _search();
                                    }),
                                  if (_priceRange.start > 0 || _priceRange.end < 200)
                                    _filterChip(
                                        '\$${_priceRange.start.toInt()}–\$${_priceRange.end.toInt()}/hr',
                                        () {
                                      setState(() => _priceRange = const RangeValues(0, 200));
                                      _search();
                                    }),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: _clearAllFilters,
                              child: Text('Clear all',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.accentBlue)),
                            ),
                          ],
                        ),
                      ),

                    // ── Result count + error ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            _error != null
                                ? _error!
                                : _isLoading
                                    ? 'Searching…'
                                    : '${_mentors.length} mentor${_mentors.length == 1 ? '' : 's'} found',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _error != null
                                    ? Colors.red
                                    : const Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),

                    // ── Results ───────────────────────────────────────────
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.accentBlue,
                        onRefresh: _search,
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.accentBlue))
                            : _mentors.isEmpty
                                ? ListView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    children: [
                                      const SizedBox(height: 60),
                                      Center(
                                        child: Column(
                                          children: [
                                            Icon(Icons.people_outline_rounded,
                                                size: 56,
                                                color: Colors.grey.shade300),
                                            const SizedBox(height: 12),
                                            Text(
                                              'No mentors found\nfor these filters.',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                  color: Colors.grey.shade400,
                                                  fontSize: 15),
                                            ),
                                            const SizedBox(height: 16),
                                            if (_hasActiveFilters)
                                              TextButton(
                                                onPressed: _clearAllFilters,
                                                child: Text('Clear filters',
                                                    style: GoogleFonts.inter(
                                                        color: AppColors.accentBlue,
                                                        fontWeight: FontWeight.w600)),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : ListView.builder(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.only(bottom: 24),
                                    itemCount: _mentors.length,
                                    itemBuilder: (ctx, i) => MentorCard(
                                      mentor: _mentors[i],
                                      onTap: () => context.push('/mentor/${_mentors[i].id}'),
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

  Widget _subjectChip(String label, String? id) {
    final isSelected = id == null
        ? _selectedSubjectId == null
        : _selectedSubjectId == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSubjectId = id;
          _selectedSubjectName = id == null ? null : label;
        });
        _search();
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
                  : const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF374151)),
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
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentBlue)),
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