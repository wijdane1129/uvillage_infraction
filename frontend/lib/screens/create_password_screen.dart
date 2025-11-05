import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_theme.dart';
import '../models/auth_models.dart';
import '../providers/auth_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/password_strength_indicator.dart';
import '../widgets/password_requirements.dart';

class CreatePasswordScreen extends ConsumerStatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  ConsumerState<CreatePasswordScreen> createState() =>
      _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends ConsumerState<CreatePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late bool _obscurePassword = true;
  late final bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _passwordsMatch =>
      _passwordController.text == _confirmPasswordController.text &&
      _passwordController.text.isNotEmpty;

  void _handleResetPassword() {
    if (_passwordsMatch &&
        _passwordController.text.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(_passwordController.text) &&
        RegExp(r'[0-9]').hasMatch(_passwordController.text) &&
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_passwordController.text)) {
      // Call reset password API
      final request = ResetPasswordRequest(
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        token: '', // Add token from previous screen
      );
      ref.read(authProvider.notifier).resetPassword(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Lock Icon with Glow
              Container(
                decoration: AppTheme.glowingCircle(AppTheme.purpleAccent),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppTheme.purpleAccent, AppTheme.pinkAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 60,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Title and Subtitle
              Text(
                'Create New Password',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your new password must be different\nfrom previously used passwords',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // New Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Password',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Enter new password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppTheme.textSecondary,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Password Strength Indicator
              PasswordStrengthIndicator(password: _passwordController.text),
              const SizedBox(height: 24),
              // Confirm Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirm Password',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _passwordsMatch
                            ? AppTheme.successGreen
                            : AppTheme.borderColor,
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Confirm password',
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _passwordsMatch
                              ? const Icon(
                                  Icons.check_circle,
                                  color: AppTheme.successGreen,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  if (_passwordsMatch)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: const [
                          Icon(Icons.check_circle,
                              size: 16, color: AppTheme.successGreen),
                          SizedBox(width: 8),
                          Text(
                            'Passwords match',
                            style: TextStyle(
                              color: AppTheme.successGreen,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              // Password Requirements
              PasswordRequirements(password: _passwordController.text),
              const SizedBox(height: 32),
              // Reset Password Button
              GradientButton(
                text: 'Reset Password',
                isLoading: authState.isLoading,
                onPressed: _handleResetPassword,
              ),
              if (authState.error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.1),
                    border: Border.all(color: AppTheme.errorRed),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    authState.error!,
                    style: const TextStyle(
                      color: AppTheme.errorRed,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
