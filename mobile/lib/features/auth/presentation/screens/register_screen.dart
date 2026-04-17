import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gnyaan/core/theme/app_colors.dart';
import 'package:gnyaan/core/theme/app_text_styles.dart';
import 'package:gnyaan/core/constants/app_constants.dart';
import 'package:gnyaan/shared/widgets/app_buttons.dart';
import 'package:gnyaan/features/auth/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.register(
        name: _nameController.text.trim(),
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
              const SizedBox(height: 40),

              // ── Back button ──────────────────────────────────────────────
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.bg600,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border200),
                  ),
                  child: const Icon(LucideIcons.arrowLeft,
                      size: 18, color: AppColors.text),
                ),
              ),

              const SizedBox(height: 32),

              // ── Title ────────────────────────────────────────────────────
              Text('Create Account', style: AppTextStyles.displayLg)
                  .animate()
                  .fadeIn()
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 6),
              Text(
                'Join ${AppConstants.appName} to build your knowledge base',
                style:
                    AppTextStyles.bodyLg.copyWith(color: AppColors.textMuted),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 36),

              // ── Form ─────────────────────────────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text('Full Name', style: AppTextStyles.labelLg),
                    const SizedBox(height: 8),
                    _InputField(
                      controller: _nameController,
                      hint: 'John Doe',
                      icon: LucideIcons.user,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Email
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

                    const SizedBox(height: 18),

                    // Password
                    Text('Password', style: AppTextStyles.labelLg),
                    const SizedBox(height: 8),
                    _InputField(
                      controller: _passwordController,
                      hint: '••••••••',
                      icon: LucideIcons.lock,
                      obscureText: _obscurePassword,
                      suffix: GestureDetector(
                        onTap: () => setState(
                            () => _obscurePassword = !_obscurePassword),
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
                        if (v.length < 6) {
                          return 'Minimum 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Confirm Password
                    Text('Confirm Password', style: AppTextStyles.labelLg),
                    const SizedBox(height: 8),
                    _InputField(
                      controller: _confirmPasswordController,
                      hint: '••••••••',
                      icon: LucideIcons.shieldCheck,
                      obscureText: _obscureConfirm,
                      suffix: GestureDetector(
                        onTap: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        child: Icon(
                          _obscureConfirm
                              ? LucideIcons.eyeOff
                              : LucideIcons.eye,
                          size: 18,
                          color: AppColors.iconSubtle,
                        ),
                      ),
                      validator: (v) {
                        if (v != _passwordController.text) {
                          return 'Passwords do not match';
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
                      )
                          .animate()
                          .fadeIn()
                          .shake(hz: 3, offset: const Offset(4, 0)),

                    const SizedBox(height: 28),

                    // Register button
                    PrimaryButton(
                      label: _isLoading ? 'Creating account...' : 'Create Account',
                      icon: _isLoading ? null : LucideIcons.sparkles,
                      onPressed: _isLoading ? () {} : _handleRegister,
                      width: double.infinity,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 28),

              // ── Login link ────────────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.textMuted),
                      children: [
                        TextSpan(
                          text: 'Sign in',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.brand,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms),

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
        hintStyle:
            AppTextStyles.bodyMd.copyWith(color: AppColors.textPlaceholder),
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
          borderSide:
              BorderSide(color: AppColors.brand.withOpacity(0.6), width: 1.5),
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
