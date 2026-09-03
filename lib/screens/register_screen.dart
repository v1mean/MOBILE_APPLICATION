import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../widgets/galaxy_background.dart';
import '../widgets/auth_widgets.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (fullName.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required.')),
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
      final response = await ApiService.registerUser(email, password, fullName);
      
      if (response['success'] == true) {
        if (mounted) {
          if (response['session'] != null) {
            context.go('/login');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration successful! Please check your email to verify your account before logging in.')),
            );
            context.go('/login');
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Registration failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error connecting to server: $e')),
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
          // Galaxy Hero Image with Dome Clip
          ClipPath(
            clipper: const DomeClipper(curveHeight: 50),
            child: SizedBox(
              height: h * 0.42,
              width: double.infinity,
              child: Image.asset(
                'assets/images/hero_bg.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(left: 20, top: h * 0.44, child: Text('*', style: GoogleFonts.inter(color: AppColors.white.withAlpha(100), fontSize: 18))),
          Positioned(left: 310, top: h * 0.46, child: Text('*', style: GoogleFonts.inter(color: AppColors.white.withAlpha(100), fontSize: 18))),
          Positioned(left: 140, top: h * 0.60, child: Text('*', style: GoogleFonts.inter(color: AppColors.white.withAlpha(100), fontSize: 14))),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: h * 0.36),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text('Welcome to Jomnes',
                            style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.white))
                            .animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),
                        const SizedBox(height: 8),
                        Text('Enter your detail below to register\nyour account.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textWhite70))
                            .animate(delay: 150.ms).fadeIn(),
                        const SizedBox(height: 28),
                        DarkTextField(controller: _fullNameController, hint: 'Full Name', icon: Icons.person_outline_rounded)
                            .animate(delay: 180.ms).fadeIn().slideY(begin: 0.2),
                        const SizedBox(height: 14),
                        DarkTextField(controller: _emailController, hint: 'Email', icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress)
                            .animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
                        const SizedBox(height: 14),
                        DarkTextField(
                          controller: _passwordController,
                          hint: 'Password', icon: Icons.lock_outline_rounded, obscureText: _obscurePassword,
                          suffix: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppColors.textSecondary, size: 20),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.2),
                        const SizedBox(height: 14),
                        DarkTextField(
                          controller: _confirmController,
                          hint: 'Confirm Password', icon: Icons.lock_outline_rounded, obscureText: _obscureConfirm,
                          suffix: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppColors.textSecondary, size: 20),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white, foregroundColor: AppColors.darkBg,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                              elevation: 0,
                            ),
                            child: _isLoading 
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text('Register Account', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800)),
                          ),
                        ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.2),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Text('Back to Log In', style: GoogleFonts.inter(color: AppColors.textWhite70, fontSize: 13)),
                        ).animate(delay: 400.ms).fadeIn(),
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
                                errorBuilder: (_, _, _) =>
                                    const Text('G', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.white)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            SocialBtn(onTap: () {}, child: const Icon(Icons.apple_rounded, color: AppColors.white, size: 26)),
                          ],
                        ).animate(delay: 450.ms).fadeIn(),
                        const SizedBox(height: 40),
                      ],
                    ),
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