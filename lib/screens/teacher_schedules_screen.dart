import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/user_avatar_header.dart';
import '../widgets/teacher_bottom_nav_bar.dart';
import '../main.dart';
import '../theme/app_colors.dart';

class TeacherSchedulesScreen extends StatefulWidget {
  const TeacherSchedulesScreen({super.key});

  @override
  State<TeacherSchedulesScreen> createState() => _TeacherSchedulesScreenState();
}

class _TeacherSchedulesScreenState extends State<TeacherSchedulesScreen> {
  String _userName = 'Teacher';
  String? _avatarUrl;

  List<Map<String, dynamic>> _scheduleBookings = [];
  bool _isLoading = true;
  StreamSubscription? _bookingSubscription;
  final AudioPlayer _audioPlayer = AudioPlayer();

  static final _hours = ['8am', '9am', '10am', '11am', '12pm', '1pm', '2pm', '3pm', '4pm', '5pm'];

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _initRealTimeListener();
  }

  @override
  void dispose() {
    _bookingSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    try {
      final session = JomnesDB.auth.currentSession;
      if (session == null) return;
      final data = await JomnesDB.from('profiles').select('full_name, avatar_url').eq('id', session.user.id).maybeSingle();
      if (data != null && mounted) {
        setState(() {
          _userName = data['full_name'] ?? 'Teacher';
          _avatarUrl = data['avatar_url'];
          if (_avatarUrl != null && _avatarUrl!.isEmpty) _avatarUrl = null;
        });
      }
    } catch (_) {}
  }

  Future<void> _initRealTimeListener() async {
    final session = JomnesDB.auth.currentSession;
    if (session == null) return;

    await _fetchScheduleView();

    int? previousCount;

    _bookingSubscription = JomnesDB
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('tutor_id', session.user.id)
        .listen((List<Map<String, dynamic>> data) async {
      
      final currentCount = data.length;
      
      if (previousCount != null && currentCount > previousCount!) {
        // New booking received!
        _playNotificationSound();
        await _fetchScheduleView(); 
      }
      previousCount = currentCount;
    });
  }

  Future<void> _fetchScheduleView() async {
    try {
      final session = JomnesDB.auth.currentSession;
      if (session == null) return;
      
      final data = await JomnesDB
          .from('teacher_schedule_view')
          .select()
          .eq('tutor_id', session.user.id);
          
      if (mounted) {
        setState(() {
          _scheduleBookings = List<Map<String, dynamic>>.from(data as List);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
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

  List<Map<String, dynamic>> get _uniqueStudents {
    final Map<String, Map<String, dynamic>> map = {};
    for (var b in _scheduleBookings) {
      final sId = b['student_id']?.toString() ?? '';
      if (sId.isNotEmpty) {
        map[sId] = {
          'name': b['student_name'] ?? 'Student',
          'avatar': b['student_avatar'],
          'location': b['student_location'] ?? 'Online',
        };
      }
    }
    return map.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final students = _uniqueStudents;

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
                      name: _userName,
                      role: 'Teacher',
                      avatarUrl: _avatarUrl,
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
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.black))
              : RefreshIndicator(
                  color: AppColors.galaxyPurple,
                  onRefresh: _fetchScheduleView,
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
                              final bookingsAtHour = _scheduleBookings.cast<Map<String, dynamic>>().where(
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
                                                    child: Text('${booking['student_name']} - Booked', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF166534)), overflow: TextOverflow.ellipsis),
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

