import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gnyaan/core/theme/app_colors.dart';
import 'package:gnyaan/core/theme/app_text_styles.dart';
import 'package:gnyaan/core/constants/app_constants.dart';
import 'package:gnyaan/shared/widgets/app_buttons.dart';
import 'package:gnyaan/features/auth/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg800,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding * 1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // ── Logo + Branding ──────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brand.withOpacity(0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.brain,
                          size: 32, color: Colors.white),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0.7, 0.7),
                          curve: Curves.elasticOut,
                          duration: 700.ms,
                        )
                        .fadeIn(),
                    const SizedBox(height: 16),
                    Text(
                      AppConstants.appName,
                      style: AppTextStyles.displayLg,
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 4),
                    Text(
                      'Welcome back',
                      style: AppTextStyles.bodyLg
                          .copyWith(color: AppColors.textMuted),
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // ── Form ─────────────────────────────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email field
                    Text('Email', style: AppTextStyles.labelLg),
                    const SizedBox(height: 8),
                    _InputField(
                      controller: _emailController,
                      hint: 'you@example.com',
                      icon: LucideIcons.mail,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Password field
                    Text('Password', style: AppTextStyles.labelLg),
                    const SizedBox(height: 8),
                    _InputField(
                      controller: _passwordController,
                      hint: '••••••••',
                      icon: LucideIcons.lock,
                      obscureText: _obscurePassword,
                      suffix: GestureDetector(
                        onTap: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                        child: Icon(
                          _obscurePassword
                              ? LucideIcons.eyeOff
                              : LucideIcons.eye,
                          size: 18,
                          color: AppColors.iconSubtle,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // Error message
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                              color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.alertCircle,
                                size: 16, color: AppColors.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTextStyles.bodySm
                                    .copyWith(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().shake(hz: 3, offset: const Offset(4, 0)),

                    const SizedBox(height: 28),

                    // Login button
                    PrimaryButton(
                      label: _isLoading ? 'Signing in...' : 'Sign In',
                      icon: _isLoading ? null : LucideIcons.logIn,
                      onPressed: _isLoading ? () {} : _handleLogin,
                      width: double.infinity,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 32),

              // ── Register link ─────────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/register'),
                  child: RichText(
                    text: TextSpan(
                      text: 'Don\'t have an account? ',
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.textMuted),
                      children: [
                        TextSpan(
                          text: 'Create one',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.brand,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Shared Input Field ────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMd,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textPlaceholder),
        prefixIcon: Icon(icon, size: 18, color: AppColors.iconSubtle),
        suffixIcon: suffix != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffix,
              )
            : null,
        filled: true,
        fillColor: AppColors.bg600,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.brand.withOpacity(0.6), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}
