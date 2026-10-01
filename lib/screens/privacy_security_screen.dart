import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _profilePublic = true;
  bool _showEmail = false;
  bool _showPhone = false;
  bool _activityStatus = true;

  bool _twoFactor = false;
  bool _loginAlerts = true;
  bool _biometricLock = false;

  bool _dataSharing = false;

  void _show2FaDialog(bool enable) {
    if (!enable) {
      setState(() => _twoFactor = false);
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Enable Two-Factor Auth',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppColors.slateDark)),
        content: Text(
          'A verification code will be sent to your registered email or phone number on every new login attempt.',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.slateGray),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _twoFactor = false);
            },
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.slateText)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _twoFactor = true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('2FA has been successfully activated.'),
                  backgroundColor: AppColors.successGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Enable', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showActiveSessions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Active Device Sessions',
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.slateDark)),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.slateText),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.laptop_chromebook_rounded, color: AppColors.accentBlue),
              ),
              title: Text('Google Chrome (Current)',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.slateDark)),
              subtitle: Text('Windows 11 • Phnom Penh, KH • Active now',
                  style: AppTextStyles.helperTextSm),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Active',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.successGreen)),
              ),
            ),
            const Divider(height: 20, color: AppColors.slateBgSoft),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.phone_android_rounded, color: AppColors.slateText),
              ),
              title: Text('Android Mobile App',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.slateDark)),
              subtitle: Text('Mobile Device • Last active 2 days ago',
                  style: AppTextStyles.helperTextSm),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cleaning_services_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text('App cache cleared (18.4 MB freed)',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete All Account Data?',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppColors.slateDark)),
        content: Text(
          'This action is irreversible. All course history, notes, and profile data will be permanently wiped.',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.slateGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.slateText)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Account data purge request submitted.'),
                  backgroundColor: AppColors.liveRed,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
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

  @override
  Widget build(BuildContext context) {
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
                      Text('Privacy & Security',
                          style: GoogleFonts.inter(
                              fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white)),
                      Text('Control data & authentication',
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
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Profile Visibility
                    _buildSectionHeader('Profile Visibility'),
                    _buildCard([
                      _buildToggleTile(
                        icon: Icons.public_rounded,
                        iconColor: AppColors.accentBlue,
                        title: 'Public Profile',
                        subtitle: 'Allow students and tutors to discover you',
                        value: _profilePublic,
                        onChanged: (v) => setState(() => _profilePublic = v),
                      ),
                      _buildDivider(),
                      _buildToggleTile(
                        icon: Icons.mail_outline_rounded,
                        iconColor: AppColors.violetAccent,
                        title: 'Show Email Address',
                        subtitle: 'Display your email on public profiles',
                        value: _showEmail,
                        onChanged: (v) => setState(() => _showEmail = v),
                      ),
                      _buildDivider(),
                      _buildToggleTile(
                        icon: Icons.phone_outlined,
                        iconColor: AppColors.successGreen,
                        title: 'Show Phone Number',
                        subtitle: 'Display phone number on profile view',
                        value: _showPhone,
                        onChanged: (v) => setState(() => _showPhone = v),
                      ),
                      _buildDivider(),
                      _buildToggleTile(
                        icon: Icons.circle_outlined,
                        iconColor: const Color(0xFF06B6D4),
                        title: 'Active Status',
                        subtitle: 'Show when you are active on Jomnes',
                        value: _activityStatus,
                        onChanged: (v) => setState(() => _activityStatus = v),
                        isLast: true,
                      ),
                    ]).animate().fadeIn().slideY(begin: 0.15),

                    const SizedBox(height: 22),

                    // Section 2: Account Security
                    _buildSectionHeader('Account Security'),
                    _buildCard([
                      _buildToggleTile(
                        icon: Icons.security_rounded,
                        iconColor: AppColors.liveRed,
                        title: 'Two-Factor Authentication',
                        subtitle: 'Extra verification step during login',
                        value: _twoFactor,
                        onChanged: _show2FaDialog,
                      ),
                      _buildDivider(),
                      _buildToggleTile(
                        icon: Icons.notifications_active_outlined,
                        iconColor: AppColors.warningAmber,
                        title: 'Login Alerts',
                        subtitle: 'Notify on unrecognized new sign-ins',
                        value: _loginAlerts,
                        onChanged: (v) => setState(() => _loginAlerts = v),
                      ),
                      _buildDivider(),
                      _buildToggleTile(
                        icon: Icons.fingerprint_rounded,
                        iconColor: AppColors.violetAccent,
                        title: 'Biometric / App Lock',
                        subtitle: 'Require biometric scan to open app',
                        value: _biometricLock,
                        onChanged: (v) => setState(() => _biometricLock = v),
                      ),
                      _buildDivider(),
                      _buildActionTile(
                        icon: Icons.devices_rounded,
                        iconColor: AppColors.accentBlue,
                        title: 'Active Sessions',
                        subtitle: 'View and manage devices logged in',
                        onTap: _showActiveSessions,
                        isLast: true,
                      ),
                    ]).animate(delay: 70.ms).fadeIn().slideY(begin: 0.15),

                    const SizedBox(height: 22),

                    // Section 3: Data & Privacy
                    _buildSectionHeader('Data & Storage'),
                    _buildCard([
                      _buildToggleTile(
                        icon: Icons.analytics_outlined,
                        iconColor: AppColors.tealAccent,
                        title: 'Usage Diagnostics',
                        subtitle: 'Share anonymous performance reports',
                        value: _dataSharing,
                        onChanged: (v) => setState(() => _dataSharing = v),
                      ),
                      _buildDivider(),
                      _buildActionTile(
                        icon: Icons.cleaning_services_outlined,
                        iconColor: AppColors.warningAmber,
                        title: 'Clear Cache Files',
                        subtitle: 'Free storage space by wiping temporary files',
                        onTap: _clearCache,
                      ),
                      _buildDivider(),
                      _buildActionTile(
                        icon: Icons.download_outlined,
                        iconColor: AppColors.accentBlue,
                        title: 'Download My Archive',
                        subtitle: 'Request full personal data export file',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Export archive will be sent to your email.'),
                              backgroundColor: AppColors.accentBlue,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildActionTile(
                        icon: Icons.delete_forever_outlined,
                        iconColor: AppColors.liveRed,
                        title: 'Purge Account Data',
                        subtitle: 'Permanently remove all data history',
                        onTap: _showDeleteDataDialog,
                        isLast: true,
                      ),
                    ]).animate(delay: 120.ms).fadeIn().slideY(begin: 0.15),

                    const SizedBox(height: 28),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 10),
                                  Text('Privacy preferences updated!',
                                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                ],
                              ),
                              backgroundColor: AppColors.successGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                          context.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentBlue,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: AppColors.accentBlue.withAlpha(120),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('Save Preferences',
                            style: AppTextStyles.boldLabelMd),
                      ),
                    ).animate(delay: 180.ms).fadeIn(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.slateText,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _buildDivider() => const Divider(height: 1, indent: 68, color: AppColors.slateBgSoft);

  Widget _buildToggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slateDark)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTextStyles.helperTextSm),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.accentBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slateDark)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: AppTextStyles.helperTextSm),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.slateIconMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
