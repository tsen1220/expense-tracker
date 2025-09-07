import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthYearPicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDateChanged;

  const MonthYearPicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateChanged,
  });

  @override
  State<MonthYearPicker> createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<MonthYearPicker> {
  late int selectedYear;
  late int selectedMonth;
  bool showingYears = true;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 300,
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 標題列
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                Text(
                  showingYears ? 'Select Year' : 'Select Month',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: showingYears ? null : () {
                    final selectedDate = DateTime(selectedYear, selectedMonth);
                    widget.onDateChanged(selectedDate);
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
            const Divider(),
            
            // 當前選擇顯示
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                showingYears 
                  ? selectedYear.toString()
                  : DateFormat('MMMM yyyy').format(DateTime(selectedYear, selectedMonth)),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            
            // 選擇器內容
            Expanded(
              child: showingYears ? _buildYearSelector() : _buildMonthSelector(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearSelector() {
    final years = List.generate(
      widget.lastDate.year - widget.firstDate.year + 1,
      (index) => widget.firstDate.year + index,
    );

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2,
      ),
      itemCount: years.length,
      itemBuilder: (context, index) {
        final year = years[index];
        final isSelected = year == selectedYear;
        
        return InkWell(
          onTap: () {
            setState(() {
              selectedYear = year;
              showingYears = false;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected 
                  ? Theme.of(context).colorScheme.primary 
                  : Colors.grey.shade300,
              ),
            ),
            child: Center(
              child: Text(
                year.toString(),
                style: TextStyle(
                  color: isSelected 
                    ? Colors.white 
                    : Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthSelector() {
    final months = List.generate(12, (index) => index + 1);
    
    return Column(
      children: [
        // 返回年份選擇按鈕
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                setState(() {
                  showingYears = true;
                });
              },
              icon: const Icon(Icons.chevron_left),
              label: Text(selectedYear.toString()),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // 月份網格
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2,
            ),
            itemCount: months.length,
            itemBuilder: (context, index) {
              final month = months[index];
              final isSelected = month == selectedMonth;
              
              return InkWell(
                onTap: () {
                  setState(() {
                    selectedMonth = month;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? Theme.of(context).colorScheme.primary 
                      : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected 
                        ? Theme.of(context).colorScheme.primary 
                        : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      DateFormat('MMM').format(DateTime(2024, month)),
                      style: TextStyle(
                        color: isSelected 
                          ? Colors.white 
                          : Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}