import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('fr'));

  void setLanguage(Locale locale) {
    state = locale;
    // Sauvegardez la préférence linguistique
    _saveLanguagePreference(locale.languageCode);
  }

  void setLanguageCode(String languageCode) {
    final locale = Locale(languageCode);
    state = locale;
    _saveLanguagePreference(languageCode);
  }

  void _saveLanguagePreference(String languageCode) {
    try {
      final box = Hive.box('authBox');
      box.put('language', languageCode);
    } catch (e) {
      // Silently fail if Hive is not available
    }
  }
}
