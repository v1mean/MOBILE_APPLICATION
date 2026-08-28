import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_data.dart';
import '../models/mentor.dart';
import '../widgets/course_card.dart';
import '../theme/app_colors.dart';

class MentorProfileScreen extends StatefulWidget {
  final int mentorId;
  const MentorProfileScreen({super.key, required this.mentorId});

  @override
  State<MentorProfileScreen> createState() => _MentorProfileScreenState();
}

class _MentorProfileScreenState extends State<MentorProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _following = false;

  Mentor get _mentor => mentors.firstWhere((m) => m.id == widget.mentorId, orElse: () => mentors.first);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final m = _mentor;
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with close
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
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
                    const SizedBox(height: 12),
                    // Avatar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 90, height: 90,
                        color: AppColors.tagBlue,
                        child: Image.network(
                          m.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(m.name[0],
                                style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.accentBlue)),
                          ),
                        ),
                      ),
                    ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
                    const SizedBox(height: 14),
                    Text(m.name,
                        style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800))
                        .animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),
                    const SizedBox(height: 6),
                    Text(m.bio,
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.5))
                        .animate(delay: 150.ms).fadeIn(),
                    const SizedBox(height: 20),
                    // Buttons row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentBlue,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text('Book Class | \$${m.bookingPrice.toInt()}',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _following = !_following),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(color: AppColors.border, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(_following ? 'Following' : 'Follow',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                        ),
                      ],
                    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
                    const SizedBox(height: 24),
                    // Stats
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                      ),
                      child: Row(
                        children: [
                          _StatItem(label: 'Students', value: _formatCount(m.students)),
                          _divider(),
                          _StatItem(label: 'Classes', value: _formatCount(m.classes)),
                          _divider(),
                          _StatItem(label: 'Followers', value: _formatCount(m.followers)),
                        ],
                      ),
                    ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.2),
                    const SizedBox(height: 20),
                    // Tab bar
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
                        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 13),
                        labelColor: AppColors.textPrimary,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicator: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)],
                        ),
                        tabs: const [
                          Tab(text: 'Courses'),
                          Tab(text: 'Source Files'),
                          Tab(text: 'Discussion'),
                        ],
                      ),
                    ).animate(delay: 300.ms).fadeIn(),
                    const SizedBox(height: 16),
                    // Course cards
                    ...m.courses.map((c) => CourseCard(course: c).animate().fadeIn().slideY(begin: 0.1)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 36, color: AppColors.border);
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
