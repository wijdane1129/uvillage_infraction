import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_theme.dart';
import '../models/auth_models.dart';
import '../providers/auth_provider.dart';
import '../widgets/gradient_button.dart';
import 'create_password_screen.dart';
import 'dart:async';

class VerificationCodeScreen extends ConsumerStatefulWidget {
  final String email;

  const VerificationCodeScreen({super.key, required this.email});

  @override
  ConsumerState<VerificationCodeScreen> createState() =>
      _VerificationCodeScreenState();
}

class _VerificationCodeScreenState
    extends ConsumerState<VerificationCodeScreen> {
  late List<TextEditingController> _codeControllers;
  late List<FocusNode> _focusNodes;
  late Timer _timer;
  int _secondsRemaining = 600; // 4:32

  @override
  void initState() {
    super.initState();
    // Verification codes are 6 digits (backend generates 6-digit codes).
    // Use a list of controllers and focus nodes so we can show six
    // separate input boxes and support paste/distribution and auto-advance.
    const int codeLength = 6;
    _codeControllers = List.generate(
      codeLength,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(codeLength, (_) => FocusNode());
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  String get _formattedTime {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get _verificationCode => _codeControllers.map((c) => c.text).join();

  void _handleVerification() {
    if (_verificationCode.length == _codeControllers.length) {
      final request = VerificationCodeRequest(
        email: widget.email,
        code: _verificationCode,
      );
      // Call verifyResetCode to validate reset codes for password reset flow.
      ref.read(authProvider.notifier).verifyResetCode(request).then((response) {
        if (response.success) {
          // Navigate to CreatePasswordScreen and pass the verified 6-digit code
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreatePasswordScreen(code: _verificationCode),
            ),
          );
        } else {
          // show error from response
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response.message)));
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer.cancel();
    super.dispose();
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
              // Mail Icon with Glow
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
                    Icons.mail_outline,
                    size: 60,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                'Verification Code',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Subtitle
              Column(
                children: [
                  Text(
                    'We sent a code to your email',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.email,
                    style: const TextStyle(
                      color: AppTheme.cyanAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Code Input Fields (six separate boxes)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_codeControllers.length, (index) {
                  return SizedBox(
                    width: 44,
                    height: 60,
                    child: TextField(
                      controller: _codeControllers[index],
                      focusNode: _focusNodes[index],
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color:
                                _codeControllers[index].text.isEmpty
                                    ? AppTheme.borderColor
                                    : AppTheme.purpleAccent,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.cyanAccent,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                        // If user pasted the full code into one box, distribute it.
                        if (value.length > 1) {
                          final chars = value.split('');
                          for (
                            var i = 0;
                            i < chars.length && i < _codeControllers.length;
                            i++
                          ) {
                            _codeControllers[i].text = chars[i];
                          }
                          // move focus to last
                          _focusNodes.last.requestFocus();
                          return;
                        }

                        if (value.isNotEmpty &&
                            index < _codeControllers.length - 1) {
                          _focusNodes[index + 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              // Timer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Center(
                  child: Text(
                    'Code expires in $_formattedTime',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Verify Button
              GradientButton(
                text: 'Verify Code',
                isLoading: authState.isLoading,
                onPressed: _handleVerification,
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
              // Resend Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Didn\'t receive the code? ',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  GestureDetector(
                    onTap:
                        _secondsRemaining == 0
                            ? () async {
                              // Call backend to resend code and restart timer on success
                              final response = await ref
                                  .read(authProvider.notifier)
                                  .resendVerificationCode(widget.email);
                              if (response.success) {
                                setState(() => _secondsRemaining = 272);
                                _startTimer();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(response.message)),
                                  );
                                }
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(response.message)),
                                  );
                                }
                              }
                            }
                            : null,
                    child: Text(
                      'Resend',
                      style: TextStyle(
                        color:
                            _secondsRemaining == 0
                                ? AppTheme.cyanAccent
                                : AppTheme.textSecondary,
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
