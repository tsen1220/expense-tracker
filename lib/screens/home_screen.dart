import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../database/database_helper.dart';
import '../widgets/expense_chart.dart';
import '../widgets/expense_list.dart';
import '../widgets/month_year_picker.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> expenses = [];
  List<Expense> allExpenses = []; // 存儲完整月份資料用於圖表
  double totalExpenses = 0.0;
  DateTime selectedMonth = DateTime.now();
  List<DateTime> availableMonths = [];
  
  // 分頁相關變數
  int currentPage = 0;
  int pageSize = 20;
  int totalCount = 0;
  int totalPages = 0;

  @override
  void initState() {
    super.initState();
    _generateMonthList();
    _loadExpenses();
  }

  void _generateMonthList() {
    // 設置初始月份為當前月份
    final now = DateTime.now();
    selectedMonth = DateTime(now.year, now.month);
  }

  Future<void> _selectMonth(BuildContext context) async {
    await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return MonthYearPicker(
          initialDate: selectedMonth,
          firstDate: DateTime(2020, 1),
          lastDate: DateTime.now(),
          onDateChanged: (DateTime picked) {
            setState(() {
              selectedMonth = DateTime(picked.year, picked.month);
              currentPage = 0; // 重置分頁
            });
            _loadExpenses();
          },
        );
      },
    );
  }

  Future<void> _loadExpenses() async {
    // 載入分頁資料
    final loadedExpenses = await DatabaseHelper.instance.getExpensesByMonthPaginated(
      selectedMonth.year,
      selectedMonth.month,
      currentPage,
      pageSize,
    );
    
    // 載入完整月份資料用於圖表
    final allMonthExpenses = await DatabaseHelper.instance.getExpensesByMonth(
      selectedMonth.year,
      selectedMonth.month,
    );
    
    // 載入總計和總數
    final total = await DatabaseHelper.instance.getTotalExpensesByMonth(
      selectedMonth.year,
      selectedMonth.month,
    );
    
    final count = await DatabaseHelper.instance.getExpensesCountByMonth(
      selectedMonth.year,
      selectedMonth.month,
    );

    setState(() {
      expenses = loadedExpenses;
      allExpenses = allMonthExpenses;
      totalExpenses = total;
      totalCount = count;
      totalPages = (count / pageSize).ceil();
    });
  }


  void _goToPage(int page) {
    if (page >= 0 && page < totalPages) {
      setState(() {
        currentPage = page;
      });
      _loadExpenses();
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      _goToPage(currentPage - 1);
    }
  }

  void _nextPage() {
    if (currentPage < totalPages - 1) {
      _goToPage(currentPage + 1);
    }
  }

  void _addExpense() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
    );
    // 新增後重置到第一頁
    setState(() {
      currentPage = 0;
    });
    _loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 月份選擇器
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(
              context,
            ).colorScheme.inversePrimary.withOpacity(0.1),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _selectMonth(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Month',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMMM yyyy').format(selectedMonth),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.calendar_month,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Total: \$${totalExpenses.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          // 圓餅圖區域 (固定高度)
          if (allExpenses.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              height: 200,
              child: ExpenseChart(expenses: allExpenses),
            ),
            const SizedBox(height: 16),
          ],
          
          // 列表區域 (佔剩餘空間)
          Expanded(
            child: expenses.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No expenses yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the + button to start tracking',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // 列表區域
                      Expanded(
                        child: ExpenseList(
                          expenses: expenses,
                          onExpenseDeleted: () {
                            // 刪除後可能需要調整頁數
                            if (expenses.length == 1 && currentPage > 0) {
                              setState(() {
                                currentPage = currentPage - 1;
                              });
                            }
                            _loadExpenses();
                          },
                        ),
                      ),
                      // 分頁控制器 (固定在底部)
                      if (totalPages > 1)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 分頁資訊
                              Flexible(
                                child: Text(
                                  'Page ${currentPage + 1} of $totalPages (Total: $totalCount)',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // 分頁按鈕
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: currentPage > 0 ? _previousPage : null,
                                    icon: const Icon(Icons.chevron_left),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text('${currentPage + 1}'),
                                  ),
                                  IconButton(
                                    onPressed: currentPage < totalPages - 1 ? _nextPage : null,
                                    icon: const Icon(Icons.chevron_right),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        child: const Icon(Icons.add),
      ),
    );
  }
}
