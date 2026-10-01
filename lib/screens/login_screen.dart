
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
import '../main.dart';
import '../router.dart';

class LoginScreen extends StatefulWidget {
  final bool passwordResetSuccess;
  final String role;
  const LoginScreen({super.key, this.passwordResetSuccess = false, this.role = 'student'});
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
      final response = await ApiService.loginUser(email, password, widget.role);

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
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle(widget.role);
     
      // Dynamic routing will be handled by router.dart based on DB role
    } catch (e) {
      debugPrint('Google Login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Login failed: $e'),
            duration: const Duration(seconds: 6),
          ),
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
      // Do NOT navigate here: signInWithOAuth only launches the browser and
      // returns immediately, long before the user has logged in. Navigating
      // now would hit the router's auth guard (no session yet) and bounce
      // straight back to /login. The onAuthStateChange listener in router.dart
      // handles the redirect to /home once the session actually lands.
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
                          style: AppTextStyles.h1,
                        ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your detail below to log into\nyour account.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmWhite70,
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
                                style: AppTextStyles.link,
                              ),
                            ),
                          ],
                        ).animate(delay: 300.ms).fadeIn(),
                        const SizedBox(height: 28),
                        PrimaryAuthButton(label: 'Log In', isLoading: _isLoading, onPressed: _handleLogin).animate(delay: 350.ms).fadeIn().slideY(begin: 0.2),
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
                        SocialAuthRow(label: 'or Log In With', onGoogleTap: _handleGoogleLogin, onFacebookTap: _handleFacebookLogin).animate(delay: 450.ms).fadeIn(),
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
                                  style: AppTextStyles.bodySmWhite70,
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
                        const SizedBox(height: 32),
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



