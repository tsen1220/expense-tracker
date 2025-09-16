import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/budget.dart';
import 'add_budget_screen.dart';

class BudgetManagementScreen extends StatefulWidget {
  const BudgetManagementScreen({super.key});

  @override
  State<BudgetManagementScreen> createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends State<BudgetManagementScreen> {
  List<Budget> _budgets = [];
  Map<int, double> _budgetUsage = {};
  bool _isLoading = true;
  final _currencyFormatter = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    setState(() => _isLoading = true);
    
    try {
      final budgets = await DatabaseHelper.instance.getAllBudgets();
      final Map<int, double> usage = {};
      
      for (final budget in budgets) {
        if (budget.id != null) {
          usage[budget.id!] = await DatabaseHelper.instance.getBudgetUsage(budget);
        }
      }
      
      setState(() {
        _budgets = budgets;
        _budgetUsage = usage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading budgets: $e')),
        );
      }
    }
  }

  Future<void> _deleteBudget(Budget budget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text(
          'Are you sure you want to delete this budget?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && budget.id != null) {
      try {
        await DatabaseHelper.instance.deleteBudget(budget.id!);
        await _loadBudgets();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Budget deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete budget: $e')),
          );
        }
      }
    }
  }

  Widget _buildBudgetCard(Budget budget) {
    final usage = _budgetUsage[budget.id] ?? 0.0;
    final usagePercentage = budget.amount > 0 ? (usage / budget.amount) * 100 : 0.0;
    final isOverBudget = usage > budget.amount;
    
    Color progressColor;
    if (usagePercentage <= 50) {
      progressColor = Colors.green;
    } else if (usagePercentage <= 80) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (budget.category != null) ...[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: budget.category!.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      budget.category!.icon,
                      color: budget.category!.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                ] else ...[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.isOverallBudget 
                            ? 'Overall Budget' 
                            : budget.category!.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${DateFormat.MMMd().format(budget.startDate)} - ${DateFormat.MMMd().format(budget.endDate)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
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
                  onSelected: (value) async {
                    switch (value) {
                      case 'edit':
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddBudgetScreen(budget: budget),
                          ),
                        );
                        if (result == true) {
                          await _loadBudgets();
                        }
                        break;
                      case 'delete':
                        await _deleteBudget(budget);
                        break;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget: ${_currencyFormatter.format(budget.amount)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Spent: ${_currencyFormatter.format(usage)}',
                  style: TextStyle(
                    color: isOverBudget ? Colors.red : null,
                    fontWeight: isOverBudget ? FontWeight.bold : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (usagePercentage / 100).clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${usagePercentage.toStringAsFixed(1)}% used',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Remaining: ${_currencyFormatter.format((budget.amount - usage).clamp(0.0, double.infinity))}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (isOverBudget) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Over budget by ${_currencyFormatter.format(usage - budget.amount)}',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
            if (!budget.isCurrentlyActive) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, color: Colors.grey, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Inactive',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _budgets.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No budgets found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Create your first budget to start tracking your spending',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBudgets,
                  child: ListView.builder(
                    itemCount: _budgets.length,
                    itemBuilder: (context, index) {
                      return _buildBudgetCard(_budgets[index]);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const AddBudgetScreen(),
            ),
          );
          if (result == true) {
            await _loadBudgets();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}