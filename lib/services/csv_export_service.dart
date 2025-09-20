import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';

class CSVExportService {
  static const String _csvHeader = 'Date,Title,Amount,Type,Category,Description';

  /// Export transactions for selected months to CSV and share
  static Future<void> exportAndShareTransactions({
    required List<DateTime> selectedMonths,
    String? customFileName,
  }) async {
    try {
      // Get all transactions for selected months
      List<Transaction> allTransactions = [];

      for (DateTime month in selectedMonths) {
        final monthTransactions = await DatabaseHelper.instance.getTransactionsByMonth(
          month.year,
          month.month,
        );
        allTransactions.addAll(monthTransactions);
      }

      if (allTransactions.isEmpty) {
        throw Exception('No transactions found for selected months');
      }

      // Sort transactions by date
      allTransactions.sort((a, b) => a.date.compareTo(b.date));

      // Generate CSV content
      final csvContent = _generateCSVContent(allTransactions);

      // Generate filename
      final fileName = customFileName ?? _generateFileName(selectedMonths);

      // Write to file and share
      await _writeAndShareCSV(csvContent, fileName);

    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }

  /// Generate CSV content from transactions
  static String _generateCSVContent(List<Transaction> transactions) {
    final List<List<String>> rows = [];

    // Add header
    rows.add(_csvHeader.split(','));

    // Add transaction data
    for (final transaction in transactions) {
      rows.add([
        DateFormat('yyyy-MM-dd').format(transaction.date),
        _escapeCsvField(transaction.title),
        transaction.amount.toStringAsFixed(2),
        transaction.type.name.toUpperCase(),
        _escapeCsvField(transaction.category.displayName),
        _escapeCsvField(transaction.description ?? ''),
      ]);
    }

    // Convert to CSV string
    return const ListToCsvConverter().convert(rows);
  }

  /// Escape special characters in CSV fields
  static String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  /// Generate filename based on selected months
  static String _generateFileName(List<DateTime> selectedMonths) {
    if (selectedMonths.isEmpty) {
      return 'expense_tracker_export_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
    }

    selectedMonths.sort();

    if (selectedMonths.length == 1) {
      final month = selectedMonths.first;
      return 'expense_tracker_${DateFormat('yyyy_MM').format(month)}.csv';
    } else {
      final startMonth = selectedMonths.first;
      final endMonth = selectedMonths.last;
      return 'expense_tracker_${DateFormat('yyyy_MM').format(startMonth)}_to_${DateFormat('yyyy_MM').format(endMonth)}.csv';
    }
  }

  /// Write CSV content to file and share
  static Future<void> _writeAndShareCSV(String csvContent, String fileName) async {
    try {
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');

      // Write CSV content to file
      await file.writeAsString(csvContent, encoding: utf8);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Expense Tracker Export - $fileName',
        subject: 'Financial Data Export',
      );

    } catch (e) {
      throw Exception('Failed to write and share CSV file: $e');
    }
  }

  /// Get summary statistics for selected months
  static Future<Map<String, dynamic>> getExportSummary(List<DateTime> selectedMonths) async {
    try {
      List<Transaction> allTransactions = [];

      for (DateTime month in selectedMonths) {
        final monthTransactions = await DatabaseHelper.instance.getTransactionsByMonth(
          month.year,
          month.month,
        );
        allTransactions.addAll(monthTransactions);
      }

      double totalIncome = 0;
      double totalExpenses = 0;
      int transactionCount = allTransactions.length;

      for (final transaction in allTransactions) {
        if (transaction.isIncome) {
          totalIncome += transaction.amount;
        } else {
          totalExpenses += transaction.amount;
        }
      }

      return {
        'totalTransactions': transactionCount,
        'totalIncome': totalIncome,
        'totalExpenses': totalExpenses,
        'netBalance': totalIncome - totalExpenses,
        'dateRange': _getDateRangeString(selectedMonths),
      };

    } catch (e) {
      throw Exception('Failed to get export summary: $e');
    }
  }

  /// Get formatted date range string
  static String _getDateRangeString(List<DateTime> selectedMonths) {
    if (selectedMonths.isEmpty) return 'No months selected';

    selectedMonths.sort();

    if (selectedMonths.length == 1) {
      return DateFormat('MMMM yyyy').format(selectedMonths.first);
    } else {
      final start = DateFormat('MMM yyyy').format(selectedMonths.first);
      final end = DateFormat('MMM yyyy').format(selectedMonths.last);
      return '$start - $end';
    }
  }

  /// Validate selected months
  static bool validateSelectedMonths(List<DateTime> selectedMonths) {
    if (selectedMonths.isEmpty) return false;

    // Check if any month is in the future
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    for (final month in selectedMonths) {
      final monthDate = DateTime(month.year, month.month);
      if (monthDate.isAfter(currentMonth)) {
        return false;
      }
    }

    return true;
  }
}