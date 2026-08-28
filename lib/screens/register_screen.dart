import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../widgets/galaxy_background.dart';
import '../widgets/auth_widgets.dart';
import '../theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          ClipPath(
            clipper: const DomeClipper(curveHeight: 50),
            child: SizedBox(
              height: h * 0.40,
              child: GalaxyBackground(
                child: Stack(
                  children: [
                    Positioned(top: 50, left: 30, child: Text('📜', style: TextStyle(fontSize: 44))),
                    Positioned(top: 36, right: 30, child: Text('🔔', style: TextStyle(fontSize: 50))),
                    Positioned(bottom: 90, left: 20, child: Text('📅', style: TextStyle(fontSize: 44))),
                    Positioned(bottom: 80, right: 24, child: Text('🎬', style: TextStyle(fontSize: 44))),
                    const Center(child: Text('🦉', style: TextStyle(fontSize: 90))),
                  ],
                ),
              ),
            ),
          ),
          Positioned(left: 20, top: h * 0.40, child: Text('*', style: GoogleFonts.inter(color: AppColors.white.withAlpha(100), fontSize: 18))),
          Positioned(left: 310, top: h * 0.42, child: Text('*', style: GoogleFonts.inter(color: AppColors.white.withAlpha(100), fontSize: 18))),
          Positioned(left: 140, top: h * 0.57, child: Text('*', style: GoogleFonts.inter(color: AppColors.white.withAlpha(100), fontSize: 14))),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: h * 0.32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SparkleIcon().animate(delay: 100.ms).fadeIn(),
                      const SizedBox(height: 14),
                      Text('Welcome to Jomnes',
                          style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.white))
                          .animate(delay: 150.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 8),
                      Text('Enter your detail below to register\nyour account.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textWhite70))
                          .animate(delay: 200.ms).fadeIn(),
                      const SizedBox(height: 28),
                      DarkTextField(hint: 'Email', icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress)
                          .animate(delay: 250.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 14),
                      DarkTextField(
                        hint: 'Password', icon: Icons.lock_outline_rounded, obscureText: _obscurePassword,
                        suffix: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textSecondary, size: 20),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 14),
                      DarkTextField(
                        hint: 'Confirm Password', icon: Icons.lock_outline_rounded, obscureText: _obscureConfirm,
                        suffix: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textSecondary, size: 20),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.go('/home'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white, foregroundColor: AppColors.darkBg,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            elevation: 0,
                          ),
                          child: Text('Register Account', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800)),
                        ),
                      ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text('Back to Log In', style: GoogleFonts.inter(color: AppColors.textWhite70, fontSize: 13)),
                      ).animate(delay: 450.ms).fadeIn(),
                      const SizedBox(height: 28),
                      Text('Registered with', style: GoogleFonts.inter(color: AppColors.textWhite70, fontSize: 12)),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SocialBtn(
                            onTap: () {},
                            child: Image.network(
                              'https://www.google.com/images/branding/googleg/1x/googleg_standard_color_128dp.png',
                              width: 24, height: 24,
                              errorBuilder: (_, __, ___) =>
                                  const Text('G', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.white)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          SocialBtn(onTap: () {}, child: const Icon(Icons.apple_rounded, color: AppColors.white, size: 26)),
                        ],
                      ).animate(delay: 500.ms).fadeIn(),
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