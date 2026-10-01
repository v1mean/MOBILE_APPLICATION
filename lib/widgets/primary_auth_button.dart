import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// White pill primary button — the "Log In" / "Register Account" /
/// "Send Reset Link" button used on every auth screen.
///
/// Extracts the duplicated ElevatedButton.styleFrom(
///   backgroundColor: AppColors.white,
///   foregroundColor: AppColors.darkBg,
///   padding: EdgeInsets.symmetric(vertical: 18),
///   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
///   elevation: 0,
/// ) pattern that appeared in login, register, teacher_login, teacher_register,
/// forgot_password, change_password, and reset_password screens.
///
/// Example:
///   PrimaryAuthButton(
///     label: 'Log In',
///     isLoading: _isLoading,
///     onPressed: _handleLogin,
///   )
class PrimaryAuthButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const PrimaryAuthButton({
    super.key,
    required this.label,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.darkBg,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 0,
          disabledBackgroundColor: AppColors.white.withValues(alpha: 0.6),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label, style: AppTextStyles.primaryButton),
      ),
    );
  }
}
