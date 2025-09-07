import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/new_home_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'services/theme_service.dart';
import 'models/language_preference.dart';
import 'l10n/app_localizations.dart';

void main() {
  // Initialize sqflite for desktop platforms
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    // Desktop platforms
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Mobile platforms (iOS/Android) use default SQLite

  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  late ThemeProvider _themeProvider;
  late LanguageProvider _languageProvider;

  @override
  void initState() {
    super.initState();
    _themeProvider = ThemeProvider();
    _languageProvider = LanguageProvider();

    // Load saved language preference (theme is loaded automatically in constructor)
    _languageProvider.loadLanguagePreference();
  }

  @override
  void dispose() {
    _themeProvider.dispose();
    _languageProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeProvider,
      builder: (context, child) {
        if (_themeProvider.isLoading) {
          return MaterialApp(
            title: 'Expense Tracker',
            theme: ThemeService.instance.lightTheme,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('zh', 'TW'), // Traditional Chinese
            ],
            home: const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return ListenableBuilder(
          listenable: _languageProvider,
          builder: (context, child) {
            if (_languageProvider.currentLanguage == AppLanguage.english &&
                _languageProvider.locale.languageCode == 'en') {
              // Language is loading, show default
            }

            return MaterialApp(
              title: 'Expense Tracker',
              theme: ThemeService.instance.lightTheme,
              darkTheme: ThemeService.instance.darkTheme,
              themeMode: _themeProvider.themeMode,
              locale: _languageProvider.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'), // English
                Locale('zh', 'TW'), // Traditional Chinese
              ],
              home: MultiProvider(
                providers: [
                  ChangeNotifierProvider<ThemeProvider>.value(value: _themeProvider),
                  ChangeNotifierProvider<LanguageProvider>.value(value: _languageProvider),
                ],
                child: const NewHomeScreen(),
              ),
            );
          },
        );
      },
    );
  }
}
