import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/primary_auth_button.dart';
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

class TeacherRegisterScreen extends StatefulWidget {
  const TeacherRegisterScreen({super.key});
  @override
  State<TeacherRegisterScreen> createState() => _TeacherRegisterScreenState();
}

class _TeacherRegisterScreenState extends State<TeacherRegisterScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  List<Widget> _asterisks(double h) => [
    Positioned(left: 20, top: h * 0.42, child: Text('*', style: AppTextStyles.decorativeStarLg)),
    Positioned(right: 28, top: h * 0.5, child: Text('*', style: GoogleFonts.inter(color: Colors.white54, fontSize: 16))),
    Positioned(left: 18, bottom: 60, child: Text('*', style: GoogleFonts.inter(color: Colors.white54, fontSize: 18))),
    Positioned(right: 22, bottom: 40, child: Text('*', style: AppTextStyles.decorativeStarSm)),
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
                      Text('Welcome to Jomnes', style: AppTextStyles.h1)
                          .animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 6),
                      Text('Enter your detail below to register\nyour account.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.authCaptionWhite70)
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
                      DarkTextField(
                        controller: _confirmPasswordController,
                        hint: 'Confirm Password',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscureConfirm,
                        suffix: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textSecondary, size: 20),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 28),
                      PrimaryAuthButton(label: 'Register Account', onPressed: () => context.go('/teacher-home')).animate(delay: 350.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text('Back to Log In', style: AppTextStyles.bodySmWhite70),
                      ).animate(delay: 380.ms).fadeIn(),
                      const SizedBox(height: 20),
                      SocialAuthRow(label: 'Registered with', onGoogleTap: () {}, onFacebookTap: () {}).animate(delay: 400.ms).fadeIn(),
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


