import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction; // null for add, not null for edit
  final TransactionType initialType;

  const AddTransactionScreen({
    super.key,
    this.transaction,
    this.initialType = TransactionType.expense,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  late TabController _tabController;
  TransactionType _selectedType = TransactionType.expense;
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _selectedType == TransactionType.expense ? 0 : 1,
    );
    _tabController.addListener(_onTabChanged);
    
    _loadCategories();
    
    if (widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _descriptionController.text = widget.transaction!.description ?? '';
      _selectedCategory = widget.transaction!.category;
      _selectedDate = widget.transaction!.date;
      _selectedType = widget.transaction!.type;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {
      _selectedType = _tabController.index == 0
          ? TransactionType.expense
          : TransactionType.income;
      _selectedCategory = null; // Reset category when switching type

      // Set default category for the new type if available
      final newCategories = _selectedType == TransactionType.expense
          ? _expenseCategories
          : _incomeCategories;
      if (newCategories.isNotEmpty) {
        _selectedCategory = newCategories.first;
      }
    });
  }

  Future<void> _loadCategories() async {
    try {
      final expenseCategories = await DatabaseHelper.instance
          .getCategoriesByType(isIncomeCategory: false);
      final incomeCategories = await DatabaseHelper.instance
          .getCategoriesByType(isIncomeCategory: true);

      setState(() {
        _expenseCategories = expenseCategories;
        _incomeCategories = incomeCategories;

        // Set default category if not already set (for new transactions)
        if (_selectedCategory == null) {
          final currentCategories = _selectedType == TransactionType.expense
              ? expenseCategories
              : incomeCategories;
          if (currentCategories.isNotEmpty) {
            _selectedCategory = currentCategories.first;
          }
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading categories: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final transaction = Transaction(
        id: widget.transaction?.id,
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        category: _selectedCategory!,
        date: _selectedDate,
        description: _descriptionController.text.isEmpty 
            ? null 
            : _descriptionController.text,
        type: _selectedType,
      );

      if (widget.transaction == null) {
        await DatabaseHelper.instance.insertTransaction(transaction);
      } else {
        await DatabaseHelper.instance.updateTransaction(transaction);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving transaction: $e')),
        );
      }
    }
  }

  List<Category> get _currentCategories {
    return _selectedType == TransactionType.expense
        ? _expenseCategories
        : _incomeCategories;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
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
              onPressed: _saveTransaction,
              child: Text(isEditing ? 'Update' : 'Save'),
            ),
        ],
        bottom: isEditing ? null : TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Expense', icon: Icon(Icons.trending_down)),
            Tab(text: 'Income', icon: Icon(Icons.trending_up)),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (isEditing) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        _selectedType == TransactionType.expense
                            ? Icons.trending_down
                            : Icons.trending_up,
                        color: _selectedType == TransactionType.expense
                            ? Colors.red
                            : Colors.green,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedType == TransactionType.expense
                            ? 'Expense Transaction'
                            : 'Income Transaction',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g., Lunch at restaurant',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: '0.00',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
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
            const SizedBox(height: 16),
            
            DropdownButtonFormField<Category>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              hint: const Text('Select a category'),
              items: _currentCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          category.icon,
                          color: category.color,
                          size: 18,
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
              validator: (value) {
                if (value == null) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat.yMMMd().format(_selectedDate),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Add notes about this transaction',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            
            if (_selectedCategory != null) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preview',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _selectedCategory!.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _selectedCategory!.icon,
                              color: _selectedCategory!.color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _titleController.text.isNotEmpty
                                      ? _titleController.text
                                      : 'Transaction Title',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  _selectedCategory!.displayName,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  DateFormat.yMMMd().format(_selectedDate),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _selectedType == TransactionType.expense ? '-' : '+',
                                style: TextStyle(
                                  color: _selectedType == TransactionType.expense
                                      ? Colors.red
                                      : Colors.green,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${_amountController.text.isNotEmpty ? _amountController.text : '0.00'}',
                                style: TextStyle(
                                  color: _selectedType == TransactionType.expense
                                      ? Colors.red
                                      : Colors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}