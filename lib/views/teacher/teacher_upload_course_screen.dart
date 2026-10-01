import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../constants/course_categories.dart';
import '../../viewmodels/teacher/teacher_upload_course_view_model.dart';
import '../../widgets/user_avatar_header.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class TeacherUploadCourseScreen extends StatefulWidget {
  const TeacherUploadCourseScreen({super.key});
  @override
  State<TeacherUploadCourseScreen> createState() => _TeacherUploadCourseScreenState();
}

class _TeacherUploadCourseScreenState extends State<TeacherUploadCourseScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  late final TeacherUploadCourseViewModel _vm;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _vm = context.read<TeacherUploadCourseViewModel>();
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
      _vm.setThumbnail(image.path);
    }
  }

  Future<void> _pickMaterial() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _vm.setMaterial(image.path);
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      _vm.setVideo(video.path);
    }
  }

  Future<void> _uploadCourse() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a course title.')),
      );
      return;
    }

    final error = await _vm.upload(
      title: title,
      description: _descController.text.trim(),
    );
    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 "$title" uploaded to ${_vm.selectedCategory} & Featured Courses!'),
        backgroundColor: AppColors.successGreen,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<TeacherUploadCourseViewModel>();
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Column(
        children: [
          // Header
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  UserAvatarHeader(
                    name: _vm.userName,
                    role: 'Lecturer',
                    avatarUrl: _vm.avatarUrl,
                  ),
                  const Spacer(),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Icon(Icons.notifications_outlined, color: Colors.white70, size: 20),
                  ),
                ],
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
                  boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                      child: Text('Upload Course', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.navyText)),
                    ),

                    const Divider(height: 24, indent: 16, endIndent: 16),

                    // ── Course Category / Subject Selector (Requirement 1) ──
                    _sectionLabel('Course Category / Subject'),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF2A2A3E)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _vm.selectedCategory,
                            isExpanded: true,
                            dropdownColor: AppColors.darkCard,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                            items: _vm.categories.map((c) {
                              final theme = getCategoryTheme(c);
                              return DropdownMenuItem<String>(
                                value: c,
                                child: Row(
                                  children: [
                                    Icon(theme.icon, color: Colors.white70, size: 18),
                                    const SizedBox(width: 10),
                                    Text(c),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                _vm.selectCategory(val);
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

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
                      child: _UploadBox(
                        icon: Icons.add_photo_alternate_outlined, 
                        label: _vm.hasThumbnail ? 'Thumbnail Selected' : 'Upload New Thumbnail',
                        isSelected: _vm.hasThumbnail,
                        onTap: _pickThumbnail,
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
                        label: _vm.hasMaterial ? 'Material Selected' : 'Upload Material', 
                        isSelected: _vm.hasMaterial,
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
                        label: _vm.hasVideo ? 'Video Selected' : 'Upload Video', 
                        isSelected: _vm.hasVideo,
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
                          onPressed: _vm.isBusy ? null : _uploadCourse,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _vm.isBusy 
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
        child: Text(text, style: AppTextStyles.cardLabelBold),
      );

  Widget _inputField(TextEditingController ctrl, String hint, {int maxLines = 1}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkCard, // Dark background for input
            border: Border.all(color: const Color(0xFF2A2A3E)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: ctrl,
            maxLines: maxLines,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white), // White text when typing
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary), // Gray hint
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
          border: Border.all(color: isSelected ? AppColors.indigoDeep : AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.check_circle_rounded : icon, 
              color: isSelected ? AppColors.indigoDeep : AppColors.textMuted, 
              size: 28
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12, 
                fontWeight: FontWeight.w500, 
                color: isSelected ? AppColors.indigoDeep : AppColors.textSecondary
              ),
            ),
          ],
        ),
      ),
    );
  }
}
