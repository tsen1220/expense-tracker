import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/multi_month_picker.dart';
import '../services/csv_export_service.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  List<DateTime> _selectedMonths = [];
  Map<String, dynamic>? _exportSummary;
  bool _isLoadingSummary = false;
  bool _isExporting = false;
  final TextEditingController _customFileNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-select current month
    final now = DateTime.now();
    _selectedMonths = [DateTime(now.year, now.month)];
    _loadSummary();
  }

  @override
  void dispose() {
    _customFileNameController.dispose();
    super.dispose();
  }

  Future<void> _loadSummary() async {
    if (_selectedMonths.isEmpty) {
      setState(() {
        _exportSummary = null;
      });
      return;
    }

    setState(() {
      _isLoadingSummary = true;
    });

    try {
      final summary = await CSVExportService.getExportSummary(_selectedMonths);
      setState(() {
        _exportSummary = summary;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading summary: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingSummary = false;
      });
    }
  }

  void _onSelectionChanged(List<DateTime> selectedMonths) {
    setState(() {
      _selectedMonths = selectedMonths;
    });
    _loadSummary();
  }

  Future<void> _exportCSV() async {
    if (_selectedMonths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one month to export'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!CSVExportService.validateSelectedMonths(_selectedMonths)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid month selection. Future months cannot be exported.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      String? customFileName;
      if (_customFileNameController.text.trim().isNotEmpty) {
        String fileName = _customFileNameController.text.trim();
        if (!fileName.endsWith('.csv')) {
          fileName += '.csv';
        }
        customFileName = fileName;
      }

      await CSVExportService.exportAndShareTransactions(
        selectedMonths: _selectedMonths,
        customFileName: customFileName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV exported and shared successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
        backgroundColor: theme.colorScheme.surfaceVariant,
        actions: [
          IconButton(
            onPressed: _selectedMonths.isNotEmpty && !_isExporting
                ? _exportCSV
                : null,
            icon: _isExporting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                : const Icon(Icons.share),
            tooltip: 'Export and Share CSV',
          ),
        ],
      ),
      body: Column(
        children: [
          // Export summary card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.assessment,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Export Summary',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_isLoadingSummary)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_exportSummary != null) ...[
                  _SummaryRow(
                    label: 'Period',
                    value: _exportSummary!['dateRange'],
                    icon: Icons.date_range,
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: 'Total Transactions',
                    value: _exportSummary!['totalTransactions'].toString(),
                    icon: Icons.receipt_long,
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: 'Total Income',
                    value: currencyFormatter.format(_exportSummary!['totalIncome']),
                    icon: Icons.trending_up,
                    valueColor: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: 'Total Expenses',
                    value: currencyFormatter.format(_exportSummary!['totalExpenses']),
                    icon: Icons.trending_down,
                    valueColor: Colors.red,
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: 'Net Balance',
                    value: currencyFormatter.format(_exportSummary!['netBalance']),
                    icon: Icons.account_balance,
                    valueColor: _exportSummary!['netBalance'] >= 0
                        ? Colors.blue
                        : Colors.orange,
                  ),
                ] else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Select months to see summary',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Custom filename input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _customFileNameController,
              decoration: InputDecoration(
                labelText: 'Custom filename (optional)',
                hintText: 'e.g., monthly_expenses_2024',
                prefixIcon: const Icon(Icons.drive_file_rename_outline),
                suffixText: '.csv',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                helperText: 'Leave empty for auto-generated filename',
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Month selection
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MultiMonthPicker(
                selectedMonths: _selectedMonths,
                onSelectionChanged: _onSelectionChanged,
              ),
            ),
          ),

          // Export button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedMonths.isNotEmpty && !_isExporting
                    ? _exportCSV
                    : null,
                icon: _isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.file_download),
                label: Text(
                  _isExporting
                      ? 'Exporting...'
                      : 'Export and Share CSV',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}