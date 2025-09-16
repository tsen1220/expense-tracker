import 'dart:async';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/recurring_transaction.dart';

class RecurringTransactionService {
  static final RecurringTransactionService _instance = RecurringTransactionService._internal();
  factory RecurringTransactionService() => _instance;
  RecurringTransactionService._internal();

  static RecurringTransactionService get instance => _instance;

  Timer? _periodicTimer;
  VoidCallback? _onTransactionsProcessed;

  /// Initialize the service and check for due transactions
  Future<void> initialize({VoidCallback? onTransactionsProcessed}) async {
    _onTransactionsProcessed = onTransactionsProcessed;

    // Process any due transactions on startup
    await processAllDueRecurringTransactions();

    // Set up periodic check (every hour)
    _startPeriodicCheck();
  }

  /// Start periodic checking for due transactions
  void _startPeriodicCheck() {
    // Cancel any existing timer
    _periodicTimer?.cancel();

    // Check every hour for due transactions
    _periodicTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      processAllDueRecurringTransactions();
    });
  }

  /// Stop the periodic checking
  void dispose() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  /// Process all due recurring transactions
  Future<int> processAllDueRecurringTransactions() async {
    try {
      final dueTransactions = await DatabaseHelper.instance.getDueRecurringTransactions();

      if (dueTransactions.isEmpty) {
        return 0;
      }

      int processedCount = 0;

      for (final recurringTransaction in dueTransactions) {
        try {
          // Skip if it should expire
          if (recurringTransaction.shouldExpire) {
            await DatabaseHelper.instance.updateRecurringTransaction(
              recurringTransaction.copyWith(isActive: false),
            );
            continue;
          }

          // Execute the recurring transaction
          await DatabaseHelper.instance.executeRecurringTransaction(recurringTransaction);
          processedCount++;

          debugPrint('RecurringTransactionService: Executed ${recurringTransaction.title}');
        } catch (e) {
          debugPrint('RecurringTransactionService: Error executing ${recurringTransaction.title}: $e');
        }
      }

      if (processedCount > 0) {
        debugPrint('RecurringTransactionService: Processed $processedCount recurring transactions');

        // Notify listeners that transactions were processed
        _onTransactionsProcessed?.call();
      }

      return processedCount;
    } catch (e) {
      debugPrint('RecurringTransactionService: Error processing recurring transactions: $e');
      return 0;
    }
  }

  /// Get count of due transactions
  Future<int> getDueTransactionCount() async {
    try {
      final dueTransactions = await DatabaseHelper.instance.getDueRecurringTransactions();
      return dueTransactions.length;
    } catch (e) {
      debugPrint('RecurringTransactionService: Error getting due transaction count: $e');
      return 0;
    }
  }

  /// Get all due transactions
  Future<List<RecurringTransaction>> getDueTransactions() async {
    try {
      return await DatabaseHelper.instance.getDueRecurringTransactions();
    } catch (e) {
      debugPrint('RecurringTransactionService: Error getting due transactions: $e');
      return [];
    }
  }

  /// Check if there are any overdue transactions (more than 1 day past due)
  Future<bool> hasOverdueTransactions() async {
    try {
      final dueTransactions = await getDueTransactions();
      final now = DateTime.now();

      for (final transaction in dueTransactions) {
        final daysSincedue = now.difference(transaction.nextDueDate).inDays;
        if (daysSincedue > 1) {
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('RecurringTransactionService: Error checking overdue transactions: $e');
      return false;
    }
  }

  /// Execute a specific recurring transaction manually
  Future<bool> executeRecurringTransaction(RecurringTransaction recurringTransaction) async {
    try {
      await DatabaseHelper.instance.executeRecurringTransaction(recurringTransaction);
      debugPrint('RecurringTransactionService: Manually executed ${recurringTransaction.title}');

      // Notify listeners that a transaction was processed
      _onTransactionsProcessed?.call();

      return true;
    } catch (e) {
      debugPrint('RecurringTransactionService: Error manually executing ${recurringTransaction.title}: $e');
      return false;
    }
  }

  /// Set a callback to be called when transactions are processed
  void setOnTransactionsProcessedCallback(VoidCallback? callback) {
    _onTransactionsProcessed = callback;
  }

  /// Force a check for due transactions (useful for manual refresh)
  Future<void> forceCheck() async {
    await processAllDueRecurringTransactions();
  }
}