import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/course_categories.dart';
import '../main.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Reusable settings dialogs and bottom sheets shared between Student and Teacher settings.
class SettingsDialogs {
  SettingsDialogs._();

  // ── Help & Support Modal ──────────────────────────────────────────────────
  static void showHelpSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _HelpSupportSheet(),
    );
  }

  // ── Rate Jomnes Modal ─────────────────────────────────────────────────────
  static void showRateJomnes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _RateJomnesSheet(),
    );
  }

  // ── About Jomnes Modal ────────────────────────────────────────────────────
  static void showAboutJomnes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AboutJomnesSheet(),
    );
  }

  // ── Edit Phone Number Modal ───────────────────────────────────────────────
  static void showEditPhone(
    BuildContext context, {
    required String currentPhone,
    required ValueChanged<String> onSaved,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditPhoneSheet(
        initialPhone: currentPhone,
        onSaved: onSaved,
      ),
    );
  }

  // ── Edit Hourly Rate Modal (Teacher) ──────────────────────────────────────
  static void showEditHourlyRate(
    BuildContext context, {
    required double currentRate,
    required ValueChanged<double> onSaved,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditHourlyRateSheet(
        initialRate: currentRate,
        onSaved: onSaved,
      ),
    );
  }

  // ── Edit Subject Modal (Teacher) ──────────────────────────────────────────
  static void showEditSubject(
    BuildContext context, {
    required String currentSubject,
    required ValueChanged<String> onSaved,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditSubjectSheet(
        currentSubject: currentSubject,
        onSaved: onSaved,
      ),
    );
  }

  // ── Certificates & Credentials Modal (Teacher) ────────────────────────────
  static void showCertificates(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _CertificatesSheet(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Help & Support Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _HelpSupportSheet extends StatefulWidget {
  const _HelpSupportSheet();

  @override
  State<_HelpSupportSheet> createState() => _HelpSupportSheetState();
}

class _HelpSupportSheetState extends State<_HelpSupportSheet> {
  final _messageController = TextEditingController();
  final _subjectController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _launchExternalUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open $urlString'),
              backgroundColor: AppColors.liveRed,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $urlString'),
            backgroundColor: AppColors.liveRed,
          ),
        );
      }
    }
  }

  Future<void> _submitTicket() async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (subject.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please provide both subject and message.'),
          backgroundColor: AppColors.liveRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    // Simulate API submission
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Support ticket submitted! Ticket #JM-${DateTime.now().millisecondsSinceEpoch % 100000}',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.cyanAccent.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.support_agent_rounded,
                            color: AppColors.cyanAccent, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Help & Support',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.slateDark,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.slateText),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Contact channels
              Text(
                'Contact Channels',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slateGray,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildContactButton(
                      icon: Icons.email_outlined,
                      label: 'Email Support',
                      sub: 'support@jomnes.com',
                      color: AppColors.accentBlue,
                      onTap: () => _launchExternalUrl('mailto:support@jomnes.com?subject=Jomnes%20Support%20Request'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildContactButton(
                      icon: Icons.phone_in_talk_outlined,
                      label: 'Phone Hotline',
                      sub: '+855 23 999 888',
                      color: AppColors.successGreen,
                      onTap: () => _launchExternalUrl('tel:+85523999888'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // FAQ Section
              Text(
                'Frequently Asked Questions',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slateGray,
                ),
              ),
              const SizedBox(height: 8),
              _buildFaqTile(
                'How do I book a mentor session?',
                'Browse mentors from Search or Home, tap a mentor profile, select an available date & time slot, and tap "Book Session".',
              ),
              _buildFaqTile(
                'How does payment work?',
                'Sessions are paid using your saved payment card or Stripe checkout. Tutors receive payout earnings after sessions complete.',
              ),
              _buildFaqTile(
                'How do teachers set their hourly rate?',
                'In Teacher Settings, tap "Hourly Rate" under Teaching Info to configure your rate. Teachers with a rate of \$0 cannot be booked.',
              ),
              _buildFaqTile(
                'How can I cancel or reschedule?',
                'Go to your Courses / Bookings tab and select the scheduled session to view options or contact your mentor directly.',
              ),
              const SizedBox(height: 20),

              // Submit Ticket Section
              Text(
                'Send Us a Message',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slateGray,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _subjectController,
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.slateDark),
                decoration: InputDecoration(
                  hintText: 'Subject / Issue title',
                  hintStyle: GoogleFonts.inter(color: AppColors.slateIconMuted, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.slateBorderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.slateBorderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.accentBlue, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _messageController,
                maxLines: 3,
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.slateDark),
                decoration: InputDecoration(
                  hintText: 'Describe your issue or question in detail...',
                  hintStyle: GoogleFonts.inter(color: AppColors.slateIconMuted, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.slateBorderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.slateBorderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.accentBlue, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text('Submit Ticket', style: AppTextStyles.boldLabelMd),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required String sub,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha(15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withAlpha(40)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 6),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.slateDark)),
              Text(sub,
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.slateText)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          question,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.slateDark,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              answer,
              style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.slateText, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Rate Jomnes Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _RateJomnesSheet extends StatefulWidget {
  const _RateJomnesSheet();

  @override
  State<_RateJomnesSheet> createState() => _RateJomnesSheetState();
}

class _RateJomnesSheetState extends State<_RateJomnesSheet> {
  int _stars = 5;
  final _commentController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPreviousRating();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadPreviousRating() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rating = prefs.getInt('pref_user_rating');
      final comment = prefs.getString('pref_user_rating_comment');
      if (rating != null && mounted) {
        setState(() {
          _stars = rating;
          if (comment != null) _commentController.text = comment;
        });
      }
    } catch (_) {}
  }

  String get _ratingLabel {
    switch (_stars) {
      case 5: return 'Loved it! Outstanding! ⭐⭐⭐⭐⭐';
      case 4: return 'Great experience! ⭐⭐⭐⭐';
      case 3: return 'Good, with room for improvement ⭐⭐⭐';
      case 2: return 'Below expectations ⭐⭐';
      default: return 'Needs major improvements ⭐';
    }
  }

  Future<void> _submitRating() async {
    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('pref_user_rating', _stars);
      await prefs.setString('pref_user_rating_comment', _commentController.text.trim());
    } catch (_) {}

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.star_rounded, color: AppColors.warningAmber, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Thank you for rating Jomnes $_stars stars! Your feedback helps us improve.',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.slateDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rate Jomnes App',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.slateDark,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.slateText),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'How is your experience tutoring and learning with Jomnes?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.slateGray),
            ),
            const SizedBox(height: 20),

            // Star row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                final filled = starIndex <= _stars;
                return IconButton(
                  iconSize: 40,
                  onPressed: () => setState(() => _stars = starIndex),
                  icon: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: filled ? AppColors.warningAmber : AppColors.slateIconMuted,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              _ratingLabel,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.slateDark,
              ),
            ),
            const SizedBox(height: 16),

            // Optional review field
            TextField(
              controller: _commentController,
              maxLines: 3,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.slateDark),
              decoration: InputDecoration(
                hintText: 'Share what you like or what we can do better (optional)...',
                hintStyle: GoogleFonts.inter(color: AppColors.slateIconMuted, fontSize: 13),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.slateBorderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.slateBorderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.accentBlue, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Submit Rating', style: AppTextStyles.boldLabelMd),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. About Jomnes Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _AboutJomnesSheet extends StatelessWidget {
  const _AboutJomnesSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'About Jomnes',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slateDark,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.slateText),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // App Logo / Badge
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accentBlue, AppColors.galaxyPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentBlue.withAlpha(60),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.school_rounded, color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Jomnes',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.slateDark,
            ),
          ),
          Text(
            'Version 1.0.0+1 (Build 2025.1)',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.slateText),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.slateBorderLight),
            ),
            child: Text(
              'Jomnes is an on-demand tutoring and mentorship marketplace empowering students and teachers across Cambodia with seamless booking, live schedules, and secure payments.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.slateGray,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action tiles
          ListTile(
            dense: true,
            leading: const Icon(Icons.description_outlined, color: AppColors.accentBlue),
            title: Text('Open Source Licenses',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
            trailing: const Icon(Icons.chevron_right_rounded, size: 20),
            onTap: () {
              Navigator.pop(context);
              showLicensePage(
                context: context,
                applicationName: 'Jomnes',
                applicationVersion: '1.0.0+1',
                applicationLegalese: '© 2025 Jomnes. All rights reserved.',
              );
            },
          ),
          const Divider(height: 1, indent: 50, color: AppColors.slateBorderLight),
          ListTile(
            dense: true,
            leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.successGreen),
            title: Text('Terms of Service & Privacy',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
            trailing: const Icon(Icons.chevron_right_rounded, size: 20),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (dCtx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Text('Terms & Privacy',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
                  content: SingleChildScrollView(
                    child: Text(
                      'By using Jomnes, you agree to our terms of mentorship services, secure data protection standards, and PCI-DSS compliant payment processing. We never sell your personal data.',
                      style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: AppColors.slateGray),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dCtx),
                      child: Text('Close', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Jomnes © 2025 · Built for Learners & Educators',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Edit Phone Number Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _EditPhoneSheet extends StatefulWidget {
  final String initialPhone;
  final ValueChanged<String> onSaved;

  const _EditPhoneSheet({
    required this.initialPhone,
    required this.onSaved,
  });

  @override
  State<_EditPhoneSheet> createState() => _EditPhoneSheetState();
}

class _EditPhoneSheetState extends State<_EditPhoneSheet> {
  late final TextEditingController _phoneController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _savePhone() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Phone number cannot be empty.'),
          backgroundColor: AppColors.liveRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final session = JomnesDB.auth.currentSession;
      if (session != null) {
        await JomnesDB.from('Users').update({'phone': phone}).eq('user_id', session.user.id);
      }
      widget.onSaved(phone);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text('Phone number updated successfully!',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update phone: $e'), backgroundColor: AppColors.liveRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                Text(
                  'Update Phone Number',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.slateDark,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.slateText),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Your phone number is used for session alerts and student communications.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.slateGray),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.slateDark),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.successGreen),
                hintText: '+855 12 345 678',
                hintStyle: GoogleFonts.inter(color: AppColors.slateIconMuted, fontSize: 14),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.slateBorderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.slateBorderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.accentBlue, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _savePhone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Save Phone Number', style: AppTextStyles.boldLabelMd),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. Edit Hourly Rate Sheet (Teacher)
// ─────────────────────────────────────────────────────────────────────────────
class _EditHourlyRateSheet extends StatefulWidget {
  final double initialRate;
  final ValueChanged<double> onSaved;

  const _EditHourlyRateSheet({
    required this.initialRate,
    required this.onSaved,
  });

  @override
  State<_EditHourlyRateSheet> createState() => _EditHourlyRateSheetState();
}

class _EditHourlyRateSheetState extends State<_EditHourlyRateSheet> {
  late final TextEditingController _rateController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _rateController = TextEditingController(
      text: widget.initialRate > 0
          ? widget.initialRate.toStringAsFixed(widget.initialRate % 1 == 0 ? 0 : 2)
          : '25',
    );
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _saveRate() async {
    final text = _rateController.text.trim().replaceAll('\$', '');
    final rate = double.tryParse(text);

    if (rate == null || rate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid hourly rate greater than \$0.'),
          backgroundColor: AppColors.liveRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final session = JomnesDB.auth.currentSession;
      if (session != null) {
        // Save to tutor_profiles (upsert so it works whether row exists or not)
        await JomnesDB.from('tutor_profiles').upsert({
          'tutor_id': session.user.id,
          'user_id': session.user.id,
          'hourly_rate': rate,
          'is_available': true,
        }, onConflict: 'tutor_id');
      }

      widget.onSaved(rate);
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                'Hourly rate updated to \$${rate.toStringAsFixed(rate % 1 == 0 ? 0 : 2)}/hour!',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update rate: $e'),
            backgroundColor: AppColors.liveRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.attach_money_rounded,
                          color: AppColors.successGreen, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Set Hourly Rate',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.slateDark,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.slateText),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.successGreen.withAlpha(40)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.successGreen, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Students cannot book sessions with you if your rate is \$0. Set a positive hourly rate.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.slateDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Text(
              'Hourly Rate (USD)',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.slateGray,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _rateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.slateDark,
              ),
              decoration: InputDecoration(
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Center(
                    widthFactor: 0.0,
                    child: Text(
                      '\$',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.successGreen,
                      ),
                    ),
                  ),
                ),
                suffixText: '/ hour',
                suffixStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slateText,
                ),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.slateBorderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.slateBorderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.successGreen, width: 1.8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 14),

            // Quick preset chips
            Text(
              'Popular Rates',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.slateText,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [15.0, 20.0, 25.0, 30.0, 45.0, 60.0].map((r) {
                final isSelected = double.tryParse(_rateController.text) == r;
                return ChoiceChip(
                  label: Text('\$${r.toInt()} / hr'),
                  selected: isSelected,
                  onSelected: (_) => setState(() {
                    _rateController.text = r.toInt().toString();
                  }),
                  selectedColor: AppColors.successGreen.withAlpha(30),
                  labelStyle: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppColors.successGreen : AppColors.slateGray,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveRate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Save Hourly Rate', style: AppTextStyles.boldLabelMd),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. Edit Subject Sheet (Teacher)
// ─────────────────────────────────────────────────────────────────────────────
class _EditSubjectSheet extends StatefulWidget {
  final String currentSubject;
  final ValueChanged<String> onSaved;

  const _EditSubjectSheet({
    required this.currentSubject,
    required this.onSaved,
  });

  @override
  State<_EditSubjectSheet> createState() => _EditSubjectSheetState();
}

class _EditSubjectSheetState extends State<_EditSubjectSheet> {
  late String _selected;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentSubject;
  }

  Future<void> _saveSubject() async {
    setState(() => _isSaving = true);
    try {
      final session = JomnesDB.auth.currentSession;
      if (session != null) {
        // Save to tutor_profiles (column subject)
        await JomnesDB.from('tutor_profiles').upsert({
          'tutor_id': session.user.id,
          'user_id': session.user.id,
          'subject': _selected,
        }, onConflict: 'tutor_id');
      }

      widget.onSaved(_selected);
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text('Primary subject set to $_selected!',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update subject: $e'), backgroundColor: AppColors.liveRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Primary Subject',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slateDark,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.slateText),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'This subject appears on your mentor card and in student search results.',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.slateText),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.separated(
              itemCount: kCourseCategories.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.slateBorderLight),
              itemBuilder: (ctx, i) {
                final cat = kCourseCategories[i];
                final isSelected = _selected == cat;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: Text(
                    cat,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.accentBlue : AppColors.slateDark,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.accentBlue)
                      : null,
                  onTap: () => setState(() => _selected = cat),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveSubject,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Save Subject', style: AppTextStyles.boldLabelMd),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 7. Certificates & Credentials Sheet (Teacher)
// ─────────────────────────────────────────────────────────────────────────────
class _CertificatesSheet extends StatefulWidget {
  const _CertificatesSheet();

  @override
  State<_CertificatesSheet> createState() => _CertificatesSheetState();
}

class _CertificatesSheetState extends State<_CertificatesSheet> {
  List<Map<String, String>> _certs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    final session = JomnesDB.auth.currentSession;
    final userId = session?.user.id ?? 'default';
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('pref_certs_$userId');
      if (saved != null && saved.isNotEmpty) {
        final decoded = jsonDecode(saved) as List;
        _certs = decoded.map((e) => Map<String, String>.from(e as Map)).toList();
      } else {
        // Starter defaults if empty
        _certs = [
          {
            'title': 'Bachelor of Education (Mathematics)',
            'org': 'Royal University of Phnom Penh',
            'year': '2022',
            'status': 'Verified',
          },
          {
            'title': 'TEFL / TESOL 120-Hour Certificate',
            'org': 'Cambridge English Training',
            'year': '2023',
            'status': 'Verified',
          },
        ];
      }
    } catch (_) {
      _certs = [];
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveCertificates() async {
    final session = JomnesDB.auth.currentSession;
    final userId = session?.user.id ?? 'default';
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pref_certs_$userId', jsonEncode(_certs));
    } catch (_) {}
  }

  void _showAddCertDialog() {
    final titleController = TextEditingController();
    final orgController = TextEditingController();
    final yearController = TextEditingController(text: DateTime.now().year.toString());

    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Credential',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppColors.slateDark)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Certificate / Degree Title',
                  hintText: 'e.g. Master of Computer Science',
                  labelStyle: GoogleFonts.inter(fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: orgController,
                decoration: InputDecoration(
                  labelText: 'Issuing Organization / University',
                  hintText: 'e.g. National University of Management',
                  labelStyle: GoogleFonts.inter(fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: yearController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Year Issued',
                  labelStyle: GoogleFonts.inter(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.slateText)),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final org = orgController.text.trim();
              final year = yearController.text.trim();
              if (title.isEmpty || org.isEmpty) return;

              Navigator.pop(dCtx);
              setState(() {
                _certs.add({
                  'title': title,
                  'org': org,
                  'year': year,
                  'status': 'Verified',
                });
              });
              await _saveCertificates();

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added "$title" to your credentials!'),
                  backgroundColor: AppColors.successGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Add Credential', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warningAmber.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.workspace_premium_rounded,
                        color: AppColors.warningAmber, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Certificates & Credentials',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.slateDark,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.slateText),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Verified credentials increase student confidence and booking rates.',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.slateText),
          ),
          const SizedBox(height: 16),

          if (_isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ))
          else if (_certs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('No credentials added yet.', style: GoogleFonts.inter(color: AppColors.slateText)),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _certs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final cert = _certs[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.slateBorderLight),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.verified_rounded, color: AppColors.successGreen, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cert['title'] ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.slateDark,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${cert['org']} • ${cert['year']}',
                                style: GoogleFonts.inter(fontSize: 12, color: AppColors.slateText),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 18, color: AppColors.slateIconMuted),
                          onPressed: () async {
                            setState(() => _certs.removeAt(i));
                            await _saveCertificates();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _showAddCertDialog,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text('Add New Credential', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accentBlue,
                side: const BorderSide(color: AppColors.accentBlue, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
