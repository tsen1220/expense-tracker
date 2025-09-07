enum AppLanguage {
  english,
  traditionalChinese,
}

extension AppLanguageExtension on AppLanguage {
  String get name {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.traditionalChinese:
        return 'zh_TW';
    }
  }

  String get displayName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.traditionalChinese:
        return '繁體中文';
    }
  }

  static AppLanguage fromString(String value) {
    switch (value) {
      case 'en':
        return AppLanguage.english;
      case 'zh_TW':
        return AppLanguage.traditionalChinese;
      default:
        return AppLanguage.english;
    }
  }
}

class LanguagePreference {
  final int? id;
  final AppLanguage languageCode;
  final DateTime lastUpdated;

  LanguagePreference({
    this.id,
    required this.languageCode,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'language_code': languageCode.name,
      'last_updated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  factory LanguagePreference.fromMap(Map<String, dynamic> map) {
    return LanguagePreference(
      id: map['id'],
      languageCode: AppLanguageExtension.fromString(map['language_code']),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['last_updated']),
    );
  }

  LanguagePreference copyWith({
    int? id,
    AppLanguage? languageCode,
    DateTime? lastUpdated,
  }) {
    return LanguagePreference(
      id: id ?? this.id,
      languageCode: languageCode ?? this.languageCode,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'LanguagePreference{id: $id, languageCode: ${languageCode.name}, lastUpdated: $lastUpdated}';
  }
}