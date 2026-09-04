import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../widgets/galaxy_background.dart';
import '../widgets/auth_widgets.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  final bool passwordResetSuccess;
  const LoginScreen({super.key, this.passwordResetSuccess = false});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.passwordResetSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully! Please log in.'),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and Password are required.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.loginUser(email, password);

      if (response['success'] == true) {
        try {
          final session = response['session'];
          if (session != null && session['refresh_token'] != null) {
            await JomnesDB.auth.setSession(
              session['refresh_token'],
              accessToken: session['access_token'],
            );
          } else if (response['token'] != null) {
            try {
              await JomnesDB.auth.setSession(response['token']);
            } catch (e) {
              // Ignore if not a valid refresh token
            }
          }
        } catch (e) {
          // Ignore session sync errors if the backend doesn't provide valid tokens
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Login Successful')),
          );
          context.go('/home');
        }
      } else {
        if (mounted) {
          String errorMessage = response['message'] ?? 'Login failed';
          if (errorMessage == 'Email not confirmed') {
            errorMessage =
                'Please confirm your email address before logging in.';
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
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
    try {
      await _authService.signInWithGoogle();
      // Google Login handled through callbacks, no direct navigation required here.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Google Login failed: $e')));
      }
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
                SizedBox(height: h * 0.38),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          'Welcome Back',
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                        ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your detail below to log into\nyour account.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textWhite70,
                          ),
                        ).animate(delay: 150.ms).fadeIn(),
                        const SizedBox(height: 28),
                        DarkTextField(
                          controller: _emailController,
                          hint: 'Email',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
                        const SizedBox(height: 14),
                        DarkTextField(
                          controller: _passwordController,
                          hint: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.2),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (v) =>
                                    setState(() => _rememberMe = v ?? false),
                                activeColor: AppColors.accentBlue,
                                side: const BorderSide(
                                  color: AppColors.darkBorder,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Remember me',
                              style: GoogleFonts.inter(
                                color: AppColors.textWhite70,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => context.push('/forgot-password'),
                              child: Text(
                                'Forgot password?',
                                style: GoogleFonts.inter(
                                  color: AppColors.accentBlue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ).animate(delay: 300.ms).fadeIn(),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              foregroundColor: AppColors.darkBg,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Log In',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.2),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: Text(
                            'Register Account',
                            style: GoogleFonts.inter(
                              color: AppColors.textWhite70,
                              fontSize: 13,
                            ),
                          ),
                        ).animate(delay: 400.ms).fadeIn(),
                        const SizedBox(height: 28),
                        Text(
                          'or Log In With',
                          style: GoogleFonts.inter(
                            color: AppColors.textWhite70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SocialBtn(
                              onTap: _handleGoogleLogin,
                              child: Image.network(
                                'https://www.google.com/images/branding/googleg/1x/googleg_standard_color_128dp.png',
                                width: 24,
                                height: 24,
                                errorBuilder: (_, _, _) => const Text(
                                  'G',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            SocialBtn(
                              onTap: () {},
                              child: const Icon(
                                Icons.apple_rounded,
                                color: AppColors.white,
                                size: 26,
                              ),
                            ),
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

  List<Widget> _asterisks(double h) => [
    Positioned(
      left: 20,
      top: h * 0.46,
      child: Text(
        '*',
        style: GoogleFonts.inter(
          color: AppColors.white.withAlpha(100),
          fontSize: 18,
        ),
      ),
    ),
    Positioned(
      left: 310,
      top: h * 0.48,
      child: Text(
        '*',
        style: GoogleFonts.inter(
          color: AppColors.white.withAlpha(100),
          fontSize: 18,
        ),
      ),
    ),
    Positioned(
      left: 50,
      top: h * 0.60,
      child: Text(
        '*',
        style: GoogleFonts.inter(
          color: AppColors.white.withAlpha(100),
          fontSize: 14,
        ),
      ),
    ),
    Positioned(
      left: 280,
      top: h * 0.65,
      child: Text(
        '*',
        style: GoogleFonts.inter(
          color: AppColors.white.withAlpha(100),
          fontSize: 14,
        ),
      ),
    ),
    Positioned(
      left: 220,
      top: h * 0.88,
      child: Text(
        '*',
        style: GoogleFonts.inter(
          color: AppColors.white.withAlpha(100),
          fontSize: 16,
        ),
      ),
    ),
  ];
}
