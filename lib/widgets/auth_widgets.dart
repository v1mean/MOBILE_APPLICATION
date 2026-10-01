import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SparkleIcon extends StatelessWidget {
  const SparkleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.darkBorder, width: 1.5),
      ),
      child: const Center(
        child: Text('✦', style: TextStyle(color: AppColors.white, fontSize: 20)),
      ),
    );
  }
}

/// Dark-themed text field used on all auth screens.
/// Uses [AppTextStyles.inputText] for consistent input font.
class DarkTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final TextEditingController? controller;

  const DarkTextField({
    super.key,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: AppTextStyles.inputText,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        suffixIcon: suffix,
      ),
    );
  }
}

/// Square icon button used for Google / Facebook / Apple sign-in.
/// Fixed 52×52 size with [AppColors.darkCard] background and rounded corners.
class SocialBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const SocialBtn({super.key, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Center(child: child),
      ),
    );
  }
}
