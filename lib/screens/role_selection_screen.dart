import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

// Matches the DomeClipper used in login_screen.dart
class _DomeClipper extends CustomClipper<Path> {
  final double curveHeight;
  const _DomeClipper({this.curveHeight = 50});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - curveHeight);
    path.quadraticBezierTo(
      size.width / 2, size.height,
      size.width, size.height - curveHeight,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_DomeClipper oldClipper) => false;
}

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  List<Widget> _asterisks(double h) => [
        Positioned(left: 20, top: h * 0.42, child: Text('*', style: GoogleFonts.inter(color: Colors.white70, fontSize: 18))),
        Positioned(right: 28, top: h * 0.45, child: Text('*', style: GoogleFonts.inter(color: Colors.white70, fontSize: 16))),
        Positioned(left: 60, top: h * 0.5, child: Text('*', style: GoogleFonts.inter(color: Colors.white54, fontSize: 14))),
      ];

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // Hero image — same dome clip as login screen
          ClipPath(
            clipper: const _DomeClipper(curveHeight: 50),
            child: SizedBox(
              height: h * 0.44,
              width: double.infinity,
              child: Image.asset(
                'assets/images/hero_bg.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // Twinkle asterisks
          ..._asterisks(h),

          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white70, size: 16),
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                ),

                SizedBox(height: h * 0.3),

                // Bottom card area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          'Who are you?',
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                        ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),

                        const SizedBox(height: 6),

                        Text(
                          'Select your role to get the best experience for you.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFFB3B3C8),
                          ),
                        ).animate(delay: 150.ms).fadeIn(),

                        const SizedBox(height: 24),

                        // Student card
                        _RoleCard(
                          icon: '🎓',
                          title: 'Student',
                          subtitle: 'Find mentors, join courses and track your learning progress.',
                          accentColor: const Color(0xFF7B3FC8),
                          borderColor: const Color(0xFF7B3FC8),
                          bgColor: const Color(0xFF1A1230),
                          isSelected: _selectedRole == 'student',
                          onTap: () => setState(() => _selectedRole = 'student'),
                          delay: 200,
                        ),

                        const SizedBox(height: 14),

                        // Teacher card
                        _RoleCard(
                          icon: '🏫',
                          title: 'Teacher / Coach / Trainer',
                          subtitle: 'Share your skills, manage your students and grow your career.',
                          accentColor: const Color(0xFF2563EB),
                          borderColor: const Color(0xFF2563EB),
                          bgColor: const Color(0xFF0E1A2E),
                          isSelected: _selectedRole == 'teacher',
                          onTap: () => setState(() => _selectedRole = 'teacher'),
                          delay: 280,
                        ),

                        const SizedBox(height: 28),

                        // Continue button
                        AnimatedOpacity(
                          opacity: _selectedRole != null ? 1.0 : 0.4,
                          duration: const Duration(milliseconds: 250),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _selectedRole == null
                                  ? null
                                  : () {
                                      if (_selectedRole == 'student') {
                                        context.push('/login');
                                      } else {
                                        context.push('/teacher-login');
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.white,
                                foregroundColor: AppColors.darkBg,
                                disabledBackgroundColor: Colors.white24,
                                padding: const EdgeInsets.symmetric(vertical: 17),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Continue',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkBg,
                                ),
                              ),
                            ),
                          ),
                        ).animate(delay: 360.ms).fadeIn().slideY(begin: 0.2),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final Color borderColor;
  final Color bgColor;
  final bool isSelected;
  final VoidCallback onTap;
  final int delay;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.borderColor,
    required this.bgColor,
    required this.isSelected,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? bgColor : const Color(0xFF16161E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? borderColor : const Color(0xFF2A2A3A),
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withAlpha(60),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            // Icon box
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor.withAlpha(40)
                    : Colors.white.withAlpha(8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFFB3B3C8),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Radio dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? accentColor : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? accentColor : Colors.white30,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn().slideY(begin: 0.1);
  }
}
