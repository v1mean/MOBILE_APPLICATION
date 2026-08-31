import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../widgets/galaxy_background.dart';
import '../widgets/auth_widgets.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String accessToken;
  const ResetPasswordScreen({super.key, required this.accessToken});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Both fields are required.')),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.updatePassword(password, widget.accessToken);
      if (mounted) {
        if (response['success'] == true) {
          context.go('/login?reset=success');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Password update failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
                      Text('Reset Password',
                          style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.white))
                          .animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 8),
                      Text('Enter your new password below.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textWhite70))
                          .animate(delay: 150.ms).fadeIn(),
                      const SizedBox(height: 28),
                      DarkTextField(
                        controller: _passwordController,
                        hint: 'New Password', icon: Icons.lock_outline_rounded, obscureText: _obscurePassword,
                        suffix: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textSecondary, size: 20),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 14),
                      DarkTextField(
                        controller: _confirmController,
                        hint: 'Confirm Password', icon: Icons.lock_outline_rounded, obscureText: _obscureConfirm,
                        suffix: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textSecondary, size: 20),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleUpdate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white, foregroundColor: AppColors.darkBg,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            elevation: 0,
                          ),
                          child: _isLoading 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text('Save New Password', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800)),
                        ),
                      ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
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

