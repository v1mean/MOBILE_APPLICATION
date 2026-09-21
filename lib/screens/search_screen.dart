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
  String? _filterSubject;
  String? _filterCity;
  String? _filterDay;
  RangeValues _priceRange = const RangeValues(0, 500);

  // ── Data ──────────────────────────────────────────────────────────────────
  List<Mentor> _mentors = [];
  bool _isLoading = false;

  UserProfile? _userProfile;
  bool _isLoadingProfile = true;

  Timer? _debounce;

  static const _subjects = ['', 'Math', 'Physics', 'Chemistry', 'English', 'Programming', 'Music', 'Art'];
  static const _cities = ['', 'Phnom Penh', 'Siem Reap', 'Battambang', 'Remote'];
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _search(); // initial load of all mentors
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Debounced search ──────────────────────────────────────────────────────
  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _search);
  }

  Future<void> _search() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.searchMentors(
        query: _query.isEmpty ? null : _query,
        subject: (_filterSubject?.isEmpty ?? true) ? null : _filterSubject,
        minPrice: _priceRange.start > 0 ? _priceRange.start : null,
        maxPrice: _priceRange.end < 500 ? _priceRange.end : null,
        city: (_filterCity?.isEmpty ?? true) ? null : _filterCity,
        day: _filterDay,
      );

      if (!mounted) return;

      final raw = result['mentors'] as List? ?? [];
      setState(() {
        _mentors = raw.map((e) => Mentor.fromJson(e as Map<String, dynamic>)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchUserProfile() async {
    final session = JomnesDB.auth.currentSession;
    if (session == null) {
      if (mounted) setState(() => _isLoadingProfile = false);
      return;
    }
    try {
      final data = await JomnesDB
          .from('Users')
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

  // ── Filter Bottom Sheet ───────────────────────────────────────────────────
  void _showFilterSheet() {
    String? tempSubject = _filterSubject;
    String? tempCity = _filterCity;
    String? tempDay = _filterDay;
    RangeValues tempPrice = _priceRange;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.92,
          minChildSize: 0.5,
          expand: false,
          builder: (ctx, scroll) => SingleChildScrollView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Text('Filter Mentors',
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),

                // Subject
                Text('Subject',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151))),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: tempSubject ?? '',
                  items: _subjects
                      .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.isEmpty ? 'Any subject' : s,
                              style: GoogleFonts.inter(fontSize: 14))))
                      .toList(),
                  onChanged: (v) => setSheetState(() => tempSubject = v),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB))),
                  ),
                ),
                const SizedBox(height: 16),

                // City
                Text('City',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151))),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: tempCity ?? '',
                  items: _cities
                      .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.isEmpty ? 'Any city' : c,
                              style: GoogleFonts.inter(fontSize: 14))))
                      .toList(),
                  onChanged: (v) => setSheetState(() => tempCity = v),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB))),
                  ),
                ),
                const SizedBox(height: 16),

                // Price Range
                Text(
                    'Price: \$${tempPrice.start.toInt()} – \$${tempPrice.end.toInt() == 500 ? "500+" : tempPrice.end.toInt()}',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151))),
                RangeSlider(
                  values: tempPrice,
                  min: 0,
                  max: 500,
                  divisions: 50,
                  activeColor: AppColors.accentBlue,
                  labels: RangeLabels(
                    '\$${tempPrice.start.toInt()}',
                    '\$${tempPrice.end.toInt()}',
                  ),
                  onChanged: (v) => setSheetState(() => tempPrice = v),
                ),
                const SizedBox(height: 8),

                // Day of week
                Text('Available Day',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _days
                      .map((d) => ChoiceChip(
                            label: Text(d,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            selected: tempDay == d,
                            selectedColor: AppColors.accentBlue,
                            labelStyle: GoogleFonts.inter(
                                color: tempDay == d
                                    ? Colors.white
                                    : const Color(0xFF374151)),
                            onSelected: (sel) => setSheetState(() =>
                                tempDay = (sel ? d : null)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 28),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setSheetState(() {
                            tempSubject = null;
                            tempCity = null;
                            tempDay = null;
                            tempPrice = const RangeValues(0, 500);
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('Clear',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _filterSubject = tempSubject;
                            _filterCity = tempCity;
                            _filterDay = tempDay;
                            _priceRange = tempPrice;
                          });
                          Navigator.pop(ctx);
                          _search();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('Apply',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Derived helpers ───────────────────────────────────────────────────────
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
    if (_userProfile?.profileImage.isNotEmpty == true) {
      return _userProfile!.profileImage;
    }
    final user = JomnesDB.auth.currentUser;
    final dynamic pic =
        user?.userMetadata?['avatar_url'] ?? user?.userMetadata?['picture'];
    return pic is String && pic.isNotEmpty ? pic : null;
  }

  bool get _hasActiveFilters =>
      (_filterSubject?.isNotEmpty ?? false) ||
      (_filterCity?.isNotEmpty ?? false) ||
      _filterDay != null ||
      _priceRange.start > 0 ||
      _priceRange.end < 500;

  void _onNavTap(int i) {
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

  @override
  Widget build(BuildContext context) {
    final initial = _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'S';
    final avatar = _avatarUrl;

    return Scaffold(
      backgroundColor: AppColors.accentBlue,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: () {
                        if (_isLoadingProfile) {
                          return const CircleAvatar(
                            backgroundColor: Color(0xFFFFD5DC),
                          );
                        }
                        if (avatar != null) {
                          return Image.network(avatar,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => CircleAvatar(
                                    backgroundColor: const Color(0xFFFFD5DC),
                                    child: Text(initial,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black)),
                                  ));
                        }
                        return CircleAvatar(
                          backgroundColor: const Color(0xFFFFD5DC),
                          child: Text(initial,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black)),
                        );
                      }(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_displayName,
                          style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(_displayRole,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded,
                        color: Colors.white, size: 26),
                  ),
                ],
              ),
            ),

            // ── White content area ───────────────────────────────────────
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
                  children: [
                    const SizedBox(height: 18),

                    // ── Search + Filter Row ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // Filter button
                          GestureDetector(
                            onTap: _showFilterSheet,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: _hasActiveFilters
                                    ? AppColors.accentBlue
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: _hasActiveFilters
                                        ? AppColors.accentBlue
                                        : const Color(0xFFE5E7EB),
                                    width: 1),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.tune_rounded,
                                      size: 18,
                                      color: _hasActiveFilters
                                          ? Colors.white
                                          : const Color(0xFF111827)),
                                  const SizedBox(width: 4),
                                  Text('Filter',
                                      style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _hasActiveFilters
                                              ? Colors.white
                                              : const Color(0xFF111827))),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Search bar
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: const Color(0xFFE5E7EB), width: 1),
                              ),
                              child: TextField(
                                controller: _controller,
                                onChanged: _onQueryChanged,
                                decoration: InputDecoration(
                                  hintText: 'Search Mentors',
                                  hintStyle: GoogleFonts.inter(
                                      color: const Color(0xFF6B7280),
                                      fontSize: 14),
                                  prefixIcon: const Icon(
                                      Icons.search_rounded,
                                      color: Color(0xFF6B7280),
                                      size: 20),
                                  suffixIcon: _query.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.close,
                                              size: 18,
                                              color: Color(0xFF6B7280)),
                                          onPressed: () {
                                            _controller.clear();
                                            _onQueryChanged('');
                                          },
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Active filter chips ──────────────────────────────
                    if (_hasActiveFilters) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 32,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            if (_filterSubject?.isNotEmpty ?? false)
                              _filterChip(_filterSubject!, () {
                                setState(() => _filterSubject = null);
                                _search();
                              }),
                            if (_filterCity?.isNotEmpty ?? false)
                              _filterChip(_filterCity!, () {
                                setState(() => _filterCity = null);
                                _search();
                              }),
                            if (_filterDay != null)
                              _filterChip(_filterDay!, () {
                                setState(() => _filterDay = null);
                                _search();
                              }),
                            if (_priceRange.start > 0 || _priceRange.end < 500)
                              _filterChip(
                                  '\$${_priceRange.start.toInt()}–\$${_priceRange.end.toInt()}',
                                  () {
                                setState(() =>
                                    _priceRange = const RangeValues(0, 500));
                                _search();
                              }),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // ── Result count ─────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text(
                            _isLoading
                                ? 'Searching…'
                                : '${_mentors.length} mentor${_mentors.length == 1 ? '' : 's'} found',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

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
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    children: [
                                      const SizedBox(height: 80),
                                      Center(
                                          child: Column(
                                        children: [
                                          Icon(Icons.search_off_rounded,
                                              size: 48,
                                              color: Colors.grey.shade400),
                                          const SizedBox(height: 12),
                                          Text('No mentors found.',
                                              style: GoogleFonts.inter(
                                                  color: Colors.grey)),
                                        ],
                                      )),
                                    ],
                                  )
                                : ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.only(bottom: 16),
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

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
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
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentBlue)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14, color: AppColors.accentBlue),
          ),
        ],
      ),
    );
  }
}