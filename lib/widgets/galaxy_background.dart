import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GalaxyBackground extends StatelessWidget {
  final Widget? child;
  final bool showOwl;
  const GalaxyBackground({super.key, this.child, this.showOwl = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.galaxyPurple,
            AppColors.galaxyMid,
            AppColors.galaxyDeep,
            AppColors.galaxyDark,
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: StarFieldPainter(),
        child: child,
      ),
    );
  }
}

class StarFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final smallStar = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    final glowStar = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    for (int i = 0; i < 70; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = rng.nextDouble() * 1.2 + 0.3;
      canvas.drawCircle(Offset(x, y), r, smallStar);
    }
    for (int i = 0; i < 12; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 1.8, glowStar);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DomeClipper extends CustomClipper<Path> {
  final double curveHeight;
  const DomeClipper({this.curveHeight = 40});

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - curveHeight)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + curveHeight,
        0,
        size.height - curveHeight,
      )
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
