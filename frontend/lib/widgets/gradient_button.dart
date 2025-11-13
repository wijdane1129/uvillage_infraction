import 'package:flutter/material.dart';
// Accès au dégradé et aux couleurs
import '../config/app_theme.dart'; 

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  // Permet de différencier le bouton principal (dégradé) du secondaire (bordure)
  final bool isPrimary; 
  // Hauteur du bouton (optionnelle)
  final double? height;
  // Rayon des coins du bouton (optionel)
  final double? radius;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.height,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Définir le décor/couleurs
    final double effectiveRadius = radius ?? 30.0;
    final double effectiveHeight = height ?? 55.0;

    final decoration = isPrimary
        ? BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(effectiveRadius)),
            // Utilisation du dégradé défini dans AppTheme
            gradient: AppTheme.buttonGradient, 
          )
        : BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(effectiveRadius)),
            // Utilisation de borderColor pour la bordure
            border: Border.all(color: AppTheme.borderColor, width: 2), 
            color: Colors.transparent,
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: effectiveHeight,
            alignment: Alignment.center,
            decoration: decoration,
            child: Text(
              text,
              // Utilisation de textPrimary de AppTheme
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