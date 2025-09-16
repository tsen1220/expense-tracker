import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/recurring_transaction.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../database/database_helper.dart';

class AddRecurringTransactionScreen extends StatefulWidget {
  final RecurringTransaction? recurringTransaction;

  const AddRecurringTransactionScreen({
    super.key,
    this.recurringTransaction,
  });

  @override
  State<AddRecurringTransactionScreen> createState() =>
      _AddRecurringTransactionScreenState();
}

class _AddRecurringTransactionScreenState extends State<AddRecurringTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  Category? _selectedCategory;
  RecurrenceFrequency _selectedFrequency = RecurrenceFrequency.monthly;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _hasEndDate = false;
  bool _isActive = true;

  List<Category> _availableCategories = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _initializeFields();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initializeFields() {
    if (widget.recurringTransaction != null) {
      final rt = widget.recurringTransaction!;
      _titleController.text = rt.title;
      _amountController.text = rt.amount.toString();
      _descriptionController.text = rt.description ?? '';
      _selectedType = rt.type;
      _selectedCategory = rt.category;
      _selectedFrequency = rt.frequency;
      _startDate = rt.startDate;
      _endDate = rt.endDate;
      _hasEndDate = rt.endDate != null;
      _isActive = rt.isActive;
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);

    try {
      final categories = await DatabaseHelper.instance.getCategoriesByType(
        isIncomeCategory: _selectedType == TransactionType.income,
      );

      setState(() {
        _availableCategories = categories;
        if (_selectedCategory == null && categories.isNotEmpty) {
          _selectedCategory = categories.first;
        } else if (_selectedCategory != null) {
          // Ensure selected category is still valid for the new type
          final validCategory = categories.firstWhere(
            (cat) => cat.id == _selectedCategory!.id,
            orElse: () => categories.first,
          );
          _selectedCategory = validCategory;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading categories: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onTypeChanged(TransactionType? type) {
    if (type != null && type != _selectedType) {
      setState(() {
        _selectedType = type;
        _selectedCategory = null;
      });
      _loadCategories();
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, clear it
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 365)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  DateTime _calculateNextDueDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDay = DateTime(_startDate.year, _startDate.month, _startDate.day);

    // If start date is in the future, use it as next due date
    if (startDay.isAfter(today)) {
      return startDay;
    }

    // Calculate next occurrence based on frequency
    DateTime nextDue = startDay;
    while (nextDue.isBefore(today) || nextDue.isAtSameMomentAs(today)) {
      switch (_selectedFrequency) {
        case RecurrenceFrequency.daily:
          nextDue = nextDue.add(const Duration(days: 1));
          break;
        case RecurrenceFrequency.weekly:
          nextDue = nextDue.add(const Duration(days: 7));
          break;
        case RecurrenceFrequency.monthly:
          if (nextDue.month == 12) {
            nextDue = DateTime(nextDue.year + 1, 1, nextDue.day);
          } else {
            try {
              nextDue = DateTime(nextDue.year, nextDue.month + 1, nextDue.day);
            } catch (e) {
              // Handle edge case for dates like Feb 30 -> Feb 28/29
              nextDue = DateTime(nextDue.year, nextDue.month + 2, 0);
            }
          }
          break;
        case RecurrenceFrequency.yearly:
          nextDue = DateTime(nextDue.year + 1, nextDue.month, nextDue.day);
          break;
      }
    }

    return nextDue;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final amount = double.parse(_amountController.text);
      final nextDueDate = _calculateNextDueDate();

      final recurringTransaction = RecurringTransaction(
        id: widget.recurringTransaction?.id,
        title: _titleController.text.trim(),
        amount: amount,
        category: _selectedCategory!,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        type: _selectedType,
        frequency: _selectedFrequency,
        startDate: _startDate,
        endDate: _hasEndDate ? _endDate : null,
        nextDueDate: nextDueDate,
        lastExecutedDate: widget.recurringTransaction?.lastExecutedDate,
        isActive: _isActive,
      );

      if (widget.recurringTransaction == null) {
        await DatabaseHelper.instance.insertRecurringTransaction(recurringTransaction);
      } else {
        await DatabaseHelper.instance.updateRecurringTransaction(recurringTransaction);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recurringTransaction != null;
    final dateFormatter = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Recurring Transaction' : 'Add Recurring Transaction'),
        actions: [
          if (_isSaving)
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
              onPressed: _save,
              child: Text(isEditing ? 'Update' : 'Save'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Transaction Type
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Transaction Type',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<TransactionType>(
                                  title: const Text('Expense'),
                                  value: TransactionType.expense,
                                  groupValue: _selectedType,
                                  onChanged: _onTypeChanged,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<TransactionType>(
                                  title: const Text('Income'),
                                  value: TransactionType.income,
                                  groupValue: _selectedType,
                                  onChanged: _onTypeChanged,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Amount
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Category
                  DropdownButtonFormField<Category>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _availableCategories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: category.color,
                              child: Icon(
                                category.icon,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
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
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Frequency
                  DropdownButtonFormField<RecurrenceFrequency>(
                    value: _selectedFrequency,
                    decoration: const InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.schedule),
                    ),
                    items: RecurrenceFrequency.values.map((frequency) {
                      return DropdownMenuItem(
                        value: frequency,
                        child: Text(frequency.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedFrequency = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Start Date
                  ListTile(
                    leading: const Icon(Icons.event),
                    title: const Text('Start Date'),
                    subtitle: Text(dateFormatter.format(_startDate)),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: _selectStartDate,
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // End Date Toggle and Selection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SwitchListTile(
                            title: const Text('Set End Date'),
                            subtitle: const Text('Leave off for indefinite recurring'),
                            value: _hasEndDate,
                            onChanged: (value) {
                              setState(() {
                                _hasEndDate = value;
                                if (!value) {
                                  _endDate = null;
                                }
                              });
                            },
                          ),
                          if (_hasEndDate) ...[
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.event),
                              title: const Text('End Date'),
                              subtitle: Text(
                                _endDate != null
                                    ? dateFormatter.format(_endDate!)
                                    : 'Select end date',
                              ),
                              trailing: const Icon(Icons.keyboard_arrow_right),
                              onTap: _selectEndDate,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 16),

                  // Active Status
                  if (isEditing)
                    Card(
                      child: SwitchListTile(
                        title: const Text('Active'),
                        subtitle: const Text('Enable/disable this recurring transaction'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Preview
                  Card(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Preview',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('Next due: ${dateFormatter.format(_calculateNextDueDate())}'),
                          Text('Frequency: ${_selectedFrequency.description}'),
                          if (_hasEndDate && _endDate != null)
                            Text('Until: ${dateFormatter.format(_endDate!)}'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}