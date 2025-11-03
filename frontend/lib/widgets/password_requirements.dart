import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class PasswordRequirements extends StatelessWidget {
  final String password;

  const PasswordRequirements({
    super.key,
    required this.password,
  });

  bool _hasMinLength() => password.length >= 8;
  bool _hasUppercase() => RegExp(r'[A-Z]').hasMatch(password);
  bool _hasNumber() => RegExp(r'[0-9]').hasMatch(password);
  bool _hasSpecialChar() => RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password must contain:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 12),
        _RequirementItem(
          text: 'At least 8 characters',
          isMet: _hasMinLength(),
        ),
        const SizedBox(height: 8),
        _RequirementItem(
          text: 'At least one uppercase letter',
          isMet: _hasUppercase(),
        ),
        const SizedBox(height: 8),
        _RequirementItem(
          text: 'At least one number',
          isMet: _hasNumber(),
        ),
        const SizedBox(height: 8),
        _RequirementItem(
          text: 'At least one special character',
          isMet: _hasSpecialChar(),
        ),
      ],
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String text;
  final bool isMet;

  const _RequirementItem({
    required this.text,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isMet ? AppTheme.successGreen : AppTheme.borderColor,
              width: 2,
            ),
          ),
          child: isMet
              ? const Icon(
                  Icons.check,
                  size: 14,
                  color: AppTheme.successGreen,
                )
              : null,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: isMet ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
