import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/teacher_bottom_nav_bar.dart';

class _Student {
  final String name;
  final String location;
  _Student(this.name, this.location);
}

class TeacherSchedulesScreen extends StatelessWidget {
  const TeacherSchedulesScreen({super.key});

  static final _students = [
    _Student('Srey Pich', 'Preak Leab'),
    _Student('Bros Sok', 'Orussey'),
    _Student('Socheatre', 'Chroy Chongva'),
    _Student('Ni Ta', 'Toul Kork'),
  ];

  static final _slots = [
    (time: '8am', color: const Color(0xFFBFEFFF)),
    (time: '10am', color: const Color(0xFFDCFCE7)),
    (time: '12pm', color: const Color(0xFFF3E8FF)),
    (time: '2pm', color: const Color(0xFFFEF08A)),
  ];

  static final _hours = ['8am', '9am', '10am', '11am', '12pm', '1pm', '2pm', '3pm'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
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
                      decoration: BoxDecoration(color: const Color(0xFF16161E), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                      child: const Icon(Icons.notifications_outlined, color: Colors.white70, size: 22),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Schedule', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                  const SizedBox(height: 14),

                  // Students header card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [const BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        ..._students.reversed.map((s) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              CircleAvatar(radius: 22, backgroundColor: const Color(0xFFF0F0F5),
                                  child: Icon(Icons.person_outline, color: Colors.grey[500], size: 24)),
                              const SizedBox(height: 4),
                              Text(s.name, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
                              Text(s.location, style: GoogleFonts.inter(fontSize: 8, color: const Color(0xFF6B7280))),
                            ],
                          ),
                        )),
                        const Spacer(),
                        RotatedBox(
                          quarterTurns: 1,
                          child: Text('Students', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Time grid
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                        boxShadow: [const BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))]),
                    child: Column(
                      children: List.generate(_hours.length, (i) {
                        final slotIndex = _slots.indexWhere((s) => s.time == _hours[i]);
                        return Row(
                          children: [
                            Container(
                              width: 50,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              child: Center(
                                child: Text(_hours[i], style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF))),
                              ),
                            ),
                            const VerticalDivider(width: 1),
                            Expanded(
                              child: slotIndex != -1
                                  ? Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: _slots[slotIndex].color,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(_slots[slotIndex].time, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF374151))),
                                    )
                                  : const SizedBox(height: 52),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const TeacherBottomNavBar(currentTab: TeacherNavTab.schedules),
    );
  }
}
