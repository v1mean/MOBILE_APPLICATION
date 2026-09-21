import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showUploadCourseModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _UploadCourseModal(),
  );
}

class _UploadCourseModal extends StatefulWidget {
  const _UploadCourseModal();

  @override
  State<_UploadCourseModal> createState() => _UploadCourseModalState();
}

class _UploadCourseModalState extends State<_UploadCourseModal> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.97,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F6FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Teacher header inside modal
              Container(
                color: const Color(0xFF0A0A12),
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFF7B3FC8),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/jessica_avatar.png',
                          width: 44, height: 44, fit: BoxFit.cover,
                          errorBuilder: (ctx, e, st) => const Icon(Icons.person, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jessica Carl', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('Lecturer', style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
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

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Card container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [const BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: Row(
                              children: [
                                Text('Upload Course', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Container(
                                    width: 28, height: 28,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F0F5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF6B7280)),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Divider(height: 24, indent: 16, endIndent: 16),

                          // Video Details
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Video Details', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextField(
                                controller: _titleController,
                                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1A1A2E)),
                                decoration: InputDecoration(
                                  hintText: 'Title (required)',
                                  hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF)),
                                  contentPadding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextField(
                                controller: _descController,
                                maxLines: 4,
                                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1A1A2E)),
                                decoration: InputDecoration(
                                  hintText: 'Description (optional)\nDescribe your content here...',
                                  hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF)),
                                  contentPadding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Thumbnail
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Thumbnail', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                          ),
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

                          const SizedBox(height: 20),

                          // Upload Material
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Upload Your Material', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _UploadBox(icon: Icons.insert_drive_file_outlined, label: 'Upload Material', onTap: () {}),
                          ),

                          const SizedBox(height: 20),

                          // Upload Video
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Upload Your Video', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _UploadBox(icon: Icons.video_camera_back_outlined, label: 'Upload Video', onTap: () {}),
                          ),

                          const SizedBox(height: 24),

                          // Upload Course button
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Course uploaded successfully!')),
                                  );
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
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
          border: Border.all(color: const Color(0xFFD1D5DB), style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: const Color(0xFF6B7280)),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B7280), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
