import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/csv_import_service.dart';
import '../l10n/app_localizations.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  bool _isImporting = false;
  CSVImportResult? _importResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.importData),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.importInstructions,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.selectCSVFormat,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text('• ${AppLocalizations.of(context)!.dateFormat}'),
                    Text('• ${AppLocalizations.of(context)!.titleFormat}'),
                    Text('• ${AppLocalizations.of(context)!.amountFormat}'),
                    Text('• ${AppLocalizations.of(context)!.typeFormat}'),
                    Text('• ${AppLocalizations.of(context)!.categoryFormat}'),
                    Text('• ${AppLocalizations.of(context)!.descriptionFormat}'),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.importNote,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Sample CSV Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.file_copy_outlined,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.sampleCSVFormat,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _copySampleCSV,
                          icon: const Icon(Icons.copy, size: 16),
                          label: Text(AppLocalizations.of(context)!.copy),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Date,Title,Amount,Type,Category,Description\n'
                        '2024-01-15,Grocery Shopping,85.50,EXPENSE,Food,Weekly groceries\n'
                        '2024-01-15,Salary Payment,3000.00,INCOME,Salary,Monthly salary',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Import Button
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isImporting ? null : _importCSV,
                  icon: _isImporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file),
                  label: Text(_isImporting ? AppLocalizations.of(context)!.importing : AppLocalizations.of(context)!.selectCSVFile),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Import Result
            if (_importResult != null) _buildImportResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildImportResult() {
    final result = _importResult!;
    final hasSuccess = result.hasSuccess;
    final hasErrors = result.hasErrors;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasErrors && !hasSuccess
                      ? Icons.error_outline
                      : hasSuccess
                          ? Icons.check_circle_outline
                          : Icons.warning_amber_outlined,
                  color: hasErrors && !hasSuccess
                      ? Theme.of(context).colorScheme.error
                      : hasSuccess
                          ? Colors.green
                          : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.importResult,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Summary
            _buildResultRow(
              AppLocalizations.of(context)!.successfullyImported,
              '${result.importedCount} ${AppLocalizations.of(context)!.transactions}',
              Colors.green,
            ),
            if (result.errorCount > 0)
              _buildResultRow(
                AppLocalizations.of(context)!.errorsEncountered,
                '${result.errorCount} ${AppLocalizations.of(context)!.rows}',
                Theme.of(context).colorScheme.error,
              ),

            const SizedBox(height: 16),

            // Detailed errors
            if (result.errors.isNotEmpty) ...[
              Text(
                AppLocalizations.of(context)!.errors,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: result.errors
                      .map((error) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '• $error',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action buttons
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.check),
                label: Text(AppLocalizations.of(context)!.done),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _importCSV() async {
    setState(() {
      _isImporting = true;
      _importResult = null;
    });

    try {
      final result = await CSVImportService.pickAndImportFile();

      if (result != null) {
        setState(() {
          _importResult = result;
        });

        // Show snackbar for quick feedback
        if (mounted) {
          final localizations = AppLocalizations.of(context)!;
        final message = result.hasSuccess
              ? localizations.importSuccessMessage(result.importedCount)
              : localizations.importFailedMessage(result.errorCount);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: result.hasSuccess
                  ? Colors.green
                  : Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.importFailedWithError(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  Future<void> _copySampleCSV() async {
    final sampleContent = CSVImportService.getSampleCSVContent();
    await Clipboard.setData(ClipboardData(text: sampleContent));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.sampleCSVCopied),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}