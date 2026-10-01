import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/galaxy_background.dart';
import '../../widgets/auth_widgets.dart';
import '../../theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth/forgot_password_view_model.dart';
import '../../theme/app_text_styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    final result = await context.read<ForgotPasswordViewModel>().requestReset(
      email,
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message ?? '')),
    );
    if (result.success) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = context.watch<ForgotPasswordViewModel>().isBusy;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          ClipPath(
            clipper: const DomeClipper(curveHeight: 50),
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
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: h * 0.38),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      Text('Forgot Password',
                          style: AppTextStyles.h1)
                          .animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 8),
                      Text('Enter your email to receive a password reset link.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.authCaptionWhite70)
                          .animate(delay: 150.ms).fadeIn(),
                      const SizedBox(height: 28),
                      DarkTextField(
                        controller: _emailController,
                        hint: 'Email', icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress)
                          .animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isBusy ? null : _handleReset,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white, foregroundColor: AppColors.darkBg,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            elevation: 0,
                          ),
                          child: isBusy
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text('Send Reset Link', style: AppTextStyles.primaryButton),
                        ),
                      ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text('Back to Log In', style: GoogleFonts.inter(color: AppColors.textWhite70, fontSize: 13)),
                      ).animate(delay: 300.ms).fadeIn(),
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

