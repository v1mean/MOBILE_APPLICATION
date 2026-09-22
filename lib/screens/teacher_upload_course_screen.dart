import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';

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
    _fetchProfile();
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
          // Dark header
          Container(
            color: const Color(0xFF0A0A12),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 38, height: 38,
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
                      backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                      child: _avatarUrl == null
                          ? const Icon(Icons.person, color: Colors.white, size: 22)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_userName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('Lecturer', style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      width: 38, height: 38,
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

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [const BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                      child: Text('Upload Course', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                    ),

                    const Divider(height: 24, indent: 16, endIndent: 16),

                    // Video Details
                    _sectionLabel('Video Details'),
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
          ),
        ),
      );
}

class _UploadBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _UploadBox({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
          mainAxisSize: MainAxisSize.min,
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
