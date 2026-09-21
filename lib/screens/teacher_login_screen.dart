import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class TeacherLoginScreen extends StatelessWidget {
  const TeacherLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white70, size: 16),
                ),
              ).animate().fadeIn(duration: 300.ms),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C3547),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: const Color(0xFF0EA5E9).withAlpha(80),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text('🏫', style: TextStyle(fontSize: 44)),
                        ),
                      ).animate(delay: 100.ms).fadeIn().scale(),
                      const SizedBox(height: 28),
                      Text(
                        'Teacher Portal',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 12),
                      Text(
                        'Coming Soon',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0EA5E9),
                          letterSpacing: 2,
                        ),
                      ).animate(delay: 280.ms).fadeIn(),
                      const SizedBox(height: 16),
                      Text(
                        'We\'re building an amazing space for\nteachers, coaches, and trainers.\nCheck back soon!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white54,
                          height: 1.6,
                        ),
                      ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => context.go('/role-select'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFF0EA5E9), width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Text(
                            'Go Back',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0EA5E9),
                            ),
                          ),
                        ),
                      ).animate(delay: 420.ms).fadeIn().slideY(begin: 0.2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
