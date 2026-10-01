import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../widgets/user_avatar_header.dart';
import '../../widgets/teacher_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/teacher/teacher_schedules_view_model.dart';
import '../../theme/app_colors.dart';

class TeacherSchedulesScreen extends StatefulWidget {
  const TeacherSchedulesScreen({super.key});

  @override
  State<TeacherSchedulesScreen> createState() => _TeacherSchedulesScreenState();
}

class _TeacherSchedulesScreenState extends State<TeacherSchedulesScreen> {
  late final TeacherSchedulesViewModel _vm;
  final AudioPlayer _audioPlayer = AudioPlayer();

  static final _hours = ['8am', '9am', '10am', '11am', '12pm', '1pm', '2pm', '3pm', '4pm', '5pm'];

  @override
  void initState() {
    super.initState();
    _vm = context.read<TeacherSchedulesViewModel>();
    _vm.onNewBooking = _playNotificationSound;
  }

  @override
  void dispose() {
    _vm.onNewBooking = null;
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.play(UrlSource('https://actions.google.com/sounds/v1/alarms/beep_short.ogg'));
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  String _formatToHourStr(String? timeStr) {
    if (timeStr == null) return '';
    final lower = timeStr.toLowerCase().replaceAll(' ', '');
    if (lower.contains(':00')) {
       return lower.replaceAll(':00', '');
    }
    return lower;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<TeacherSchedulesViewModel>();
    final students = _vm.uniqueStudents;

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: Column(
        children: [
          Container(
            color: AppColors.darkBg,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                child: Row(
                  children: [
                    UserAvatarHeader(
                      name: _vm.userName,
                      role: 'Teacher',
                      avatarUrl: _vm.avatarUrl,
                    ),
                    const Spacer(),
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                      child: const Icon(Icons.notifications_outlined, color: Colors.white70, size: 22),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _vm.isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.black))
              : RefreshIndicator(
                  color: AppColors.galaxyPurple,
                  onRefresh: _vm.loadSchedule,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Schedule', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navyText)),
                        const SizedBox(height: 14),

                        // Students header card
                        if (students.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [const BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: students.map((s) => Padding(
                                        padding: const EdgeInsets.only(right: 18),
                                        child: Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 22, 
                                              backgroundColor: const Color(0xFFF0F0F5),
                                              backgroundImage: (s['avatar']?.toString().isNotEmpty ?? false) ? NetworkImage(s['avatar']) : null,
                                              child: (s['avatar']?.toString().isEmpty ?? true) ? Icon(Icons.person_outline, color: Colors.grey[500], size: 24) : null
                                            ),
                                            const SizedBox(height: 4),
                                            Text(s['name'].toString().split(' ').first, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.navyText)),
                                            Text(s['location'], style: GoogleFonts.inter(fontSize: 9, color: AppColors.textSecondary)),
                                          ],
                                        ),
                                      )).toList(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                RotatedBox(
                                  quarterTurns: 1,
                                  child: Text('Students', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navyText)),
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
                              final hourKey = _hours[i];
                              
                              // Find all bookings for this hour
                              final bookingsAtHour = _vm.scheduleBookings.cast<Map<String, dynamic>>().where(
                                (b) => _formatToHourStr(b['time_slot']) == hourKey, 
                              ).toList();

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 50,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    child: Center(
                                      child: Text(hourKey, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
                                    ),
                                  ),
                                  const VerticalDivider(width: 1),
                                  Expanded(
                                    child: bookingsAtHour.isNotEmpty
                                        ? Column(
                                            children: bookingsAtHour.map((booking) => Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: AppColors.successBgLight, // Theme color for booked slot
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 12,
                                                    backgroundColor: Colors.white,
                                                    backgroundImage: (booking['student_avatar']?.toString().isNotEmpty ?? false) ? NetworkImage(booking['student_avatar']) : null,
                                                    child: (booking['student_avatar']?.toString().isEmpty ?? true) ? const Icon(Icons.person, size: 14, color: Colors.grey) : null,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text('${booking['student_name']} (${booking['booking_date'] ?? ''}) - Booked', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF166534)), overflow: TextOverflow.ellipsis),
                                                  ),
                                                ],
                                              ),
                                            )).toList(),
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
          ),
        ],
      ),
      bottomNavigationBar: const TeacherBottomNavBar(currentTab: TeacherNavTab.schedules),
    );
  }
}

