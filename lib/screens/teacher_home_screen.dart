import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../widgets/teacher_bottom_nav_bar.dart';

class _ScheduleItem {
  final String name;
  final String location;
  final String time;
  final Color color;
  _ScheduleItem(this.name, this.location, this.time, this.color);
}

class _CourseItem {
  final String title;
  final String description;
  final double rating;
  final String timeAgo;
  final Color color;
  _CourseItem(this.title, this.description, this.rating, this.timeAgo, this.color);
}

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  static final _schedule = [
    _ScheduleItem('Socheatre', 'Chroy Chongva', '10am - 11am', const Color(0xFFF3E8FF)),
    _ScheduleItem('Srey Pich', 'Preak Leab', '8am - 9am', const Color(0xFFE0F2FE)),
    _ScheduleItem('Bros Sok', 'Orussey', '9am - 10am', const Color(0xFFDCFCE7)),
  ];

  static final _courses = [
    _CourseItem('Master Chemistry Formular /\nBac II Preparation Course', 'Practice Exercise/ understand\nmore about formula.', 4.5, '1 day ago', const Color(0xFFF3D0FF)),
    _CourseItem('Bac II Chemistry Most\nPractice Exercises', 'Practice Exercise/ understand\nmore about formula.', 4.3, '10hrs ago', const Color(0xFFBFEFFF)),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          // Dark header
          Container(
            color: const Color(0xFF0A0A12),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF7B3FC8),
                      child: ClipOval(
                        child: Image.asset('assets/images/jessica_avatar.png',
                            width: 48, height: 48, fit: BoxFit.cover,
                            errorBuilder: (ctx, e, st) => const Icon(Icons.person, color: Colors.white, size: 28)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jessica Carl', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('Teacher', style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF16161E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Icon(Icons.notifications_outlined, color: Colors.white70, size: 22),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today Schedule
                  Text('Today Schedule', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [const BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        ..._schedule.map((s) => _ScheduleRow(item: s)),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('See more', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Latest Courses
                  Text('Your Latest Courses', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                  const SizedBox(height: 12),
                  ..._courses.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _CourseCard(item: c),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/teacher-upload'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 4,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      bottomNavigationBar: const TeacherBottomNavBar(currentTab: TeacherNavTab.course),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final _ScheduleItem item;
  const _ScheduleRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: item.color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Icon(Icons.person_outline, color: Colors.grey[600], size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
                Text(item.location, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B7280))),
              ],
            ),
          ),
          Text(item.time, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF374151))),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final _CourseItem item;
  const _CourseCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(item.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
              ),
              const SizedBox(width: 8),
              Icon(Icons.edit_outlined, size: 18, color: Colors.grey[600]),
            ],
          ),
          const SizedBox(height: 6),
          Text(item.description, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280))),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('${item.rating} rating', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF1A1A2E))),
              const Spacer(),
              Text(item.timeAgo, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280))),
            ],
          ),
        ],
      ),
    );
  }
}
