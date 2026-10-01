import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/student/search_view_model.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/mentor_card.dart';
import '../../widgets/notification_bell.dart';
import '../../theme/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _navIndex = 1;
  final _controller = TextEditingController();
  late final SearchViewModel _vm;

  static const _days = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  @override
  void initState() {
    super.initState();
    _vm = context.read<SearchViewModel>();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearAllFilters() {
    _controller.clear();
    _vm.clearAllFilters();
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
    context.watch<SearchViewModel>();
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
                        child: _vm.displayAvatar != null
                            ? Image.network(
                                _vm.displayAvatar!,
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
                              onChanged: _vm.setQuery,
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
                                suffixIcon: _vm.query.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 18,
                                          color: AppColors.textSecondary,
                                        ),
                                        onPressed: () {
                                          _controller.clear();
                                          _vm.setQuery('');
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
                            child: _vm.isLoadingSubjects
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
                                    itemCount: _vm.subjects.length,
                                    itemBuilder: (ctx, i) {
                                      final s = _vm.subjects[i];
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
                                final isSelected = _vm.filterDay == day;
                                return GestureDetector(
                                  onTap: () => _vm.toggleDay(day),
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
                                '\$${_vm.minPrice.toInt()} – \$${_vm.maxPrice.toInt()}/hr',
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
                              values: RangeValues(_vm.minPrice, _vm.maxPrice),
                              min: 0,
                              max: 200,
                              divisions: 20,
                              onChanged: (vals) =>
                                  _vm.setPriceRange(vals.start, vals.end),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Active filters bar ─────────────────────────────────
                    if (_vm.hasActiveFilters)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  if (_vm.selectedSubjectName != null &&
                                      _vm.selectedSubjectName != 'All')
                                    _filterChip(
                                      'Subject: ${_vm.selectedSubjectName}',
                                      _vm.clearSubject,
                                    ),
                                  if (_vm.filterDay != null)
                                    _filterChip(
                                      'Day: ${_vm.filterDay}',
                                      _vm.clearDay,
                                    ),
                                  if (_vm.minPrice > 0 ||
                                      _vm.maxPrice < 200)
                                    _filterChip(
                                        '\$${_vm.minPrice.toInt()}–\$${_vm.maxPrice.toInt()}/hr',
                                        _vm.resetPriceRange),
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
                            _vm.isLoading
                                ? 'Searching…'
                                : '${_vm.mentors.length} mentor${_vm.mentors.length == 1 ? '' : 's'} found',
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
                        onRefresh: _vm.refresh,
                        child: _vm.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.accentBlue,
                                ),
                              )
                            : _vm.mentors.isEmpty
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
                                            if (_vm.hasActiveFilters)
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
                                    itemCount: _vm.mentors.length,
                                    itemBuilder: (ctx, i) => MentorCard(
                                      mentor: _vm.mentors[i],
                                      onTap: () => context
                                          .push('/mentor/${_vm.mentors[i].id}'),
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
        _vm.displayName.isNotEmpty ? _vm.displayName[0].toUpperCase() : 'U';
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
        ? (_vm.selectedSubjectId == null || _vm.selectedSubjectId == 'All')
        : _vm.selectedSubjectId == id;
    return GestureDetector(
      onTap: () => _vm.selectSubject(id, label),
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
