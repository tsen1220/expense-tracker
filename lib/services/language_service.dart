import '../database/database_helper.dart';
import '../models/language_preference.dart';

class LanguageService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<LanguagePreference> getLanguagePreference() async {
    return await _databaseHelper.getLanguagePreference();
  }

  Future<void> setLanguagePreference(AppLanguage language) async {
    await _databaseHelper.setLanguage(language);
  }

  Future<AppLanguage> getCurrentLanguage() async {
    final preference = await getLanguagePreference();
    return preference.languageCode;
  }

  static const List<AppLanguage> supportedLanguages = [
    AppLanguage.english,
    AppLanguage.traditionalChinese,
  ];

  static bool isLanguageSupported(String languageCode) {
    return supportedLanguages
        .any((lang) => lang.name == languageCode);
  }

  static AppLanguage? getLanguageFromCode(String? languageCode) {
    if (languageCode == null) return null;

    for (final language in supportedLanguages) {
      if (language.name == languageCode) {
        return language;
      }
    }
    return null;
  }
}