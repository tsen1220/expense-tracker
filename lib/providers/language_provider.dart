import 'package:flutter/material.dart';
import '../models/language_preference.dart';
import '../services/language_service.dart';

class LanguageProvider extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.english;
  final LanguageService _languageService = LanguageService();

  AppLanguage get currentLanguage => _currentLanguage;

  Locale get locale {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return const Locale('en');
      case AppLanguage.traditionalChinese:
        return const Locale('zh', 'TW');
    }
  }

  Future<void> loadLanguagePreference() async {
    try {
      final languagePreference = await _languageService.getLanguagePreference();
      _currentLanguage = languagePreference.languageCode;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading language preference: $e');
      // Keep default language (English)
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      notifyListeners();

      try {
        await _languageService.setLanguagePreference(language);
      } catch (e) {
        debugPrint('Error saving language preference: $e');
        // Revert on error
        await loadLanguagePreference();
      }
    }
  }

  void toggleLanguage() {
    final newLanguage = _currentLanguage == AppLanguage.english
        ? AppLanguage.traditionalChinese
        : AppLanguage.english;
    setLanguage(newLanguage);
  }
}