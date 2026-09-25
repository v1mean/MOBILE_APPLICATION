import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../services/teacher_course_service.dart';
import '../services/device_file_picker.dart';
import '../constants/course_categories.dart';
import '../main.dart';

class TeacherUploadCourseScreen extends StatefulWidget {
  const TeacherUploadCourseScreen({super.key});
  @override
  State<TeacherUploadCourseScreen> createState() => _TeacherUploadCourseScreenState();
}

class _TeacherUploadCourseScreenState extends State<TeacherUploadCourseScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedCategory = kCourseCategories[0]; // 'Math'
  final List<String> _categories = kCourseCategories;

  Uint8List? _thumbnailBytes;
  String? _thumbnailName;
  String? _thumbnailSize;

  String? _selectedMaterialName;
  String? _selectedMaterialSize;

  String? _selectedVideoName;
  String? _selectedVideoSize;

  bool _isUploading = false;
  String _tutorName = 'Teacher';
  String _tutorTitle = 'Lecturer';
  String? _tutorAvatarUrl;
  String? _tutorId;

  @override
  void initState() {
    super.initState();
    _loadTeacherProfile();
  }

  Future<void> _loadTeacherProfile() async {
    try {
      final currentUser = JomnesDB.auth.currentUser;
      Map<String, dynamic>? userData;
      Map<String, dynamic>? tutorProfileData;

      if (currentUser != null) {
        _tutorId = currentUser.id;
        final res = await JomnesDB.from('Users')
            .select()
            .eq('user_id', currentUser.id)
            .maybeSingle();
        userData = res;
      }

      // If not logged in or user record not found, fallback to first available tutor from DB
      if (userData == null) {
        final tutors = await JomnesDB.from('Users')
            .select()
            .eq('role', 'tutor')
            .limit(1) as List<dynamic>;
        if (tutors.isNotEmpty) {
          userData = tutors.first as Map<String, dynamic>;
          _tutorId = userData['user_id']?.toString();
        }
      }

      if (_tutorId != null) {
        final profile = await JomnesDB.from('tutor_profiles')
            .select()
            .eq('user_id', _tutorId!)
            .maybeSingle();
        tutorProfileData = profile;
      }

      if (mounted) {
        setState(() {
          if (userData != null) {
            _tutorName = userData['name']?.toString() ?? 'Teacher';
            _tutorAvatarUrl = userData['profile_image']?.toString();
          }
          final subject = tutorProfileData?['subject']?.toString();
          if (subject != null && subject.isNotEmpty) {
            _tutorTitle = '$subject Mentor';
          }
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

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ── 1. Pick Thumbnail from PC / Device ──
  Future<void> _pickThumbnailFromDevice() async {
    try {
      final result = await DeviceFilePicker.pickImage();

      if (result != null) {
        setState(() {
          _thumbnailBytes = result.bytes;
          _thumbnailName = result.name;
          _thumbnailSize = _formatSize(result.size);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Thumbnail selected: ${result.name}'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // ── 2. Pick Material Document from PC / Device ──
  Future<void> _pickMaterialFromDevice() async {
    try {
      final result = await DeviceFilePicker.pickDocument();

      if (result != null) {
        setState(() {
          _selectedMaterialName = result.name;
          _selectedMaterialSize = _formatSize(result.size);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Material attached: ${result.name}'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // ── 3. Pick Video from PC / Device ──
  Future<void> _pickVideoFromDevice() async {
    try {
      final result = await DeviceFilePicker.pickVideo();

      if (result != null) {
        setState(() {
          _selectedVideoName = result.name;
          _selectedVideoSize = _formatSize(result.size);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Video attached: ${result.name}'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking video: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _handleUploadCourse() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a course title.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    final theme = getCategoryTheme(_selectedCategory);

    // Persist to Supabase database
    try {
      final currentUser = JomnesDB.auth.currentUser;
      String? tutorId = currentUser?.id ?? _tutorId;

      // Ensure valid tutor ID dynamically if still null
      if (tutorId == null) {
        final existingTutor = await JomnesDB.from('Users')
            .select('user_id')
            .eq('role', 'tutor')
            .limit(1)
            .maybeSingle();
        if (existingTutor != null && existingTutor['user_id'] != null) {
          tutorId = existingTutor['user_id'].toString();
        }
      }

      if (tutorId != null) {
        await JomnesDB.from('courses').insert({
          'tutor_id': tutorId,
          'title': title,
          'description': _descController.text.trim().isEmpty
              ? 'Practice exercise and course materials.'
              : _descController.text.trim(),
          'category': _selectedCategory,
          'rating': 5.0,
          'duration_hours': 10,
          'card_color': theme.cardColorKey,
          'is_live': false,
          'is_featured': true,
        });
      } else {
        throw Exception('No valid tutor account found to associate with course.');
      }
    } catch (e) {
    }

    if (!mounted) return;

    TeacherCourseService.instance.addCourse(
      title: title,
      description: _descController.text.trim(),
      category: _selectedCategory,
      thumbnailBytes: _thumbnailBytes,
      materialName: _selectedMaterialName,
      materialSize: _selectedMaterialSize,
      videoName: _selectedVideoName,
      videoDuration: _selectedVideoSize,
    );

    setState(() => _isUploading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 "$title" uploaded and saved successfully!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );

    context.pop();
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1F28),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1E1F28),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          items: _categories.map((c) {
                            return DropdownMenuItem<String>(
                              value: c,
                              child: Row(
                                children: [
                                  Icon(
                                    c == 'Chemistry'
                                        ? Icons.science_outlined
                                        : c == 'Mathematics'
                                            ? Icons.calculate_outlined
                                            : c == 'Physics'
                                                ? Icons.electric_bolt_outlined
                                                : c == 'Biology'
                                                    ? Icons.biotech_outlined
                                                    : c == 'English'
                                                        ? Icons.translate_rounded
                                                        : c == 'Computer Science'
                                                            ? Icons.computer_rounded
                                                            : Icons.school_outlined,
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(c),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedCategory = val);
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Video Details Section ──
                    Text(
                      'Video Details',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Title Input Field (Dark Box matching Figma)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1F28),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: _titleController,
                        style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Course title (e.g. Bac II Chemistry Prep)',
                          hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description Input Field (Dark Multiline Box matching Figma)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1F28),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: _descController,
                        maxLines: 5,
                        style: GoogleFonts.inter(fontSize: 14, color: Colors.white, height: 1.4),
                        decoration: InputDecoration(
                          hintText: 'Enter course description, syllabus, formulas and practice exercises...',
                          hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280)),
                          contentPadding: const EdgeInsets.all(16),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── Thumbnail Section (Requirement 2: Upload image directly from PC) ──
                    Text(
                      'Thumbnail',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _DeviceThumbnailUploadBox(
                      thumbnailBytes: _thumbnailBytes,
                      thumbnailName: _thumbnailName,
                      thumbnailSize: _thumbnailSize,
                      onTap: _pickThumbnailFromDevice,
                      onClear: () => setState(() {
                        _thumbnailBytes = null;
                        _thumbnailName = null;
                        _thumbnailSize = null;
                      }),
                    ),

                    const SizedBox(height: 22),

                    // ── Upload Your Material Section (Requirement 3: Upload from PC) ──
                    Text(
                      'Upload Your Material',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _DeviceMaterialUploadBox(
                      fileName: _selectedMaterialName,
                      fileSize: _selectedMaterialSize,
                      onTap: _pickMaterialFromDevice,
                      onClear: () => setState(() {
                        _selectedMaterialName = null;
                        _selectedMaterialSize = null;
                      }),
                    ),

                    const SizedBox(height: 22),

                    // ── Upload Your Video Section (Requirement 4: Upload video from PC) ──
                    Text(
                      'Upload Your Video',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _DeviceVideoUploadBox(
                      videoName: _selectedVideoName,
                      videoSize: _selectedVideoSize,
                      onTap: _pickVideoFromDevice,
                      onClear: () => setState(() {
                        _selectedVideoName = null;
                        _selectedVideoSize = null;
                      }),
                    ),

                    const SizedBox(height: 28),

                    // ── Upload Course CTA Button ──
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _handleUploadCourse,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                          disabledBackgroundColor: Colors.black45,
                        ),
                        child: _isUploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                'Upload Course',
                                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
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
}

// ── Device Thumbnail Upload Box ──
class _DeviceThumbnailUploadBox extends StatelessWidget {
  final Uint8List? thumbnailBytes;
  final String? thumbnailName;
  final String? thumbnailSize;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DeviceThumbnailUploadBox({
    this.thumbnailBytes,
    this.thumbnailName,
    this.thumbnailSize,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (thumbnailBytes != null) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF10B981), width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(thumbnailBytes!, fit: BoxFit.cover),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent, Colors.black87],
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 12,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    thumbnailName ?? 'Image attached',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                onPressed: onClear,
              ),
            ),
            Positioned(
              bottom: 10,
              right: 12,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.swap_horiz_rounded, size: 14, color: Colors.black),
                      const SizedBox(width: 4),
                      Text(
                        'Change Image',
                        style: GoogleFonts.inter(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w700),
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD1D5DB), width: 1.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_photo_alternate_outlined, size: 26, color: Color(0xFF4B5563)),
            ),
            const SizedBox(height: 10),
            Text(
              'Upload Thumbnail Image',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
            ),
            const SizedBox(height: 4),
            Text(
              'Click to browse image from your PC (JPG, PNG, WebP)',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Device Material Upload Box ──
class _DeviceMaterialUploadBox extends StatelessWidget {
  final String? fileName;
  final String? fileSize;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DeviceMaterialUploadBox({
    this.fileName,
    this.fileSize,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (fileName != null) {
      final isPdf = fileName!.toLowerCase().endsWith('.pdf');
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
                color: (isPdf ? Colors.red : Colors.orange).withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file_outlined,
                color: isPdf ? Colors.red : Colors.orange,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName!,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (fileSize != null) ...[
                    const SizedBox(height: 2),
                    Text(fileSize!, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600])),
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
  final VoidCallback onClear;

  const _DeviceVideoUploadBox({
    this.videoName,
    this.videoSize,
    required this.onTap,
    required this.onClear,
  });

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
            const Icon(Icons.videocam_outlined, size: 30, color: Color(0xFF6B7280)),
            const SizedBox(height: 8),
            Text(
              'Upload Video',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}

