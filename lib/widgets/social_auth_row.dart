import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'auth_widgets.dart';

/// "or Log In With" / "Registered with" divider + Google & Facebook buttons.
///
/// Replaces the identical Row(mainAxisAlignment: center, children: [SocialBtn,
/// SizedBox(16), SocialBtn]) block copy-pasted into login_screen,
/// register_screen, teacher_login_screen, and teacher_register_screen.
///
/// Example (student login):
///   SocialAuthRow(
///     label: 'or Log In With',
///     onGoogleTap: _handleGoogleLogin,
///     onFacebookTap: _handleFacebookLogin,
///   )
class SocialAuthRow extends StatelessWidget {
  final String label;
  final VoidCallback onGoogleTap;
  final VoidCallback onFacebookTap;

  const SocialAuthRow({
    super.key,
    this.label = 'or Log In With',
    required this.onGoogleTap,
    required this.onFacebookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.captionWhite70),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SocialBtn(
              onTap: onGoogleTap,
              child: Image.network(
                'https://www.google.com/images/branding/googleg/1x/googleg_standard_color_128dp.png',
                width: 24,
                height: 24,
                errorBuilder: (_, _, _) => const Text(
                  'G',
                  style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.white),
                ),
              ),
            ),
            const SizedBox(width: 16),
            SocialBtn(
              onTap: onFacebookTap,
              child: const Icon(
                Icons.facebook,
                color: Color(0xFF1877F2),
                size: 28,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
