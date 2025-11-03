import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_theme.dart';
import '../models/auth_models.dart';
import '../providers/auth_provider.dart';
import '../widgets/gradient_button.dart';
import 'verification_code_screen.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleForgotPassword() {
    if (_emailController.text.isNotEmpty &&
        RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text)) {
      final request = ForgotPasswordRequest(email: _emailController.text);
      ref.read(authProvider.notifier).forgotPassword(request);

      // Navigate to verification code screen
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VerificationCodeScreen(
                email: _emailController.text,
              ),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Title
              Text(
                'Forgot your password?',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                'Enter the email associated with your account\nand we\'ll send you a verification code to reset\nyour password.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Illustration
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    Icons.security,
                    size: 120,
                    color: AppTheme.purpleAccent.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Email Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email address',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Send Verification Code Button
              GradientButton(
                text: 'Send Verification Code',
                isLoading: authState.isLoading,
                onPressed: _handleForgotPassword,
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
              const SizedBox(height: 24),
              // Navigation Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Remember your password? ',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        color: AppTheme.pinkAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
