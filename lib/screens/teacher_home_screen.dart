import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../widgets/teacher_bottom_nav_bar.dart';
import '../services/teacher_course_service.dart';
import '../main.dart';

class _ScheduleItem {
  final String name;
  final String location;
  final String time;
  final Color color;
  _ScheduleItem(this.name, this.location, this.time, this.color);
}

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  String _userName = 'Teacher';
  String? _avatarUrl;

  static final _schedule = [
    _ScheduleItem('Socheatre', 'Chroy Chongva', '10am - 11am', const Color(0xFFF3E8FF)),
    _ScheduleItem('Srey Pich', 'Preak Leab', '8am - 9am', const Color(0xFFE0F2FE)),
    _ScheduleItem('Bros Sok', 'Orussey', '9am - 10am', const Color(0xFFDCFCE7)),
  ];

  List<_CourseItem> _courses = [];
  bool _isLoadingCourses = true;
  void _showCourseDetailModal(BuildContext context, TeacherCourse course) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (course.thumbnailBytes != null) ...[
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  image: DecorationImage(
                    image: MemoryImage(course.thumbnailBytes!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          course.category,
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF2563EB)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        course.title.replaceAll('\n', ' '),
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${course.rating}',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              course.description,
              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF4B5563), height: 1.4),
            ),
            const SizedBox(height: 16),
            if (course.materialName != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.red, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.materialName!,
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (course.materialSize != null)
                            Text(
                              course.materialSize!,
                              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600]),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.download_rounded, size: 18, color: Colors.black),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (course.videoName != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.play_circle_fill, color: Colors.blue, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.videoName!,
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (course.videoDuration != null)
                            Text(
                              course.videoDuration!,
                              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600]),
                            ),
                        ],
                      ),
                    ),
                    const Text('Watch', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.blue)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      TeacherCourseService.instance.removeCourse(course.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Course deleted.')),
                      );
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                    label: Text(
                      'Delete',
                      style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: Text('Close', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    try {
      final session = JomnesDB.auth.currentSession;
      if (session == null) return;
      final data = await JomnesDB.from('courses')
          .select()
          .eq('tutor_id', session.user.id)
          .order('created_at', ascending: false);
          
      if (mounted) {
        setState(() {
          _courses = (data as List).map((c) => _CourseItem(
            c['title'] ?? 'Course Title',
            c['description'] ?? 'No description',
            (c['rating'] as num?)?.toDouble() ?? 5.0,
            _formatTimeAgo(c['created_at']),
            _parseColor(c['card_color']),
          )).toList();
          _isLoadingCourses = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingCourses = false);
    }
  }

  String _formatTimeAgo(String? dateStr) {
    if (dateStr == null) return 'Just now';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return 'Just now';
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    if (diff.inHours > 0) return '${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
    return 'Just now';
  }

  Color _parseColor(String? colorStr) {
    switch (colorStr) {
      case 'pink': return const Color(0xFFF3D0FF);
      case 'blue': return const Color(0xFFE0F2FE);
      case 'green': return const Color(0xFFDCFCE7);
      case 'orange': return const Color(0xFFFFEDD5);
      case 'slate': return const Color(0xFFE2E8F0);
      case 'cyan': return const Color(0xFFCFFAFE);
      default: return const Color(0xFFF3D0FF);
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final session = JomnesDB.auth.currentSession;
      if (session == null) return;
      final uData = await JomnesDB.from('Users').select('name, profile_image').eq('user_id', session.user.id).maybeSingle();
      if (uData != null && mounted) {
        setState(() {
          _userName = uData['name'] ?? 'Teacher';
          _avatarUrl = uData['profile_image'];
          if (_avatarUrl != null && _avatarUrl!.isEmpty) _avatarUrl = null;
        });
        return;
      }
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          // ── Dark Top Header ──
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
                      backgroundImage: _avatarUrl != null && _avatarUrl!.startsWith('http')
                          ? NetworkImage(_avatarUrl!)
                          : null,
                      child: (_avatarUrl == null || !_avatarUrl!.startsWith('http'))
                          ? const Icon(Icons.person, color: Colors.white, size: 28)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_userName, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('Teacher', style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 40,
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

          // ── Scrollable Body ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today Schedule
                  Text(
                    'Today Schedule',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        ..._schedule.map((s) => _ScheduleRow(item: s)),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => context.go('/teacher-schedules'),
                              child: Text(
                                'See more',
                                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF2563EB), fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Latest Courses Section Header with "+ Add Course" (Requirement 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Latest Courses',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/teacher-upload'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Add Course',
                                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isLoadingCourses)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(color: Color(0xFF7B3FC8)),
                      ),
                    )
                  else if (_courses.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text('No courses uploaded yet.\nClick + to upload one!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(color: Colors.grey, fontSize: 14)),
                      ),
                    )
                  else
                    ..._courses.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _CourseCard(item: c),
                    )),

                  AnimatedBuilder(
                    animation: TeacherCourseService.instance,
                    builder: (context, _) {
                      final courses = TeacherCourseService.instance.courses;
                      return Column(
                        children: [
                          ...courses.map((c) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _CourseCard(
                                  item: c,
                                  onTap: () => _showCourseDetailModal(context, c),
                                ),
                              )),
                          // Option to create/add other course (Requirement 1)
                          GestureDetector(
                            onTap: () => context.push('/teacher-upload'),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFCBD5E1),
                                  style: BorderStyle.solid,
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF3F4F6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.add_rounded, size: 18, color: Colors.black),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Create or Add Another Course',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/teacher-upload');
          _fetchCourses();
        },
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 4,
        shape: const CircleBorder(),
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
  final TeacherCourse item;
  final VoidCallback onTap;
  const _CourseCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.thumbnailBytes != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  item.thumbnailBytes!,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.category.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(200),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.category,
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        item.title,
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.edit_outlined, size: 18, color: Colors.grey[700]),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.description,
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF4B5563)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${item.rating} rating',
                  style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF1A1A2E)),
                ),
                const Spacer(),
                Text(
                  item.timeAgo,
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
