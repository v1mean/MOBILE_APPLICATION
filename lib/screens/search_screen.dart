import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_data.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/mentor_card.dart';
import '../theme/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    final filtered = mentors.where((m) =>
        m.name.toLowerCase().contains(_query.toLowerCase()) ||
        m.subject.toLowerCase().contains(_query.toLowerCase())).toList();

    void onNavTap(int i) {
      if (i == _navIndex) return;
      setState(() => _navIndex = i);
      switch (i) {
        case 0: context.go('/home'); break;
        case 2: context.go('/courses'); break;
        case 3: context.go('/profile'); break;
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accentBlue, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        'https://api.dicebear.com/9.x/avataaars/png?seed=Jessica&backgroundColor=ffd5dc',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const ColoredBox(
                          color: AppColors.tagPurple,
                          child: Center(child: Text('J', style: TextStyle(fontWeight: FontWeight.w700))),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Jessica Carl',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.white)),
                      Text('Student',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textWhite70)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.notifications_outlined, color: AppColors.white, size: 26),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.lightBg,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Search bar row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Filter dropdown
                        GestureDetector(
                          onTap: () {
                            setState(() => _filter = _filter == 'Mentors' ? 'Courses' : 'Mentors');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                            ),
                            child: Row(
                              children: [
                                Text(_filter,
                                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Search input
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                            ),
                            child: TextField(
                              controller: _controller,
                              onChanged: (v) => setState(() => _query = v),
                              decoration: InputDecoration(
                                hintText: 'Search Mentors',
                                hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
                                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                                border: InputBorder.none, enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none, filled: false,
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Search history',
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: filtered.length,
                      itemBuilder: (context, i) => MentorCard(
                        mentor: filtered[i],
                        onTap: () => context.push('/mentor/${filtered[i].id}'),
                      ).animate(delay: (i * 80).ms).fadeIn().slideY(begin: 0.1),
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
