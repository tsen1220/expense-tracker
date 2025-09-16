import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../database/database_helper.dart';
import '../widgets/transaction_chart.dart';
import '../widgets/transaction_list.dart';
import '../widgets/budget_overview.dart';
import 'add_transaction_screen.dart';
import 'category_management_screen.dart';
import 'budget_management_screen.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<Transaction> _transactions = [];
  List<Budget> _activeBudgets = [];
  double _totalExpenses = 0.0;
  double _totalIncome = 0.0;
  double _netBalance = 0.0;
  DateTime _selectedMonth = DateTime.now();
  TransactionType _currentType = TransactionType.expense;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 0) {
      setState(() => _currentType = TransactionType.expense);
    } else {
      setState(() => _currentType = TransactionType.income);
    }
    _loadTransactions();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      await Future.wait([
        _loadTransactions(),
        _loadTotals(),
        _loadActiveBudgets(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTransactions() async {
    final transactions = await DatabaseHelper.instance.getTransactionsByMonth(
      _selectedMonth.year,
      _selectedMonth.month,
      type: _currentType,
    );
    
    setState(() {
      _transactions = transactions.cast<Transaction>();
    });
  }

  Future<void> _loadTotals() async {
    final expenses = await DatabaseHelper.instance.getTotalByMonth(
      _selectedMonth.year,
      _selectedMonth.month,
      TransactionType.expense,
    );
    
    final income = await DatabaseHelper.instance.getTotalByMonth(
      _selectedMonth.year,
      _selectedMonth.month,
      TransactionType.income,
    );
    
    setState(() {
      _totalExpenses = expenses;
      _totalIncome = income;
      _netBalance = income - expenses;
    });
  }

  Future<void> _loadActiveBudgets() async {
    final budgets = await DatabaseHelper.instance.getActiveBudgets();
    setState(() {
      _activeBudgets = budgets;
    });
  }

  Future<void> _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020, 1),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Tracker'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'categories':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoryManagementScreen(),
                    ),
                  );
                  break;
                case 'budgets':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BudgetManagementScreen(),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'categories',
                child: Row(
                  children: [
                    Icon(Icons.category),
                    SizedBox(width: 8),
                    Text('Manage Categories'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'budgets',
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet),
                    SizedBox(width: 8),
                    Text('Manage Budgets'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Month selector and summary
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: _selectMonth,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('MMMM yyyy').format(_selectedMonth),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Icon(Icons.calendar_month),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              color: Colors.green.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    const Icon(Icons.trending_up, color: Colors.green),
                                    const SizedBox(height: 4),
                                    const Text('Income', style: TextStyle(fontSize: 12)),
                                    Text(
                                      currencyFormatter.format(_totalIncome),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Card(
                              color: Colors.red.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    const Icon(Icons.trending_down, color: Colors.red),
                                    const SizedBox(height: 4),
                                    const Text('Expenses', style: TextStyle(fontSize: 12)),
                                    Text(
                                      currencyFormatter.format(_totalExpenses),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Card(
                              color: _netBalance >= 0 ? Colors.blue.shade50 : Colors.orange.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Icon(
                                      _netBalance >= 0 
                                          ? Icons.account_balance 
                                          : Icons.warning,
                                      color: _netBalance >= 0 ? Colors.blue : Colors.orange,
                                    ),
                                    const SizedBox(height: 4),
                                    const Text('Net', style: TextStyle(fontSize: 12)),
                                    Text(
                                      currencyFormatter.format(_netBalance),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _netBalance >= 0 ? Colors.blue : Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Budget overview
                if (_activeBudgets.isNotEmpty)
                  BudgetOverview(budgets: _activeBudgets),
                
                // Tab bar for income/expense
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Expenses', icon: Icon(Icons.trending_down)),
                    Tab(text: 'Income', icon: Icon(Icons.trending_up)),
                  ],
                ),
                
                // Content area
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTransactionView(TransactionType.expense),
                      _buildTransactionView(TransactionType.income),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionScreen(
                initialType: _currentType,
              ),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransactionView(TransactionType type) {
    final typeTransactions = _transactions.where((t) => t.type == type).toList();
    
    return Column(
      children: [
        // Chart section
        if (typeTransactions.isNotEmpty) ...[
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            child: TransactionChart(
              transactions: typeTransactions,
              type: type,
            ),
          ),
          const Divider(height: 1),
        ],
        
        // Transaction list
        Expanded(
          child: typeTransactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        type == TransactionType.expense
                            ? Icons.receipt_long
                            : Icons.account_balance_wallet,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        type == TransactionType.expense
                            ? 'No expenses yet'
                            : 'No income yet',
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the + button to start tracking',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : TransactionList(
                  transactions: typeTransactions,
                  onTransactionDeleted: () => _loadData(),
                ),
        ),
      ],
    );
  }
}