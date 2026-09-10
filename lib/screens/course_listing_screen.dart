import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../models/mentor.dart';
import '../widgets/mentor_card.dart';
import '../data/mock_data.dart';
import '../main.dart';

class CourseListingScreen extends StatefulWidget {
  final String subject;

  const CourseListingScreen({super.key, required this.subject});

  @override
  State<CourseListingScreen> createState() => _CourseListingScreenState();
}

class _CourseListingScreenState extends State<CourseListingScreen> {
  List<Mentor> _allMentors = [];
  bool _isLoading = true;
  String _selectedTab = 'All Mentors';

  @override
  void initState() {
    super.initState();
    _fetchMentors();
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

  List<Mentor> get _filteredMentors {
    final sub = widget.subject.toLowerCase().trim();
    final list = _allMentors.where((m) {
      final mSub = m.subject.toLowerCase().trim();
      return mSub.contains(sub) ||
          sub.contains(mSub) ||
          m.name.toLowerCase().contains(sub);
    }).toList();

    // If no exact match found, show top mentors with high ratings as recommendations
    if (list.isEmpty) {
      return _allMentors;
    }

    final result = List<Mentor>.from(list.isEmpty ? _allMentors : list);
    if (_selectedTab == 'Top Rated') {
      result.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final mentors = _filteredMentors;
    final isRecommended = !mentors.any((m) =>
        m.subject.toLowerCase().contains(widget.subject.toLowerCase()));

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Column(
        children: [
          // Header Bar
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 20, 16),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accentBlue.withAlpha(100),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.school_rounded,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          '${mentors.length} listings',
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

          // Main Content Container
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filter Tabs
                      Row(
                        children: [
                          _buildTab('All Mentors'),
                          const SizedBox(width: 8),
                          _buildTab('Top Rated'),
                        ],
                      ),
                      const SizedBox(height: 18),

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

                      // Listing Section Header
                      Text(
                        'Available Mentors (${mentors.length})',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Mentors List
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (mentors.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'No mentors found for ${widget.subject}.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: mentors.length,
                          itemBuilder: (context, i) => MentorCard(
                            mentor: mentors[i],
                            onTap: () =>
                                context.push('/mentor/${mentors[i].id}'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label) {
    final isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = label),
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
