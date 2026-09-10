import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../models/user_profile.dart';
import '../widgets/bottom_nav_bar.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final int _navIndex = 4;
  bool _notificationsEnabled = true;
  bool _emailUpdates = false;
  bool _darkMode = false;
  String _selectedLanguage = 'English';
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final session = JomnesDB.auth.currentSession;
    if (session == null) return;
    try {
      final data = await JomnesDB.from('Users')
          .select()
          .eq('user_id', session.user.id)
          .maybeSingle();
      if (mounted && data != null) {
        setState(() {
          _userProfile = UserProfile.fromJson(data);
        });
      }
    } catch (_) {}
  }

  String get _displayName {
    if (_userProfile?.name.isNotEmpty == true) return _userProfile!.name;
    final user = JomnesDB.auth.currentUser;
    return user?.userMetadata?['full_name'] ??
        user?.userMetadata?['name'] ??
        user?.email?.split('@').first ??
        'Student';
  }

  String get _displayEmail {
    if (_userProfile?.email.isNotEmpty == true) return _userProfile!.email;
    return JomnesDB.auth.currentUser?.email ?? '';
  }

  String get _displayRole {
    if (_userProfile?.role.isNotEmpty == true) return _userProfile!.role;
    return 'Student';
  }

  String? get _avatarUrl {
    if (_userProfile?.profileImage.isNotEmpty == true) return _userProfile!.profileImage;
    final user = JomnesDB.auth.currentUser;
    final dynamic pic = user?.userMetadata?['avatar_url'] ?? user?.userMetadata?['picture'];
    return pic is String && pic.isNotEmpty ? pic : null;
  }

  void _onNavTap(int i) {
    if (i == _navIndex) return;
    switch (i) {
      case 0: context.go('/home'); break;
      case 1: context.go('/search'); break;
      case 2: context.go('/courses'); break;
      case 3: context.go('/profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Column(
        children: [
          // Top bar
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              child: Builder(builder: (context) {
                final name = _displayName;
                final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
                final avatar = _avatarUrl;
                return Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: avatar != null
                            ? Image.network(
                                avatar,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => CircleAvatar(
                                  backgroundColor: const Color(0xFFFFD5DC),
                                  child: Text(initial,
                                      style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor: const Color(0xFFFFD5DC),
                                child: Text(initial,
                                    style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _displayRole,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ),
          // White card body
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.lightBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      // Page title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text('Settings',
                            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800))
                            .animate().fadeIn().slideY(begin: 0.2),
                      ),
                      const SizedBox(height: 20),

                      // ── Profile Card ──
                      _buildProfileCard(context),
                      const SizedBox(height: 20),

                      // ── Account ──
                      _buildSectionHeader('Account'),
                      _buildSettingsCard(
                        delay: 100,
                        items: [
                          _SettingsTile(
                            icon: Icons.person_outline_rounded,
                            iconColor: AppColors.accentBlue,
                            title: 'Edit Profile',
                            onTap: () async {
                              await context.push('/edit-profile');
                              _fetchUserProfile();
                            },
                          ),
                          _SettingsTile(
                            icon: Icons.lock_outline_rounded,
                            iconColor: const Color(0xFF8B5CF6),
                            title: 'Change Password',
                            onTap: () => context.push('/change-password'),
                          ),
                          _SettingsTile(
                            icon: Icons.shield_outlined,
                            iconColor: const Color(0xFF10B981),
                            title: 'Privacy & Security',
                            onTap: () => context.push('/privacy-security'),
                          ),
                          _SettingsTile(
                            icon: Icons.payment_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            title: 'Payment Methods',
                            onTap: () => context.push('/payment-methods'),
                            isLast: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Preferences ──
                      _buildSectionHeader('Preferences'),
                      _buildSettingsCard(
                        delay: 200,
                        items: [
                          _SettingsTile(
                            icon: Icons.notifications_outlined,
                            iconColor: const Color(0xFFEF4444),
                            title: 'Push Notifications',
                            trailing: Switch.adaptive(
                              value: _notificationsEnabled,
                              onChanged: (v) => setState(() => _notificationsEnabled = v),
                              activeTrackColor: AppColors.accentBlue,
                            ),
                          ),
                          _SettingsTile(
                            icon: Icons.mail_outline_rounded,
                            iconColor: const Color(0xFF3B82F6),
                            title: 'Email Updates',
                            trailing: Switch.adaptive(
                              value: _emailUpdates,
                              onChanged: (v) => setState(() => _emailUpdates = v),
                              activeTrackColor: AppColors.accentBlue,
                            ),
                          ),
                          _SettingsTile(
                            icon: Icons.dark_mode_outlined,
                            iconColor: const Color(0xFF6366F1),
                            title: 'Dark Mode',
                            trailing: Switch.adaptive(
                              value: _darkMode,
                              onChanged: (v) => setState(() => _darkMode = v),
                              activeTrackColor: AppColors.accentBlue,
                            ),
                          ),
                          _SettingsTile(
                            icon: Icons.language_rounded,
                            iconColor: const Color(0xFF14B8A6),
                            title: 'Language',
                            subtitle: _selectedLanguage,
                            onTap: () => _showLanguagePicker(),
                            isLast: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Support ──
                      _buildSectionHeader('Support'),
                      _buildSettingsCard(
                        delay: 300,
                        items: [
                          _SettingsTile(
                            icon: Icons.help_outline_rounded,
                            iconColor: const Color(0xFF0EA5E9),
                            title: 'Help & Support',
                            onTap: () {},
                          ),
                          _SettingsTile(
                            icon: Icons.star_outline_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            title: 'Rate Jomnes',
                            onTap: () {},
                          ),
                          _SettingsTile(
                            icon: Icons.info_outline_rounded,
                            iconColor: AppColors.textSecondary,
                            title: 'About',
                            subtitle: 'Version 1.0.0',
                            onTap: () {},
                            isLast: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Danger Zone ──
                      _buildSectionHeader('Account Actions'),
                      _buildSettingsCard(
                        delay: 400,
                        items: [
                          _SettingsTile(
                            icon: Icons.logout_rounded,
                            iconColor: AppColors.liveRed,
                            title: 'Log Out',
                            titleColor: AppColors.liveRed,
                            onTap: () => _showLogoutDialog(context),
                          ),
                          _SettingsTile(
                            icon: Icons.delete_outline_rounded,
                            iconColor: AppColors.liveRed,
                            title: 'Delete Account',
                            titleColor: AppColors.liveRed,
                            onTap: () => _showDeleteDialog(context),
                            isLast: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Footer
                      Center(
                        child: Text(
                          'Jomnes © 2025 · All rights reserved',
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                        ).animate(delay: 500.ms).fadeIn(),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _navIndex, onTap: _onNavTap),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final name = _displayName;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final avatar = _avatarUrl;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.accentBlue, Color(0xFF6366F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentBlue.withAlpha(80),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              await context.push('/edit-profile');
              _fetchUserProfile();
            },
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  ClipOval(
                    child: Container(
                      width: 60, height: 60,
                      color: Colors.white24,
                      child: avatar != null
                          ? Image.network(
                              avatar,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => CircleAvatar(
                                backgroundColor: const Color(0xFFFFD5DC),
                                child: Text(initial,
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black)),
                              ),
                            )
                          : CircleAvatar(
                              backgroundColor: const Color(0xFFFFD5DC),
                              child: Text(initial,
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black)),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                        Text(_displayEmail,
                            style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_displayRole,
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().fadeIn().slideY(begin: 0.2),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> items, int delay = 0}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: Column(children: items),
        ),
      ).animate(delay: delay.ms).fadeIn().slideY(begin: 0.1),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Language',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            ...['English', 'Khmer (ខ្មែរ)', 'Chinese (中文)', 'French', 'Japanese'].map(
              (lang) => ListTile(
                title: Text(lang, style: GoogleFonts.inter(fontSize: 15)),
                trailing: _selectedLanguage == lang
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.accentBlue)
                    : null,
                onTap: () {
                  setState(() => _selectedLanguage = lang);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Log Out', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: Text('Are you sure you want to log out?',
            style: GoogleFonts.inter(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await AuthService().signOut();
              } catch (_) {}
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.liveRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Log Out', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Account', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: Text(
          'This action is permanent and cannot be undone. All your data will be lost.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.liveRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Delete', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isLast;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.trailing,
    this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            mouseCursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
            borderRadius: BorderRadius.circular(isLast ? 0 : 0).copyWith(
              bottomLeft: isLast ? const Radius.circular(20) : Radius.zero,
              bottomRight: isLast ? const Radius.circular(20) : Radius.zero,
              topLeft: Radius.zero,
              topRight: Radius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
              children: [
                // Icon container
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                // Title & subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: titleColor ?? AppColors.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!,
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ],
                  ),
                ),
                // Trailing widget or chevron
                trailing ??
                    (onTap != null
                        ? const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textMuted, size: 20)
                        : const SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
      if (!isLast)
          const Divider(height: 1, indent: 68, endIndent: 16, color: AppColors.border),
      ],
    );
  }
}