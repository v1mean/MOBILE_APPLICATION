import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../widgets/galaxy_background.dart';
import '../theme/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GalaxyBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Floating icons
                    Positioned(
                      top: 30,
                      left: 30,
                      child: _FloatingIcon(emoji: '📜', size: 56)
                          .animate(delay: 400.ms)
                          .fadeIn()
                          .slideX(begin: -0.3),
                    ),
                    Positioned(
                      top: 20,
                      right: 28,
                      child: _FloatingIcon(emoji: '🔔', size: 64)
                          .animate(delay: 500.ms)
                          .fadeIn()
                          .slideX(begin: 0.3),
                    ),
                    Positioned(
                      top: 120,
                      left: 16,
                      child: _FloatingIcon(emoji: '📅', size: 52)
                          .animate(delay: 600.ms)
                          .fadeIn()
                          .slideX(begin: -0.3),
                    ),
                    Positioned(
                      top: 130,
                      right: 20,
                      child: _FloatingIcon(emoji: '🎬', size: 52)
                          .animate(delay: 700.ms)
                          .fadeIn()
                          .slideX(begin: 0.3),
                    ),
                    // Center owl on crystal platform
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        // Glowing platform
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.purple.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: -140),
                        Text(
                          '🦉',
                          style: const TextStyle(fontSize: 120),
                          textAlign: TextAlign.center,
                        )
                            .animate(delay: 200.ms)
                            .fadeIn(duration: 600.ms)
                            .scale(begin: const Offset(0.7, 0.7)),
                        // Crystal gems below
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _CrystalGem(color: Colors.cyan.shade300, size: 28),
                            const SizedBox(width: 6),
                            _CrystalGem(color: Colors.purple.shade300, size: 40),
                            const SizedBox(width: 6),
                            _CrystalGem(color: Colors.blue.shade300, size: 28),
                          ],
                        ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),
                      ],
                    ),
                  ],
                ),
              ),
              // Bottom text + button
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
                child: Column(
                  children: [
                    Text(
                      'Find your best mentor,\nStudy anytime',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        height: 1.3,
                      ),
                    ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.3),
                    const SizedBox(height: 32),
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
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ).animate(delay: 900.ms).fadeIn().slideY(begin: 0.3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingIcon extends StatefulWidget {
  final String emoji;
  final double size;
  const _FloatingIcon({required this.emoji, required this.size});

  @override
  State<_FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<_FloatingIcon> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -8 * _ctrl.value),
        child: child,
      ),
      child: Text(widget.emoji, style: TextStyle(fontSize: widget.size)),
    );
  }
}

class _CrystalGem extends StatelessWidget {
  final Color color;
  final double size;
  const _CrystalGem({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.4,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color, color.withOpacity(0.4)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size * 0.3),
          topRight: Radius.circular(size * 0.3),
          bottomLeft: Radius.circular(size * 0.15),
          bottomRight: Radius.circular(size * 0.15),
        ),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.5), blurRadius: 12, spreadRadius: 2),
        ],
      ),
    );
  }
}
