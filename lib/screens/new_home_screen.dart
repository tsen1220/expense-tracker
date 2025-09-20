import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/recurring_transaction.dart';
import '../database/database_helper.dart';
import '../widgets/transaction_chart.dart';
import '../widgets/transaction_list.dart';
import '../widgets/budget_overview.dart';
import '../services/recurring_transaction_service.dart';
import 'add_transaction_screen.dart';
import 'category_management_screen.dart';
import 'budget_management_screen.dart';
import 'recurring_transaction_management_screen.dart';
import 'export_screen.dart';

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
  List<RecurringTransaction> _dueRecurringTransactions = [];
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

    // Set up recurring transaction service callback
    RecurringTransactionService.instance.setOnTransactionsProcessedCallback(_loadData);
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
        _loadDueRecurringTransactions(),
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

  Future<void> _loadDueRecurringTransactions() async {
    final dueTransactions = await RecurringTransactionService.instance.getDueTransactions();
    setState(() {
      _dueRecurringTransactions = dueTransactions;
    });
  }

  Future<void> _selectMonth() async {
    await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return _DatePickerPopup(
          selectedDate: _selectedMonth,
          onDateSelected: (DateTime selectedDate) {
            setState(() {
              _selectedMonth = DateTime(selectedDate.year, selectedDate.month);
            });
            _loadData();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$');
    
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
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
                case 'recurring':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecurringTransactionManagementScreen(),
                    ),
                  ).then((_) => _loadData());
                  break;
                case 'export':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExportScreen(),
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
              PopupMenuItem(
                value: 'recurring',
                child: Row(
                  children: [
                    Badge(
                      label: Text(_dueRecurringTransactions.length.toString()),
                      isLabelVisible: _dueRecurringTransactions.isNotEmpty,
                      child: const Icon(Icons.repeat),
                    ),
                    const SizedBox(width: 8),
                    const Text('Recurring Transactions'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('Export Data'),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: _selectMonth,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('MMMM yyyy').format(_selectedMonth),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Icon(Icons.calendar_month, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              color: Colors.green.shade50,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.trending_up, color: Colors.green, size: 16),
                                    const SizedBox(height: 2),
                                    Text('Income', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        currencyFormatter.format(_totalIncome),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Card(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              color: Colors.red.shade50,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.trending_down, color: Colors.red, size: 16),
                                    const SizedBox(height: 2),
                                    Text('Expenses', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        currencyFormatter.format(_totalExpenses),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Card(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              color: _netBalance >= 0 ? Colors.blue.shade50 : Colors.orange.shade50,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _netBalance >= 0
                                          ? Icons.account_balance
                                          : Icons.warning,
                                      color: _netBalance >= 0 ? Colors.blue : Colors.orange,
                                      size: 16,
                                    ),
                                    const SizedBox(height: 2),
                                    Text('Net', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        currencyFormatter.format(_netBalance),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _netBalance >= 0 ? Colors.blue : Colors.orange,
                                          fontSize: 12,
                                        ),
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

                // Due recurring transactions notification
                if (_dueRecurringTransactions.isNotEmpty)
                  _buildDueRecurringTransactionsNotification(),

                // Tab bar for income/expense
                Material(
                  child: TabBar(
                    controller: _tabController,
                    labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
                    tabAlignment: TabAlignment.fill,
                    tabs: [
                      Tab(
                        text: 'Expenses',
                        icon: Icon(Icons.trending_down, size: 16),
                        height: 40,
                      ),
                      Tab(
                        text: 'Income',
                        icon: Icon(Icons.trending_up, size: 16),
                        height: 40,
                      ),
                    ],
                  ),
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
            height: 140,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildDueRecurringTransactionsNotification() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.notification_important, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_dueRecurringTransactions.length} recurring transaction(s) due',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await RecurringTransactionService.instance.processAllDueRecurringTransactions();
                      _loadData();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All due transactions processed'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    child: const Text('Execute All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _dueRecurringTransactions.length,
                  itemBuilder: (context, index) {
                    final rt = _dueRecurringTransactions[index];
                    final currencyFormatter = NumberFormat.currency(symbol: '\$');

                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 8),
                      child: Card(
                        child: InkWell(
                          onTap: () async {
                            await RecurringTransactionService.instance.executeRecurringTransaction(rt);
                            _loadData();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Executed: ${rt.title}'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: rt.category.color,
                                      child: Icon(
                                        rt.category.icon,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        rt.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currencyFormatter.format(rt.amount),
                                  style: TextStyle(
                                    color: rt.isExpense ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  rt.frequency.displayName,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecurringTransactionManagementScreen(),
                      ),
                    ).then((_) => _loadData());
                  },
                  icon: const Icon(Icons.manage_accounts),
                  label: const Text('Manage All'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePickerPopup extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const _DatePickerPopup({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<_DatePickerPopup> createState() => _DatePickerPopupState();
}

class _DatePickerPopupState extends State<_DatePickerPopup> {
  late int _selectedYear;
  int? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.selectedDate.year;
    _selectedMonth = widget.selectedDate.month;
  }

  List<int> get _availableYears {
    final currentYear = DateTime.now().year;
    final years = <int>[];

    // Start from current year and go backwards
    for (int year = currentYear; year >= 2020; year--) {
      years.add(year);
    }

    return years;
  }

  void _onYearChanged(int year) {
    setState(() {
      _selectedYear = year;
    });
  }

  void _onMonthSelected(int month) {
    setState(() {
      _selectedMonth = month;
    });

    final selectedDate = DateTime(_selectedYear, month);
    widget.onDateSelected(selectedDate);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        width: 360,
        height: 420,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Date',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Year dropdown
            Text(
              'Year:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedYear,
                  isExpanded: true,
                  items: _availableYears.map((year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(
                        year.toString(),
                        style: theme.textTheme.bodyLarge,
                      ),
                    );
                  }).toList(),
                  onChanged: (year) {
                    if (year != null) {
                      _onYearChanged(year);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Month grid
            Text(
              'Month:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            // 12 month grid (4x3)
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final isSelected = _selectedMonth == month;

                  return Material(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () => _onMonthSelected(month),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          DateFormat('MMM').format(DateTime(_selectedYear, month)),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Current selection info
            if (_selectedMonth != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Selected: ${DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth!))}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}