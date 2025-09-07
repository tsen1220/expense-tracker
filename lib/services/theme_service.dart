import 'package:flutter/material.dart';
import '../models/theme_preference.dart' as model;
import '../database/database_helper.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static ThemeService get instance => _instance;

  Future<model.ThemePreference> getThemePreference() async {
    return await DatabaseHelper.instance.getThemePreference();
  }

  Future<void> saveThemePreference(model.AppThemeMode themeMode) async {
    await DatabaseHelper.instance.setThemeMode(themeMode);
  }

  // Get system theme configuration
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        margin: EdgeInsets.all(8),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        margin: EdgeInsets.all(8),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
    );
  }

  // Helper methods for theme switching
  String getThemeDisplayName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return '跟隨系統';
      case ThemeMode.light:
        return '淺色模式';
      case ThemeMode.dark:
        return '深色模式';
    }
  }

  IconData getThemeIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.brightness_7;
      case ThemeMode.dark:
        return Icons.brightness_4;
    }
  }

  List<ThemeMode> get availableThemes => [
    ThemeMode.system,
    ThemeMode.light,
    ThemeMode.dark,
  ];
}