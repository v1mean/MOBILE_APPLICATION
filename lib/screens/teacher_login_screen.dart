import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/social_auth_row.dart';
import '../theme/app_text_styles.dart';

class _DomeClipper extends CustomClipper<Path> {
  const _DomeClipper();
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(_DomeClipper old) => false;
}

class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});
  @override
  State<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  final bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  List<Widget> _asterisks(double h) => [
    Positioned(left: 20, top: h * 0.42, child: Text('*', style: GoogleFonts.inter(color: Colors.white70, fontSize: 18))),
    Positioned(right: 28, top: h * 0.46, child: Text('*', style: GoogleFonts.inter(color: Colors.white70, fontSize: 16))),
    Positioned(left: 60, top: h * 0.52, child: Text('*', style: GoogleFonts.inter(color: Colors.white54, fontSize: 14))),
    Positioned(left: 18, bottom: 60, child: Text('*', style: GoogleFonts.inter(color: Colors.white54, fontSize: 18))),
    Positioned(right: 22, bottom: 40, child: Text('*', style: GoogleFonts.inter(color: Colors.white54, fontSize: 16))),
  ];

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          ClipPath(
            clipper: const _DomeClipper(),
            child: SizedBox(
              height: h * 0.44,
              width: double.infinity,
              child: Image.asset('assets/images/hero_bg.png', fit: BoxFit.cover, alignment: Alignment.topCenter),
            ),
          ),
          ..._asterisks(h),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: h * 0.36),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SparkleIcon().animate(delay: 50.ms).fadeIn(),
                      const SizedBox(height: 12),
                      Text('Welcome Back', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.white))
                          .animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 6),
                      Text('Enter your detail below to log into\nyour account.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textWhite70))
                          .animate(delay: 150.ms).fadeIn(),
                      const SizedBox(height: 28),
                      DarkTextField(
                        controller: _phoneController,
                        hint: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 14),
                      DarkTextField(
                        controller: _passwordController,
                        hint: 'Password',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        suffix: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textSecondary, size: 20),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          SizedBox(
                            width: 20, height: 20,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (v) => setState(() => _rememberMe = v ?? false),
                              activeColor: AppColors.accentBlue,
                              side: const BorderSide(color: AppColors.darkBorder),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('Remember me', style: AppTextStyles.bodySmWhite70),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => context.push('/teacher-forgot-password'),
                            child: Text('Forgot password?', style: GoogleFonts.inter(color: AppColors.accentBlue, fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ).animate(delay: 300.ms).fadeIn(),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () => context.go('/teacher-home'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.darkBg,
                            padding: const EdgeInsets.symmetric(vertical: 17),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text('Log In', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800)),
                        ),
                      ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => context.push('/teacher-register'),
                        child: Text('Register Account', style: AppTextStyles.bodySmWhite70),
                      ).animate(delay: 380.ms).fadeIn(),
                      const SizedBox(height: 20),
                      SocialAuthRow(label: 'or Log In With', onGoogleTap: () {}, onFacebookTap: () {}).animate(delay: 400.ms).fadeIn(),
                      const SizedBox(height: 40),
                    ],
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


