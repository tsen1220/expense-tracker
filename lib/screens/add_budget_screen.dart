import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/budget.dart';
import '../models/category.dart';

class AddBudgetScreen extends StatefulWidget {
  final Budget? budget; // null for add, not null for edit

  const AddBudgetScreen({super.key, this.budget});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  
  Category? _selectedCategory;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _isOverallBudget = false;
  bool _isActive = true;
  bool _isLoading = false;
  List<Category> _expenseCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    
    if (widget.budget != null) {
      _amountController.text = widget.budget!.amount.toString();
      _selectedCategory = widget.budget!.category;
      _startDate = widget.budget!.startDate;
      _endDate = widget.budget!.endDate;
      _isOverallBudget = widget.budget!.isOverallBudget;
      _isActive = widget.budget!.isActive;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await DatabaseHelper.instance
          .getCategoriesByType(isIncomeCategory: false);
      setState(() {
        _expenseCategories = categories;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading categories: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isOverallBudget && _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final budget = Budget(
        id: widget.budget?.id,
        category: _isOverallBudget ? null : _selectedCategory,
        amount: double.parse(_amountController.text),
        startDate: _startDate,
        endDate: _endDate,
        isActive: _isActive,
      );

      if (widget.budget == null) {
        await DatabaseHelper.instance.insertBudget(budget);
      } else {
        await DatabaseHelper.instance.updateBudget(budget);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving budget: $e')),
        );
      }
    }
  }

  void _setPresetPeriod(String preset) {
    final now = DateTime.now();
    
    switch (preset) {
      case 'this_month':
        setState(() {
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month + 1, 1)
              .subtract(const Duration(days: 1));
        });
        break;
      case 'next_month':
        setState(() {
          _startDate = DateTime(now.year, now.month + 1, 1);
          _endDate = DateTime(now.year, now.month + 2, 1)
              .subtract(const Duration(days: 1));
        });
        break;
      case '3_months':
        setState(() {
          _startDate = now;
          _endDate = now.add(const Duration(days: 90));
        });
        break;
      case '6_months':
        setState(() {
          _startDate = now;
          _endDate = now.add(const Duration(days: 180));
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.budget != null;
    final dateFormat = DateFormat.yMMMd();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Budget' : 'Add Budget'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveBudget,
              child: Text(isEditing ? 'Update' : 'Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget Type',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    RadioListTile<bool>(
                      title: const Text('Overall Budget'),
                      subtitle: const Text('Budget for all expenses'),
                      value: true,
                      groupValue: _isOverallBudget,
                      onChanged: (value) {
                        setState(() {
                          _isOverallBudget = value ?? false;
                          if (_isOverallBudget) {
                            _selectedCategory = null;
                          }
                        });
                      },
                    ),
                    RadioListTile<bool>(
                      title: const Text('Category Budget'),
                      subtitle: const Text('Budget for specific category'),
                      value: false,
                      groupValue: _isOverallBudget,
                      onChanged: (value) {
                        setState(() {
                          _isOverallBudget = !(value ?? true);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (!_isOverallBudget) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Category',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Category>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Choose a category',
                        ),
                        items: _expenseCategories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: category.color.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    category.icon,
                                    color: category.color,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(category.displayName),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        validator: !_isOverallBudget ? (value) {
                          if (value == null) {
                            return 'Please select a category';
                          }
                          return null;
                        } : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget Amount',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget Period',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Start Date'),
                            subtitle: Text(dateFormat.format(_startDate)),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => _selectDate(true),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text('End Date'),
                            subtitle: Text(dateFormat.format(_endDate)),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => _selectDate(false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Quick Presets',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('This Month'),
                          onSelected: (_) => _setPresetPeriod('this_month'),
                        ),
                        FilterChip(
                          label: const Text('Next Month'),
                          onSelected: (_) => _setPresetPeriod('next_month'),
                        ),
                        FilterChip(
                          label: const Text('3 Months'),
                          onSelected: (_) => _setPresetPeriod('3_months'),
                        ),
                        FilterChip(
                          label: const Text('6 Months'),
                          onSelected: (_) => _setPresetPeriod('6_months'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Budget is currently active'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}