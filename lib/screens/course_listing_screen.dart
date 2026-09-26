import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../models/mentor.dart';
import '../widgets/mentor_card.dart';
import '../widgets/rich_course_card.dart';
import '../constants/course_categories.dart';
import '../constants/mock_data.dart';
import '../main.dart';

class CourseListingScreen extends StatefulWidget {
  final String subject;

  const CourseListingScreen({super.key, required this.subject});

  @override
  State<CourseListingScreen> createState() => _CourseListingScreenState();
}

class _CourseListingScreenState extends State<CourseListingScreen>
    with SingleTickerProviderStateMixin {
  List<Mentor> _allMentors = [];
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([_fetchMentors(), _fetchCourses()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchMentors() async {
    try {
      final usersData = await JomnesDB.from('Users')
          .select()
          .or('role.eq.mentor,role.eq.tutor');

      final userList = usersData as List;
      final userIds = userList.map((u) => u['user_id']).toList();

      List<dynamic> profiles = [];
      if (userIds.isNotEmpty) {
        profiles = await JomnesDB.from('tutor_profiles')
            .select()
            .filter('user_id', 'in', userIds) as List;
      }
      final profileMap = {for (var p in profiles) p['user_id'].toString(): p};

      final mentors = userList.map((u) {
        final uid = u['user_id'].toString();
        final p = profileMap[uid] ?? {};
        final subject = (p['subject'] as String? ?? '').isNotEmpty
            ? p['subject'] as String
            : Mentor.inferMentorSubject(p['bio'], p['education']);

        final avatar = (u['profile_image'] != null &&
                u['profile_image'].toString().trim().isNotEmpty)
            ? u['profile_image'].toString()
            : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&fit=crop';

        return Mentor(
          id: uid,
          name: u['name'] ?? 'Mentor',
          subject: subject,
          experience: '${p['experience_years'] ?? 5} years experience',
          timeSlot: 'Flexible',
          avatarUrl: avatar,
          rating: (p['rating'] as num?)?.toDouble() ?? 4.9,
          students: (p['total_students'] as num?)?.toInt() ?? 120,
          classes: 50,
          followers: 300,
          bookingPrice: (p['hourly_rate'] as num?)?.toDouble() ?? 35.0,
          bio: p['bio'] ?? 'Experienced mentor.',
          courses: [],
        );
      }).toList();

      // Combine real mentors from database with mock mentors across all subjects
      final combinedMentors = <Mentor>[...mentors];
      final seenIds = mentors.map((m) => m.id).toSet();
      for (final mockM in kMockMentors) {
        if (seenIds.add(mockM.id)) {
          combinedMentors.add(mockM);
        }
      }

      if (mounted) {
        setState(() {
          _allMentors = combinedMentors;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _allMentors = kMockMentors;
        });
      }
    }
  }


  Future<void> _fetchCourses() async {
    try {
      List<Map<String, dynamic>> dbCourses = [];
      try {
        final data = await JomnesDB.from('courses')
            .select('*, Users(name)')
            .order('id', ascending: true);
        dbCourses = List<Map<String, dynamic>>.from(data);
      } catch (_) {}

      // Combine real uploaded courses from DB with mock courses
      final combinedCourses = <Map<String, dynamic>>[...dbCourses];
      final seenTitles = dbCourses.map((c) => (c['title'] ?? '').toString().toLowerCase().trim()).toSet();
      for (final mc in getMockCoursesAsJson()) {
        final title = (mc['title'] ?? '').toString().toLowerCase().trim();
        if (seenTitles.add(title)) {
          combinedCourses.add(mc);
        }
      }

      if (mounted) {
        setState(() {
          _courses = combinedCourses;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _courses = getMockCoursesAsJson();
        });
      }
    }
  }

  List<Mentor> get _filteredMentors {
    final sub = widget.subject.toLowerCase().trim();
    final list = _allMentors.where((m) {
      final mSub = m.subject.toLowerCase().trim();
      return mSub == sub ||
          mSub.contains(sub) ||
          sub.contains(mSub) ||
          m.name.toLowerCase().contains(sub);
    }).toList();

    // If no exact match, show all mentors as recommendations
    if (list.isEmpty) return _allMentors;
    return list;
  }

  List<Map<String, dynamic>> get _filteredCourses {
    final sub = widget.subject.toLowerCase().trim();

    // Match by category column or title
    final matched = _courses.where((c) {
      final cat = (c['category'] as String? ?? '').toLowerCase().trim();
      final title = (c['title'] as String? ?? '').toLowerCase().trim();
      return cat == sub ||
          cat.contains(sub) ||
          sub.contains(cat) ||
          title.contains(sub);
    }).toList();

    return matched;
  }

  @override
  Widget build(BuildContext context) {
    final theme = getCategoryTheme(widget.subject);
    final mentors = _filteredMentors;
    final courses = _filteredCourses;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Column(
        children: [
          // Header Bar
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.subject,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Courses & Expert Mentors',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Stats pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accentBlue.withAlpha(100)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.school_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          '${courses.length + mentors.length}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Container(
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withAlpha(25)),
              ),
              child: TabBar(
                controller: _tabController,
                labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle:
                    GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13),
                labelColor: const Color(0xFF111827),
                unselectedLabelColor: Colors.white70,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(theme.icon, size: 15),
                        const SizedBox(width: 6),
                        const Text('Courses'),
                      ],
                    ),
                  ),
                  const Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_rounded, size: 15),
                        SizedBox(width: 6),
                        Text('Mentors'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Content Container
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 14),
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          // === COURSES TAB ===
                          _CoursesTabContent(
                            courses: courses,
                            subject: widget.subject,
                          ),

                          // === MENTORS TAB ===
                          _MentorsTabContent(
                            mentors: mentors,
                            subject: widget.subject,
                            onMentorTap: (m) => context.push('/mentor/${m.id}'),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Courses Tab ─────────────────────────────────────────────────────────────

class _CoursesTabContent extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  final String subject;

  const _CoursesTabContent({required this.courses, required this.subject});

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_rounded, size: 56, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'No courses found for $subject',
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      itemCount: courses.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Available Courses (${courses.length})',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
            ),
          );
        }
        final c = courses[i - 1];
        final users = c['Users'] as Map<String, dynamic>? ?? {};
        final category = c['category'] as String? ?? subject;
        final level = c['level'] as String? ?? 'Beginner';
        final price = (c['price'] as num?)?.toDouble() ?? 0.0;
        final rating = (c['rating'] as num?)?.toDouble() ?? 4.5;
        final ratingCount = (c['rating_count'] as num?)?.toInt() ??
            (c['total_students'] as num?)?.toInt() ??
            120;
        final duration = (c['duration_hours'] as num?)?.toInt() ?? 10;

        return RichCourseCard(
          title: c['title'] as String? ?? 'Untitled Course',
          description: c['description'] as String? ?? 'A comprehensive course covering the essentials.',
          instructorName: users['name'] as String? ?? 'Expert Instructor',
          category: category.isEmpty ? subject : category,
          rating: rating,
          ratingCount: ratingCount,
          price: price,
          durationHours: duration,
          level: level,
        );
      },
    );
  }
}

// ─── Mentors Tab ─────────────────────────────────────────────────────────────

class _MentorsTabContent extends StatefulWidget {
  final List<Mentor> mentors;
  final String subject;
  final void Function(Mentor) onMentorTap;

  const _MentorsTabContent({
    required this.mentors,
    required this.subject,
    required this.onMentorTap,
  });

  @override
  State<_MentorsTabContent> createState() => _MentorsTabContentState();
}

class _MentorsTabContentState extends State<_MentorsTabContent> {
  String _selectedFilter = 'All';

  List<Mentor> get _filtered {
    switch (_selectedFilter) {
      case 'Top Rated':
        final sorted = List<Mentor>.from(widget.mentors)
          ..sort((a, b) => b.rating.compareTo(a.rating));
        return sorted;
      case 'Affordable':
        final sorted = List<Mentor>.from(widget.mentors)
          ..sort((a, b) => a.bookingPrice.compareTo(b.bookingPrice));
        return sorted;
      default:
        return widget.mentors;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mentors = _filtered;
    final isRecommended = !mentors.any(
      (m) => m.subject.toLowerCase().contains(widget.subject.toLowerCase()),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        // Filter chips
        Row(
          children: [
            _filterChip('All'),
            const SizedBox(width: 8),
            _filterChip('Top Rated'),
            const SizedBox(width: 8),
            _filterChip('Affordable'),
          ],
        ),
        const SizedBox(height: 16),

        // Recommendation notice
        if (isRecommended)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: Color(0xFF2563EB), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Showing top recommended tutors for ${widget.subject}.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF1E40AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Header
        Text(
          'Available Mentors (${mentors.length})',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),

        // Mentor cards
        if (mentors.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No mentors found for ${widget.subject}.',
                style: GoogleFonts.inter(
                    fontSize: 14, color: const Color(0xFF6B7280)),
              ),
            ),
          )
        else
          ...mentors.map(
            (m) => MentorCard(
              mentor: m,
              onTap: () => widget.onMentorTap(m),
            ),
          ),
      ],
    );
  }

  Widget _filterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}

