import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../services/api_service.dart';

class TeacherUploadCourseScreen extends StatefulWidget {
  const TeacherUploadCourseScreen({super.key});
  @override
  State<TeacherUploadCourseScreen> createState() => _TeacherUploadCourseScreenState();
}

class _TeacherUploadCourseScreenState extends State<TeacherUploadCourseScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  String _userName = 'Teacher';
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadTeacherProfile();
  }

  Future<void> _loadTeacherProfile() async {
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

  Widget _buildAvatar() {
    if (_tutorAvatarUrl != null && _tutorAvatarUrl!.trim().isNotEmpty) {
      if (_tutorAvatarUrl!.startsWith('http')) {
        return Image.network(
          _tutorAvatarUrl!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.person, color: Colors.white, size: 22),
        );
      } else {
        return Image.asset(
          _tutorAvatarUrl!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.person, color: Colors.white, size: 22),
        );
      }
    }
    return const Icon(Icons.person, color: Colors.white, size: 22);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          // ── Dark Top Header ──
          Container(
            color: const Color(0xFF0E0E14),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF16161E),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 16),
                      ),
                    ),
                    const SizedBox(width: 14),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF7B3FC8),
                      child: ClipOval(
                        child: _buildAvatar(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _tutorName,
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        Text(
                          _tutorTitle,
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF16161E),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Icon(Icons.notifications_outlined, color: Colors.white70, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Scrollable White Container Content ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(color: Color(0x08000000), blurRadius: 14, offset: Offset(0, 4)),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Upload Course',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 18),

                    // ── Course Category / Subject Selector (Requirement 1) ──
                    Text(
                      'Course Category / Subject',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _inputField(_titleController, 'Title (required)', maxLines: 1),
                    const SizedBox(height: 10),
                    _inputField(_descController, 'Description (optional)\nDescribe your content here...', maxLines: 5),

                    const SizedBox(height: 22),

                    // Thumbnail
                    _sectionLabel('Thumbnail'),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(child: _UploadBox(icon: Icons.add_photo_alternate_outlined, label: 'Upload New Thumbnail', onTap: () {})),
                          const SizedBox(width: 10),
                          Expanded(child: _UploadBox(icon: Icons.video_library_outlined, label: 'Select Thumbnail From Video', onTap: () {})),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Material
                    _sectionLabel('Upload Your Material'),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _UploadBox(icon: Icons.insert_drive_file_outlined, label: 'Upload Material', onTap: () {}),
                    ),

                    const SizedBox(height: 22),

                    // Video
                    _sectionLabel('Upload Your Video'),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _UploadBox(icon: Icons.video_camera_back_outlined, label: 'Upload Video', onTap: () {}),
                    ),

                    const SizedBox(height: 24),

                    // Upload button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Course uploaded successfully!')),
                            );
                            context.pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text('Upload Course', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                        ),
                      ),
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

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(text, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
      );

  Widget _inputField(TextEditingController ctrl, String hint, {int maxLines = 1}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: ctrl,
            maxLines: maxLines,
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1A1A2E)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF)),
              contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              border: InputBorder.none,
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description_outlined, size: 28, color: Color(0xFF6B7280)),
            const SizedBox(height: 8),
            Text(
              'Upload Material',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Device Video Upload Box ──
class _DeviceVideoUploadBox extends StatelessWidget {
  final String? videoName;
  final String? videoSize;
  final VoidCallback onTap;
  const _UploadBox({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (videoName != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF10B981), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.videocam_rounded, color: Colors.blue, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    videoName!,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (videoSize != null) ...[
                    const SizedBox(height: 2),
                    Text(videoSize!, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600])),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
              onPressed: onClear,
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: const Color(0xFF6B7280)),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B7280), height: 1.4)),
          ],
        ),
      ),
    );
  }
}
