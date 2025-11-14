import 'package:flutter/material.dart';
// Accès au dégradé et aux couleurs
import '../config/app_theme.dart'; 

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isPrimary; 
  final double? height;
  final double? radius;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.height,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final double effectiveRadius = radius ?? 30.0;
    final double effectiveHeight = height ?? 55.0;

    final decoration = isPrimary
        ? BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(effectiveRadius)),
            gradient: AppTheme.buttonGradient, 
          )
        : BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(effectiveRadius)),
            border: Border.all(color: AppTheme.borderColor, width: 2), 
            color: Colors.transparent,
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(effectiveRadius),
          child: Container(
            height: effectiveHeight,
            alignment: Alignment.center,
            decoration: decoration,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.textPrimary,
                      ),
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
