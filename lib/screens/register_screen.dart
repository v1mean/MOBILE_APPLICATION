import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../widgets/galaxy_background.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/primary_auth_button.dart';
import '../widgets/social_auth_row.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../router.dart';
import '../main.dart';

class RegisterScreen extends StatefulWidget {
  final String role;
  const RegisterScreen({super.key, this.role = 'student'});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

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
      final response = await ApiService.registerUser(email, password, fullName, widget.role);
      
      if (response['success'] == true) {
        if (mounted) {
          if (response['session'] != null) {
            final session = JomnesDB.auth.currentSession;
            String finalRole = widget.role;
            if (session != null) {
               try {
                  final data = await JomnesDB.from('profiles').select('role').eq('id', session.user.id).maybeSingle();
                  if (data != null && data['role'] != null) {
                    finalRole = data['role'];
                  }
               } catch (_) {}
            }
            if (!mounted) return;
            if (finalRole == 'teacher' || finalRole == 'mentor') {
               context.go('/teacher-home');
            } else {
               context.go('/home');
            }
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

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle(widget.role);
      // Dynamic routing handled in router.dart
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Login failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleFacebookLogin() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithFacebook(widget.role);
      // No navigation here — signInWithOAuth returns as soon as the browser is
      // launched, before login completes. router.dart's onAuthStateChange
      // listener sends us to /home once the session actually arrives.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Facebook Login failed: $e')),
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
              height: h * 0.44,
              width: double.infinity,
              child: Image.asset(
                'assets/images/hero_bg.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          ..._asterisks(h),
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
                            style: AppTextStyles.h1)
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
                        PrimaryAuthButton(label: 'Register Account', isLoading: _isLoading, onPressed: _handleRegister).animate(delay: 350.ms).fadeIn().slideY(begin: 0.2),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Text('Back to Log In', style: AppTextStyles.bodySmWhite70),
                        ).animate(delay: 400.ms).fadeIn(),
                        const SizedBox(height: 28),
                        SocialAuthRow(label: 'Registered with', onGoogleTap: _handleGoogleLogin, onFacebookTap: _handleFacebookLogin).animate(delay: 450.ms).fadeIn(),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: () {
                            isGuestMode = true;
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.darkCard.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: AppColors.darkBorder.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Continue as guest',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textWhite70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: AppColors.textWhite70,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ).animate(delay: 500.ms).fadeIn(),
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

  List<Widget> _asterisks(double h) => [
    Positioned(left: 30, top: h * 0.45, child: Text('*', style: GoogleFonts.inter(color: AppColors.white.withAlpha(100), fontSize: 18))),
    Positioned(left: 320, top: h * 0.47, child: Text('*', style: GoogleFonts.inter(color: AppColors.white.withAlpha(100), fontSize: 18))),
    Positioned(left: 40, top: h * 0.62, child: Text('*', style: GoogleFonts.inter(color: AppColors.white.withAlpha(100), fontSize: 14))),
    Positioned(left: 290, top: h * 0.63, child: Text('*', style: GoogleFonts.inter(color: AppColors.white.withAlpha(100), fontSize: 14))),
    Positioned(left: 200, top: h * 0.85, child: Text('*', style: GoogleFonts.inter(color: AppColors.white.withAlpha(100), fontSize: 16))),
  ];
}

