import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/new_home_screen.dart';
import 'services/recurring_transaction_service.dart';

void main() {
  // Initialize sqflite for desktop platforms only
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
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
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    RecurringTransactionService.instance.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    // Initialize recurring transaction service
    await RecurringTransactionService.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const NewHomeScreen(),
    );
  }
}
