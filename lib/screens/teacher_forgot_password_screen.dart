import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/auth_widgets.dart';

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

class TeacherForgotPasswordScreen extends StatefulWidget {
  const TeacherForgotPasswordScreen({super.key});
  @override
  State<TeacherForgotPasswordScreen> createState() => _TeacherForgotPasswordScreenState();
}

class _TeacherForgotPasswordScreenState extends State<TeacherForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  List<Widget> _asterisks(double h) => [
    Positioned(left: 20, top: h * 0.42, child: Text('*', style: GoogleFonts.inter(color: Colors.white70, fontSize: 18))),
    Positioned(right: 28, top: h * 0.46, child: Text('*', style: GoogleFonts.inter(color: Colors.white54, fontSize: 16))),
    Positioned(left: 18, bottom: 80, child: Text('*', style: GoogleFonts.inter(color: Colors.white54, fontSize: 18))),
    Positioned(right: 22, bottom: 40, child: Text('*', style: GoogleFonts.inter(color: Colors.white54, fontSize: 14))),
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
                SizedBox(height: h * 0.38),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SparkleIcon().animate(delay: 50.ms).fadeIn(),
                      const SizedBox(height: 12),
                      Text('Forgot Password', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.white))
                          .animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 6),
                      Text('Enter your email to receive password\nreset link',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textWhite70))
                          .animate(delay: 150.ms).fadeIn(),
                      const SizedBox(height: 28),
                      DarkTextField(
                        controller: _emailController,
                        hint: 'Email',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Reset link sent! Check your email.')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.darkBg,
                            padding: const EdgeInsets.symmetric(vertical: 17),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            elevation: 0,
                          ),
                          child: Text('Send Reset Link', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800)),
                        ),
                      ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text('Back to Login', style: GoogleFonts.inter(color: AppColors.textWhite70, fontSize: 14)),
                      ).animate(delay: 350.ms).fadeIn(),
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
