import 'package:flutter/material.dart';
import '../models/theme_preference.dart' as model;
import '../database/database_helper.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = true;

  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final themePreference = await DatabaseHelper.instance
          .getThemePreference();
      _themeMode = _convertToFlutterThemeMode(themePreference.themeMode);
    } catch (e) {
      // If there's an error, fall back to system theme
      _themeMode = ThemeMode.system;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode newThemeMode) async {
    if (_themeMode == newThemeMode) return;

    _themeMode = newThemeMode;
    notifyListeners();

    try {
      final customThemeMode = _convertToCustomThemeMode(newThemeMode);
      await DatabaseHelper.instance.setThemeMode(customThemeMode);
    } catch (e) {
      // If saving fails, revert the change
      final oldThemeMode = _themeMode;
      await _loadThemePreference();
      if (_themeMode != oldThemeMode) {
        notifyListeners();
      }
    }
  }

  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case ThemeMode.system:
        await setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.system);
        break;
    }
  }

  String get currentThemeName {
    switch (_themeMode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  IconData get currentThemeIcon {
    switch (_themeMode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.brightness_7;
      case ThemeMode.dark:
        return Icons.brightness_4;
    }
  }

  // Convert custom AppThemeMode enum to Flutter's ThemeMode
  ThemeMode _convertToFlutterThemeMode(model.AppThemeMode customThemeMode) {
    switch (customThemeMode) {
      case model.AppThemeMode.light:
        return ThemeMode.light;
      case model.AppThemeMode.dark:
        return ThemeMode.dark;
      case model.AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  // Convert Flutter's ThemeMode to custom AppThemeMode enum
  model.AppThemeMode _convertToCustomThemeMode(ThemeMode flutterThemeMode) {
    switch (flutterThemeMode) {
      case ThemeMode.light:
        return model.AppThemeMode.light;
      case ThemeMode.dark:
        return model.AppThemeMode.dark;
      case ThemeMode.system:
        return model.AppThemeMode.system;
    }
  }
}
