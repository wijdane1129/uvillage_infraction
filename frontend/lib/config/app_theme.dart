import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color darkBg = Color(0xFF1A1D2E);
  static const Color darkBgAlt = Color(0xFF0F1419);
  static const Color purpleAccent = Color(0xFFAB47BC);
  static const Color pinkAccent = Color(0xFFEC407A);
  static const Color cyanAccent = Color(0xFF26C6DA);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color borderColor = Color(0xFF2D3748);
  static const Color errorRed = Color(0xFFEF5350);
  static const Color successGreen = Color(0xFF66BB6A);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkBgAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: purpleAccent, width: 2),
      ),
      hintStyle: const TextStyle(color: textSecondary),
      labelStyle: const TextStyle(color: textPrimary),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        color: textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: purpleAccent,
        foregroundColor: textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );

  // Gradient for buttons
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [purpleAccent, pinkAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glow effect for circular icon
  static BoxDecoration glowingCircle(Color glowColor) {
    return BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: glowColor.withOpacity(0.4),
          blurRadius: 40,
          spreadRadius: 20,
        ),
      ],
    );
  }
}
