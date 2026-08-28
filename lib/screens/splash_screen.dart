import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // Background Hero Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.72,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/hero_bg.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                // Gradient overlay at bottom of the image for seamless blend
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 120,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.darkBg.withAlpha(200),
                          AppColors.darkBg,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Twinkle Asterisks
          Positioned(left: 30, top: size.height * 0.65, child: Text('*', style: GoogleFonts.inter(color: Colors.white70, fontSize: 18))),
          Positioned(right: 40, top: size.height * 0.68, child: Text('*', style: GoogleFonts.inter(color: Colors.white70, fontSize: 16))),
          Positioned(left: 100, bottom: 120, child: Text('*', style: GoogleFonts.inter(color: Colors.white54, fontSize: 14))),
          Positioned(right: 60, bottom: 40, child: Text('*', style: GoogleFonts.inter(color: Colors.white54, fontSize: 18))),
          // Bottom Content & CTA
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Find your best mentor,\nStudy anytime',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        height: 1.3,
                      ),
                    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push('/login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.darkBg,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Get Started',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}