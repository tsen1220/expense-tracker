enum AppThemeMode {
  light,
  dark,
  system,
}

class ThemePreference {
  final int? id;
  final AppThemeMode themeMode;
  final DateTime lastUpdated;

  const ThemePreference({
    this.id,
    required this.themeMode,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'theme_mode': themeMode.name,
      'last_updated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  factory ThemePreference.fromMap(Map<String, dynamic> map) {
    return ThemePreference(
      id: map['id'],
      themeMode: AppThemeMode.values.firstWhere(
        (mode) => mode.name == map['theme_mode'],
        orElse: () => AppThemeMode.system,
      ),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['last_updated']),
    );
  }

  ThemePreference copyWith({
    int? id,
    AppThemeMode? themeMode,
    DateTime? lastUpdated,
  }) {
    return ThemePreference(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemePreference &&
        other.id == id &&
        other.themeMode == themeMode &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return id.hashCode ^ themeMode.hashCode ^ lastUpdated.hashCode;
  }

  @override
  String toString() {
    return 'ThemePreference(id: $id, themeMode: $themeMode, lastUpdated: $lastUpdated)';
  }
}