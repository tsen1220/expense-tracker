import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/recurring_transaction.dart';
import '../models/transaction.dart';
import '../database/database_helper.dart';
import 'add_recurring_transaction_screen.dart';

class RecurringTransactionManagementScreen extends StatefulWidget {
  const RecurringTransactionManagementScreen({super.key});

  @override
  State<RecurringTransactionManagementScreen> createState() =>
      _RecurringTransactionManagementScreenState();
}

class _RecurringTransactionManagementScreenState
    extends State<RecurringTransactionManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<RecurringTransaction> _expenseRecurring = [];
  List<RecurringTransaction> _incomeRecurring = [];
  List<RecurringTransaction> _dueTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final allRecurring = await DatabaseHelper.instance.getAllRecurringTransactions();
      final dueRecurring = await DatabaseHelper.instance.getDueRecurringTransactions();

      setState(() {
        _expenseRecurring = allRecurring
            .where((rt) => rt.type == TransactionType.expense)
            .toList();
        _incomeRecurring = allRecurring
            .where((rt) => rt.type == TransactionType.income)
            .toList();
        _dueTransactions = dueRecurring;
      });
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

  Future<void> _executeRecurringTransaction(RecurringTransaction recurringTransaction) async {
    try {
      await DatabaseHelper.instance.executeRecurringTransaction(recurringTransaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Executed: ${recurringTransaction.title}'),
            backgroundColor: Colors.green,
          ),
        );
      }

      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error executing transaction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleRecurringTransactionStatus(RecurringTransaction recurringTransaction) async {
    try {
      final updated = recurringTransaction.copyWith(
        isActive: !recurringTransaction.isActive,
      );

      await DatabaseHelper.instance.updateRecurringTransaction(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updated.isActive ? 'Activated: ${updated.title}' : 'Deactivated: ${updated.title}'
            ),
          ),
        );
      }

      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating transaction: $e')),
        );
      }
    }
  }

  Future<void> _deleteRecurringTransaction(RecurringTransaction recurringTransaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recurring Transaction'),
        content: Text('Are you sure you want to delete "${recurringTransaction.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseHelper.instance.deleteRecurringTransaction(recurringTransaction.id!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deleted: ${recurringTransaction.title}')),
          );
        }

        _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting transaction: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Transactions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Due Now',
              icon: Badge(
                label: Text(_dueTransactions.length.toString()),
                child: const Icon(Icons.notification_important),
              ),
            ),
            const Tab(text: 'Expenses', icon: Icon(Icons.trending_down)),
            const Tab(text: 'Income', icon: Icon(Icons.trending_up)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDueTransactionsList(),
                _buildRecurringTransactionsList(_expenseRecurring, TransactionType.expense),
                _buildRecurringTransactionsList(_incomeRecurring, TransactionType.income),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const AddRecurringTransactionScreen(),
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

  Widget _buildDueTransactionsList() {
    if (_dueTransactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'All caught up!',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'No recurring transactions are due',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_dueTransactions.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border.all(color: Colors.orange),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_dueTransactions.length} recurring transaction(s) are due',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await DatabaseHelper.instance.processAllDueRecurringTransactions();
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
          ),
        Expanded(
          child: ListView.builder(
            itemCount: _dueTransactions.length,
            itemBuilder: (context, index) {
              final recurringTransaction = _dueTransactions[index];
              return _buildRecurringTransactionCard(
                recurringTransaction,
                isDue: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecurringTransactionsList(List<RecurringTransaction> transactions, TransactionType type) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == TransactionType.expense ? Icons.receipt_long : Icons.account_balance_wallet,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              type == TransactionType.expense
                  ? 'No recurring expenses'
                  : 'No recurring income',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const Text(
              'Tap the + button to create one',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final recurringTransaction = transactions[index];
        return _buildRecurringTransactionCard(recurringTransaction);
      },
    );
  }

  Widget _buildRecurringTransactionCard(RecurringTransaction recurringTransaction, {bool isDue = false}) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$');
    final dateFormatter = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isDue ? Colors.orange.shade50 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: recurringTransaction.category.color,
          child: Icon(
            recurringTransaction.category.icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                recurringTransaction.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: recurringTransaction.isActive ? null : TextDecoration.lineThrough,
                  color: recurringTransaction.isActive ? null : Colors.grey,
                ),
              ),
            ),
            if (isDue)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'DUE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (!recurringTransaction.isActive && !isDue)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'INACTIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${recurringTransaction.category.displayName} • ${recurringTransaction.frequency.displayName}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Next: ${dateFormatter.format(recurringTransaction.nextDueDate)}',
              style: TextStyle(
                fontSize: 12,
                color: isDue ? Colors.red : Colors.grey[600],
                fontWeight: isDue ? FontWeight.bold : null,
              ),
            ),
            if (recurringTransaction.lastExecutedDate != null)
              Text(
                'Last: ${dateFormatter.format(recurringTransaction.lastExecutedDate!)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormatter.format(recurringTransaction.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: recurringTransaction.isExpense ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'execute':
                    _executeRecurringTransaction(recurringTransaction);
                    break;
                  case 'toggle':
                    _toggleRecurringTransactionStatus(recurringTransaction);
                    break;
                  case 'edit':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddRecurringTransactionScreen(
                          recurringTransaction: recurringTransaction,
                        ),
                      ),
                    ).then((result) {
                      if (result == true) _loadData();
                    });
                    break;
                  case 'delete':
                    _deleteRecurringTransaction(recurringTransaction);
                    break;
                }
              },
              itemBuilder: (context) => [
                if (recurringTransaction.isActive)
                  const PopupMenuItem(
                    value: 'execute',
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow),
                        SizedBox(width: 8),
                        Text('Execute Now'),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(recurringTransaction.isActive ? Icons.pause : Icons.play_arrow),
                      const SizedBox(width: 8),
                      Text(recurringTransaction.isActive ? 'Deactivate' : 'Activate'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: isDue && recurringTransaction.isActive
            ? () => _executeRecurringTransaction(recurringTransaction)
            : null,
      ),
    );
  }
}