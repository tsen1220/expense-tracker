import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MultiMonthPicker extends StatefulWidget {
  final List<DateTime> selectedMonths;
  final Function(List<DateTime>) onSelectionChanged;
  final DateTime? earliestMonth;
  final DateTime? latestMonth;

  const MultiMonthPicker({
    super.key,
    required this.selectedMonths,
    required this.onSelectionChanged,
    this.earliestMonth,
    this.latestMonth,
  });

  @override
  State<MultiMonthPicker> createState() => _MultiMonthPickerState();
}

class _MultiMonthPickerState extends State<MultiMonthPicker> {
  late List<DateTime> _selectedMonths;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedMonths = List.from(widget.selectedMonths);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  DateTime get _earliestAvailable {
    return widget.earliestMonth ?? DateTime(2020, 1);
  }

  DateTime get _latestAvailable {
    final now = DateTime.now();
    return widget.latestMonth ?? DateTime(now.year, now.month);
  }

  List<DateTime> _getAvailableMonths() {
    List<DateTime> months = [];
    DateTime current = _earliestAvailable;
    final latest = _latestAvailable;

    while (current.isBefore(latest) ||
           (current.year == latest.year && current.month == latest.month)) {
      months.add(DateTime(current.year, current.month));

      if (current.month == 12) {
        current = DateTime(current.year + 1, 1);
      } else {
        current = DateTime(current.year, current.month + 1);
      }
    }

    return months.reversed.toList(); // Most recent first
  }

  bool _isMonthSelected(DateTime month) {
    return _selectedMonths.any((selected) =>
        selected.year == month.year && selected.month == month.month);
  }

  void _toggleMonth(DateTime month) {
    setState(() {
      final isSelected = _isMonthSelected(month);

      if (isSelected) {
        _selectedMonths.removeWhere((selected) =>
            selected.year == month.year && selected.month == month.month);
      } else {
        _selectedMonths.add(month);
      }

      widget.onSelectionChanged(_selectedMonths);
    });
  }

  void _selectAll() {
    setState(() {
      _selectedMonths = List.from(_getAvailableMonths());
      widget.onSelectionChanged(_selectedMonths);
    });
  }

  void _clearAll() {
    setState(() {
      _selectedMonths.clear();
      widget.onSelectionChanged(_selectedMonths);
    });
  }

  void _selectCurrentYear() {
    final currentYear = DateTime.now().year;
    final yearMonths = _getAvailableMonths()
        .where((month) => month.year == currentYear)
        .toList();

    setState(() {
      // Remove current year months first
      _selectedMonths.removeWhere((month) => month.year == currentYear);
      // Add all current year months
      _selectedMonths.addAll(yearMonths);
      widget.onSelectionChanged(_selectedMonths);
    });
  }

  void _selectLastSixMonths() {
    final availableMonths = _getAvailableMonths();
    final lastSixMonths = availableMonths.take(6).toList();

    setState(() {
      _selectedMonths.clear();
      _selectedMonths.addAll(lastSixMonths);
      widget.onSelectionChanged(_selectedMonths);
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableMonths = _getAvailableMonths();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Selection summary and quick actions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Selected: ${_selectedMonths.length} month(s)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _QuickActionChip(
                    label: 'Last 6 months',
                    onTap: _selectLastSixMonths,
                    icon: Icons.schedule,
                  ),
                  _QuickActionChip(
                    label: 'This year',
                    onTap: _selectCurrentYear,
                    icon: Icons.calendar_today,
                  ),
                  _QuickActionChip(
                    label: 'Select all',
                    onTap: _selectAll,
                    icon: Icons.select_all,
                  ),
                  _QuickActionChip(
                    label: 'Clear all',
                    onTap: _clearAll,
                    icon: Icons.clear_all,
                    isDestructive: true,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Month selection grid
        Text(
          'Select months to export:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        SizedBox(
          height: 400,
          child: availableMonths.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No months available',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : Scrollbar(
                  controller: _scrollController,
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: availableMonths.length,
                    itemBuilder: (context, index) {
                      final month = availableMonths[index];
                      final isSelected = _isMonthSelected(month);

                      return _MonthTile(
                        month: month,
                        isSelected: isSelected,
                        onTap: () => _toggleMonth(month),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _MonthTile extends StatelessWidget {
  final DateTime month;
  final bool isSelected;
  final VoidCallback onTap;

  const _MonthTile({
    required this.month,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: isSelected ? 2 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('MMM').format(month),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(
                month.year.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer.withOpacity(0.8)
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData icon;
  final bool isDestructive;

  const _QuickActionChip({
    required this.label,
    required this.onTap,
    required this.icon,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ActionChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isDestructive
            ? theme.colorScheme.error
            : theme.colorScheme.primary,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isDestructive
              ? theme.colorScheme.error
              : theme.colorScheme.primary,
          fontSize: 12,
        ),
      ),
      onPressed: onTap,
      backgroundColor: isDestructive
          ? theme.colorScheme.errorContainer.withOpacity(0.3)
          : theme.colorScheme.primaryContainer.withOpacity(0.3),
      side: BorderSide(
        color: isDestructive
            ? theme.colorScheme.error.withOpacity(0.5)
            : theme.colorScheme.primary.withOpacity(0.5),
      ),
    );
  }
}