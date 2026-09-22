import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khabark/core/constants/app_spacing.dart';
import 'package:khabark/core/theme/app_colors.dart';
import 'package:khabark/core/theme/app_text_styles.dart';
import 'package:khabark/core/utils/responsive.dart';
import 'package:khabark/core/widgets/app_text_field.dart';
import 'package:khabark/core/widgets/primary_button.dart';

class AuthScreen extends StatefulWidget {
  final bool isLoading;
  final String? errorMessage;
  final void Function(String email, String password) onSignIn;
  final void Function(String email, String password) onSignUp;
  final VoidCallback onGoogleSignIn;

  final Future<void> Function(String email) onForgotPassword;
  final VoidCallback? onModeChanged;

  const AuthScreen({
    super.key,
    required this.isLoading,
    this.errorMessage,
    required this.onSignIn,
    required this.onSignUp,
    required this.onGoogleSignIn,
    required this.onForgotPassword,
    this.onModeChanged,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      if (_isSignUp) {
        widget.onSignUp(email, password);
      } else {
        widget.onSignIn(email, password);
      }
    }
  }

  void _toggleMode() {
    if (widget.isLoading) return;
    _formKey.currentState?.reset();
    setState(() => _isSignUp = !_isSignUp);
    widget.onModeChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.l,
              ),
              child: Responsive.isMobile(context)
                  ? _buildForm()
                  : Card(
                      elevation: 0,
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.cardBorderRadius,
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.l),
                        child: _buildForm(),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Khabark',
                style: GoogleFonts.merriweather(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 3),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),

          Text(
            _isSignUp ? 'Create your account' : 'Welcome back',
            style: AppTextStyles.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _isSignUp
                ? 'Sign up to personalize your news experience'
                : 'Sign in to continue reading',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.l),

          if (widget.errorMessage != null &&
              widget.errorMessage!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: AppSpacing.inputBorderRadius,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      widget.errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          AppTextField(
            label: 'Email address',
            hintText: 'you@example.com',
            controller: _emailController,
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            enabled: !widget.isLoading,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              final v = value.trim();
              final at = v.indexOf('@');
              if (at < 1 || !v.substring(at + 1).contains('.')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.m),

          AppTextField(
            label: 'Password',
            hintText: '••••••••••••',
            controller: _passwordController,
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            obscureText: _obscurePassword,
            enabled: !widget.isLoading,
            onToggleVisibility: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          if (_isSignUp) ...[
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              label: 'Confirm password',
              hintText: '••••••••••••',
              controller: _confirmPasswordController,
              prefixIcon: Icons.lock_reset_rounded,
              isPassword: true,
              obscureText: _obscureConfirmPassword,
              enabled: !widget.isLoading,
              onToggleVisibility: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ],

          if (!_isSignUp) ...[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.isLoading
                    ? null
                    : () =>
                          widget.onForgotPassword(_emailController.text.trim()),
                child: Text(
                  'Forgot password?',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.m),
          ],

          PrimaryButton(
            text: _isSignUp ? 'Create account' : 'Sign in',
            isLoading: widget.isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.m),

          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                child: Text('or', style: AppTextStyles.bodySmall),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: AppSpacing.m),

          OutlinedButton(
            onPressed: widget.isLoading ? null : widget.onGoogleSignIn,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/Google__G__logo.svg',
                  width: 20,
                  height: 20,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.g_mobiledata_rounded,
                    size: 24,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                const Text('Continue with Google'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isSignUp
                    ? 'Already have an account? '
                    : "Don't have an account? ",
                style: AppTextStyles.bodyMedium,
              ),
              TextButton(
                onPressed: widget.isLoading ? null : _toggleMode,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(0, 44),
                ),
                child: Text(
                  _isSignUp ? 'Sign in' : 'Sign up',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
