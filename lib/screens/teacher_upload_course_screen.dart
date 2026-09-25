import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
  
  String? _thumbnailPath;
  String? _materialPath;
  String? _videoPath;
  
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final session = JomnesDB.auth.currentSession;
      if (session == null) return;
      final data = await JomnesDB.from('Users').select('name, profile_image').eq('user_id', session.user.id).maybeSingle();
      if (data != null && mounted) {
        setState(() {
          _userName = data['name'] ?? 'Teacher';
          _avatarUrl = data['profile_image'];
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

  Future<void> _pickThumbnail() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _thumbnailPath = image.path);
    }
  }

  Future<void> _pickMaterial() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _materialPath = image.path);
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() => _videoPath = video.path);
    }
  }

  Future<void> _uploadCourse() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    setState(() => _isUploading = true);

    final success = await ApiService.uploadCourse(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      thumbnailPath: _thumbnailPath,
      materialPath: _materialPath,
      videoPath: _videoPath,
    );

    if (!mounted) return;
    setState(() => _isUploading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course uploaded successfully!')));
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to upload course. Check your connection.')));
    }
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
                          Expanded(child: _UploadBox(
                            icon: Icons.add_photo_alternate_outlined, 
                            label: _thumbnailPath != null ? 'Thumbnail Selected' : 'Upload New Thumbnail',
                            isSelected: _thumbnailPath != null,
                            onTap: _pickThumbnail,
                          )),
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
                      child: _UploadBox(
                        icon: Icons.insert_drive_file_outlined, 
                        label: _materialPath != null ? 'Material Selected' : 'Upload Material', 
                        isSelected: _materialPath != null,
                        onTap: _pickMaterial,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Video
                    _sectionLabel('Upload Your Video'),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _UploadBox(
                        icon: Icons.video_camera_back_outlined, 
                        label: _videoPath != null ? 'Video Selected' : 'Upload Video', 
                        isSelected: _videoPath != null,
                        onTap: _pickVideo,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Upload button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isUploading ? null : _uploadCourse,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _isUploading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Upload Course', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
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
            color: const Color(0xFF16161E), // Dark background for input
            border: Border.all(color: const Color(0xFF2A2A3E)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: ctrl,
            maxLines: maxLines,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white), // White text when typing
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280)), // Gray hint
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
  final bool isSelected;
  const _UploadBox({required this.icon, required this.label, required this.onTap, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
          border: Border.all(color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.check_circle_rounded : icon, 
              color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF), 
              size: 28
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12, 
                fontWeight: FontWeight.w500, 
                color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF6B7280)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
