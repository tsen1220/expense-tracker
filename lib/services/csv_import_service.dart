import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class CSVImportResult {
  final int importedCount;
  final int errorCount;
  final List<String> errors;

  CSVImportResult({
    required this.importedCount,
    required this.errorCount,
    required this.errors,
  });

  bool get hasErrors => errorCount > 0;
  bool get hasSuccess => importedCount > 0;
  int get totalProcessed => importedCount + errorCount;
}

class CSVImportService {
  static const List<String> expectedHeaders = [
    'Date',
    'Title',
    'Amount',
    'Type',
    'Category',
    'Description'
  ];

  /// Pick and import CSV file
  static Future<CSVImportResult?> pickAndImportFile() async {
    try {
      // Pick CSV file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null; // User cancelled
      }

      final file = File(result.files.single.path!);
      return await importFromFile(file);

    } catch (e) {
      throw Exception('Failed to pick and import file: $e');
    }
  }

  /// Import transactions from CSV file
  static Future<CSVImportResult> importFromFile(File file) async {
    try {
      // Read and parse CSV
      final csvContent = await file.readAsString();
      final List<List<dynamic>> csvRows = const CsvToListConverter().convert(csvContent);

      if (csvRows.isEmpty) {
        throw Exception('CSV file is empty');
      }

      // Validate headers
      final headers = csvRows.first.map((e) => e.toString().trim()).toList();
      _validateHeaders(headers);

      // Process data rows
      final dataRows = csvRows.skip(1).toList();
      return await _processTransactionRows(dataRows, headers);

    } catch (e) {
      throw Exception('Failed to import CSV file: $e');
    }
  }

  /// Validate CSV headers
  static void _validateHeaders(List<String> headers) {
    final missingHeaders = <String>[];

    for (final expectedHeader in expectedHeaders) {
      if (!headers.any((h) => h.toLowerCase() == expectedHeader.toLowerCase())) {
        missingHeaders.add(expectedHeader);
      }
    }

    if (missingHeaders.isNotEmpty) {
      throw Exception('Missing required headers: ${missingHeaders.join(", ")}');
    }
  }

  /// Process transaction rows from CSV
  static Future<CSVImportResult> _processTransactionRows(
    List<List<dynamic>> rows,
    List<String> headers
  ) async {
    final List<String> errors = [];
    final List<Transaction> validTransactions = [];

    // Get existing categories for mapping
    final categories = await DatabaseHelper.instance.getAllCategories();
    final categoryMap = <String, Category>{};
    for (final category in categories) {
      categoryMap[category.displayName.toLowerCase()] = category;
      categoryMap[category.name.toLowerCase()] = category;
    }

    // Create header index map
    final headerMap = <String, int>{};
    for (int i = 0; i < headers.length; i++) {
      headerMap[headers[i].toLowerCase()] = i;
    }

    for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];
      final rowNumber = rowIndex + 2; // +2 because we skip header and array is 0-indexed

      try {
        // Skip empty rows
        if (row.isEmpty || row.every((cell) => cell.toString().trim().isEmpty)) {
          continue;
        }

        final transaction = _parseTransactionFromRow(row, headerMap, categoryMap, rowNumber);
        if (transaction != null) {
          validTransactions.add(transaction);
        }

      } catch (e) {
        errors.add('Row $rowNumber: $e');
      }
    }

    // Import all valid transactions
    int importedCount = 0;

    for (final transaction in validTransactions) {
      await DatabaseHelper.instance.insertTransaction(transaction);
      importedCount++;
    }

    return CSVImportResult(
      importedCount: importedCount,
      errorCount: errors.length,
      errors: errors,
    );
  }

  /// Parse a single transaction from CSV row
  static Transaction? _parseTransactionFromRow(
    List<dynamic> row,
    Map<String, int> headerMap,
    Map<String, Category> categoryMap,
    int rowNumber,
  ) {
    try {
      // Extract values using header mapping
      final dateStr = _getCellValue(row, headerMap, 'date');
      final title = _getCellValue(row, headerMap, 'title');
      final amountStr = _getCellValue(row, headerMap, 'amount');
      final typeStr = _getCellValue(row, headerMap, 'type');
      final categoryStr = _getCellValue(row, headerMap, 'category');
      final description = _getCellValue(row, headerMap, 'description');

      // Validate required fields
      if (dateStr.isEmpty || title.isEmpty || amountStr.isEmpty || typeStr.isEmpty || categoryStr.isEmpty) {
        throw Exception('Missing required fields');
      }

      // Parse date
      DateTime date;
      try {
        date = DateFormat('yyyy-MM-dd').parse(dateStr);
      } catch (e) {
        throw Exception('Invalid date format: $dateStr (expected yyyy-MM-dd)');
      }

      // Parse amount
      double amount;
      try {
        amount = double.parse(amountStr);
        if (amount < 0) {
          throw Exception('Amount cannot be negative: $amount');
        }
      } catch (e) {
        throw Exception('Invalid amount: $amountStr');
      }

      // Parse transaction type
      TransactionType type;
      final typeUpper = typeStr.toUpperCase();
      if (typeUpper == 'INCOME') {
        type = TransactionType.income;
      } else if (typeUpper == 'EXPENSE') {
        type = TransactionType.expense;
      } else {
        throw Exception('Invalid transaction type: $typeStr (expected INCOME or EXPENSE)');
      }

      // Find category
      final category = categoryMap[categoryStr.toLowerCase()];
      if (category == null) {
        throw Exception('Category not found: $categoryStr');
      }

      // Validate category type matches transaction type
      if (type == TransactionType.income && !category.isIncomeCategory) {
        throw Exception('Category "$categoryStr" is not an income category');
      }
      if (type == TransactionType.expense && category.isIncomeCategory) {
        throw Exception('Category "$categoryStr" is not an expense category');
      }

      return Transaction(
        title: title,
        amount: amount,
        category: category,
        date: date,
        description: description.isNotEmpty ? description : null,
        type: type,
      );

    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Get cell value from row using header mapping
  static String _getCellValue(List<dynamic> row, Map<String, int> headerMap, String headerName) {
    final index = headerMap[headerName.toLowerCase()];
    if (index == null || index >= row.length) {
      return '';
    }
    return row[index]?.toString().trim() ?? '';
  }


  /// Get sample CSV format for user reference
  static String getSampleCSVContent() {
    final List<List<String>> sampleData = [
      expectedHeaders,
      ['2024-01-15', 'Grocery Shopping', '85.50', 'EXPENSE', 'Food', 'Weekly groceries'],
      ['2024-01-15', 'Salary Payment', '3000.00', 'INCOME', 'Salary', 'Monthly salary'],
      ['2024-01-16', 'Gas Station', '45.00', 'EXPENSE', 'Transport', 'Car fuel'],
      ['2024-01-16', 'Movie Tickets', '25.00', 'EXPENSE', 'Entertainment', 'Weekend movie'],
    ];

    return const ListToCsvConverter().convert(sampleData);
  }

  /// Validate import file before processing
  static Future<List<String>> validateFile(File file) async {
    final List<String> issues = [];

    try {
      // Check file size (limit to 10MB)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        issues.add('File size too large (max 10MB)');
      }

      // Check file extension
      if (!file.path.toLowerCase().endsWith('.csv')) {
        issues.add('File must be a CSV file');
      }

      // Read and validate content
      final csvContent = await file.readAsString();
      final List<List<dynamic>> csvRows = const CsvToListConverter().convert(csvContent);

      if (csvRows.isEmpty) {
        issues.add('CSV file is empty');
        return issues;
      }

      // Validate headers
      final headers = csvRows.first.map((e) => e.toString().trim()).toList();
      for (final expectedHeader in expectedHeaders) {
        if (!headers.any((h) => h.toLowerCase() == expectedHeader.toLowerCase())) {
          issues.add('Missing required header: $expectedHeader');
        }
      }

      // Check if there are data rows
      if (csvRows.length < 2) {
        issues.add('CSV file contains no data rows');
      }

    } catch (e) {
      issues.add('Failed to read CSV file: $e');
    }

    return issues;
  }
}