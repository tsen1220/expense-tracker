import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../database/database_helper.dart';

class BudgetOverview extends StatefulWidget {
  final List<Budget> budgets;

  const BudgetOverview({super.key, required this.budgets});

  @override
  State<BudgetOverview> createState() => _BudgetOverviewState();
}

class _BudgetOverviewState extends State<BudgetOverview> {
  Map<int, double> _budgetUsage = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBudgetUsage();
  }

  @override
  void didUpdateWidget(BudgetOverview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.budgets != oldWidget.budgets) {
      _loadBudgetUsage();
    }
  }

  Future<void> _loadBudgetUsage() async {
    setState(() => _isLoading = true);
    
    final Map<int, double> usage = {};
    for (final budget in widget.budgets) {
      if (budget.id != null) {
        usage[budget.id!] = await DatabaseHelper.instance.getBudgetUsage(budget);
      }
    }
    
    setState(() {
      _budgetUsage = usage;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.budgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Active Budgets',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ...widget.budgets.map((budget) => _buildBudgetItem(budget)),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetItem(Budget budget) {
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (budget.category != null) ...[
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: budget.category!.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    budget.category!.icon,
                    color: budget.category!.color,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    budget.category!.displayName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ] else ...[
                const Icon(Icons.account_balance_wallet, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Overall Budget',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
              Text(
                '${NumberFormat.currency(symbol: '\$').format(usage)} / ${NumberFormat.currency(symbol: '\$').format(budget.amount)}',
                style: Theme.of(context).textTheme.bodySmall,
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
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${usagePercentage.toStringAsFixed(1)}% used',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              if (isOverBudget)
                Text(
                  'Over by ${NumberFormat.currency(symbol: '\$').format(usage - budget.amount)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}