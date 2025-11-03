import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  PasswordStrength _calculateStrength(String password) {
    if (password.isEmpty) return PasswordStrength.none;
    
    int strength = 0;
    if (password.length >= 8) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    if (strength <= 1) return PasswordStrength.weak;
    if (strength <= 2) return PasswordStrength.fair;
    if (strength <= 3) return PasswordStrength.good;
    return PasswordStrength.strong;
  }

  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength(password);
    final progressValue = (strength.index + 1) / 5;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password Strength',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              strength.label,
              style: TextStyle(
                color: strength.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progressValue,
            minHeight: 8,
            backgroundColor: AppTheme.borderColor,
            valueColor: AlwaysStoppedAnimation<Color>(strength.color),
          ),
        ),
      ],
    );
  }
}

enum PasswordStrength {
  none,
  weak,
  fair,
  good,
  strong,
}

extension PasswordStrengthExt on PasswordStrength {
  String get label {
    switch (this) {
      case PasswordStrength.none:
        return 'None';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.fair:
        return 'Fair';
      case PasswordStrength.good:
        return 'Good';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  Color get color {
    switch (this) {
      case PasswordStrength.none:
        return AppTheme.textSecondary;
      case PasswordStrength.weak:
        return AppTheme.errorRed;
      case PasswordStrength.fair:
        return Color(0xFFFFA500);
      case PasswordStrength.good:
        return Color(0xFF64B5F6);
      case PasswordStrength.strong:
        return AppTheme.successGreen;
    }
  }
}
