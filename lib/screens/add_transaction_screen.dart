import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../l10n/app_localizations.dart';

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
          SnackBar(content: Text(AppLocalizations.of(context)!.errorLoadingCategories(e.toString()))),
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
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectCategory)),
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
          SnackBar(content: Text(AppLocalizations.of(context)!.errorSavingTransaction(e.toString()))),
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
        title: Text(isEditing ? AppLocalizations.of(context)!.editTransaction : AppLocalizations.of(context)!.addTransaction),
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
              child: Text(isEditing ? AppLocalizations.of(context)!.update : AppLocalizations.of(context)!.save),
            ),
        ],
        bottom: isEditing ? null : TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.expense, icon: const Icon(Icons.trending_down)),
            Tab(text: AppLocalizations.of(context)!.income, icon: const Icon(Icons.trending_up)),
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
                            ? AppLocalizations.of(context)!.expenseTransaction
                            : AppLocalizations.of(context)!.incomeTransaction,
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
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.title,
                hintText: AppLocalizations.of(context)!.titleHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.pleaseEnterTitle;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.amount,
                hintText: AppLocalizations.of(context)!.amountHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.pleaseEnterAmount;
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return AppLocalizations.of(context)!.pleaseEnterValidAmount;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<Category>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.category,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.category),
              ),
              hint: Text(AppLocalizations.of(context)!.selectCategory),
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
                  return AppLocalizations.of(context)!.pleaseSelectCategory;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.date,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat.yMMMd().format(_selectedDate),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.descriptionOptional,
                hintText: AppLocalizations.of(context)!.addNotesHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}