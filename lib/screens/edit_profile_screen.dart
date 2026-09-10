import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../models/user_profile.dart';
import '../theme/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _roleController = TextEditingController();
  final _emailController = TextEditingController();

  String? _avatarUrl;
  bool _isLoading = false;
  bool _isFetching = true;
  UserProfile? _profile;

  // Preset avatar URLs for selection
  static const List<String> _avatarPresets = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&fit=crop&crop=faces',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&fit=crop&crop=faces',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&fit=crop&crop=faces',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&fit=crop&crop=faces',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&fit=crop&crop=faces',
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200&fit=crop&crop=faces',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final session = JomnesDB.auth.currentSession;
    final currentUser = JomnesDB.auth.currentUser;

    if (session == null) {
      if (mounted) setState(() => _isFetching = false);
      return;
    }

    _emailController.text = currentUser?.email ?? '';

    final metaName = currentUser?.userMetadata?['full_name'] ??
        currentUser?.userMetadata?['name'] ??
        currentUser?.email?.split('@').first ??
        'Student';
    final metaAvatar = currentUser?.userMetadata?['avatar_url'] ??
        currentUser?.userMetadata?['picture'];

    try {
      final data = await JomnesDB.from('Users')
          .select()
          .eq('user_id', session.user.id)
          .maybeSingle();

      if (mounted && data != null) {
        _profile = UserProfile.fromJson(data);
        _nameController.text = _profile!.name.isNotEmpty ? _profile!.name : metaName;
        _phoneController.text = _profile!.phone;
        _locationController.text = _profile!.location;
        _roleController.text = _profile!.role.isNotEmpty ? _profile!.role : 'Student';
        _avatarUrl = _profile!.profileImage.isNotEmpty
            ? _profile!.profileImage
            : (metaAvatar is String ? metaAvatar : null);
      } else if (mounted) {
        _nameController.text = metaName;
        _roleController.text = 'Student';
        if (metaAvatar is String) _avatarUrl = metaAvatar;
      }
    } catch (_) {
      if (mounted) {
        _nameController.text = metaName;
        _roleController.text = 'Student';
        if (metaAvatar is String) _avatarUrl = metaAvatar;
      }
    }

    if (mounted) setState(() => _isFetching = false);
  }

  Future<void> _saveProfile() async {
    final session = JomnesDB.auth.currentSession;
    if (session == null) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Full name cannot be empty'),
          backgroundColor: AppColors.liveRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final payload = {
        'user_id': session.user.id,
        'name': name,
        'phone': _phoneController.text.trim(),
        'location': _locationController.text.trim(),
        'role': _roleController.text.trim().isNotEmpty ? _roleController.text.trim() : 'Student',
        if (_avatarUrl != null && _avatarUrl!.isNotEmpty) 'profile_image': _avatarUrl,
        if (session.user.email != null) 'email': session.user.email,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await JomnesDB.from('Users').upsert(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text('Profile updated successfully!',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: AppColors.liveRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAvatarPicker() {
    final urlController = TextEditingController(text: _avatarUrl ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Choose Profile Photo',
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A))),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Preset Avatars',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B))),
              const SizedBox(height: 12),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _avatarPresets.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final url = _avatarPresets[i];
                    final isSelected = _avatarUrl == url;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _avatarUrl = url);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.accentBlue : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: AppColors.accentBlue.withAlpha(80),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(Icons.person),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text('Or Custom Image URL',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B))),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: urlController,
                  style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: 'https://example.com/avatar.jpg',
                    hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final trimmed = urlController.text.trim();
                    if (trimmed.isNotEmpty) {
                      setState(() => _avatarUrl = trimmed);
                    }
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Apply Avatar',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _nameController.text;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Column(
        children: [
          // Header Bar
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withAlpha(25)),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Edit Profile',
                          style: GoogleFonts.inter(
                              fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white)),
                      Text('Manage your personal info',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.white60)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Body Content
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: _isFetching
                  ? const Center(child: CircularProgressIndicator(color: AppColors.accentBlue))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                      child: Column(
                        children: [
                          // Hero Avatar Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(8),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: _showAvatarPicker,
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 104,
                                        height: 104,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            colors: [AppColors.accentBlue, Color(0xFF6366F1)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.accentBlue.withAlpha(50),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(3),
                                        child: ClipOval(
                                          child: Container(
                                            color: const Color(0xFFFFD5DC),
                                            child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                                ? Image.network(
                                                    _avatarUrl!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, _, _) => Center(
                                                      child: Text(
                                                        initial,
                                                        style: const TextStyle(
                                                            fontSize: 38,
                                                            fontWeight: FontWeight.w800,
                                                            color: Colors.black),
                                                      ),
                                                    ),
                                                  )
                                                : Center(
                                                    child: Text(
                                                      initial,
                                                      style: const TextStyle(
                                                          fontSize: 38,
                                                          fontWeight: FontWeight.w800,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 2,
                                        right: 2,
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: AppColors.accentBlue,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2.5),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withAlpha(30),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(Icons.camera_alt_rounded,
                                              color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _nameController.text.isNotEmpty ? _nameController.text : 'Your Name',
                                  style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _emailController.text.isNotEmpty
                                      ? _emailController.text
                                      : 'student@jomnes.com',
                                  style: GoogleFonts.inter(
                                      fontSize: 13, color: const Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: _showAvatarPicker,
                                  icon: const Icon(Icons.photo_library_outlined, size: 16),
                                  label: const Text('Change Photo'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.accentBlue,
                                    side: BorderSide(color: AppColors.accentBlue.withAlpha(100)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn().slideY(begin: 0.15),

                          const SizedBox(height: 20),

                          // Form Details Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(8),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Personal Details',
                                    style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0F172A))),
                                const SizedBox(height: 18),
                                _buildFormField(
                                  label: 'Full Name',
                                  controller: _nameController,
                                  hint: 'Enter full name',
                                  icon: Icons.person_rounded,
                                  iconColor: AppColors.accentBlue,
                                  onChanged: (_) => setState(() {}),
                                ),
                                const SizedBox(height: 16),
                                _buildReadOnlyEmail(),
                                const SizedBox(height: 16),
                                _buildFormField(
                                  label: 'Headline / Role',
                                  controller: _roleController,
                                  hint: 'e.g. Computer Science Student',
                                  icon: Icons.school_rounded,
                                  iconColor: const Color(0xFF8B5CF6),
                                ),
                                const SizedBox(height: 16),
                                _buildFormField(
                                  label: 'Phone Number',
                                  controller: _phoneController,
                                  hint: '+855 12 345 678',
                                  icon: Icons.phone_rounded,
                                  iconColor: const Color(0xFF10B981),
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 16),
                                _buildFormField(
                                  label: 'Location',
                                  controller: _locationController,
                                  hint: 'e.g. Phnom Penh, Cambodia',
                                  icon: Icons.location_on_rounded,
                                  iconColor: const Color(0xFFF59E0B),
                                ),
                              ],
                            ),
                          ).animate(delay: 80.ms).fadeIn().slideY(begin: 0.15),

                          const SizedBox(height: 24),

                          // Save Changes Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentBlue,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: AppColors.accentBlue.withAlpha(120),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5, color: Colors.white),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.check_rounded, size: 20),
                                        const SizedBox(width: 8),
                                        Text('Save Changes',
                                            style: GoogleFonts.inter(
                                                fontSize: 16, fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                            ),
                          ).animate(delay: 140.ms).fadeIn(),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569))),
        const SizedBox(height: 7),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: GoogleFonts.inter(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13.5),
              filled: true,
              fillColor: Colors.transparent,
              prefixIcon: Container(
                margin: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.accentBlue, width: 1.8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Email Address',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF475569))),
            Row(
              children: [
                const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF10B981)),
                const SizedBox(width: 4),
                Text('Verified',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF10B981))),
              ],
            ),
          ],
        ),
        const SizedBox(height: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.mail_rounded, color: Color(0xFF64748B), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _emailController.text.isNotEmpty
                      ? _emailController.text
                      : 'No email attached',
                  style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B)),
                ),
              ),
              const Icon(Icons.lock_rounded, size: 16, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ],
    );
  }
}
