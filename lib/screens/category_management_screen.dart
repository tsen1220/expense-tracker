import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/category.dart';
import '../l10n/app_localizations.dart';
import 'add_category_screen.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    
    try {
      final expenseCategories = await DatabaseHelper.instance
          .getCategoriesByType(isIncomeCategory: false);
      final incomeCategories = await DatabaseHelper.instance
          .getCategoriesByType(isIncomeCategory: true);
      
      setState(() {
        _expenseCategories = expenseCategories;
        _incomeCategories = incomeCategories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorLoadingCategories(e.toString()))),
        );
      }
    }
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.delete),
        content: Text(
          AppLocalizations.of(context)!.deleteConfirmCategory(category.displayName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && category.id != null) {
      try {
        await DatabaseHelper.instance.deleteCategory(category.id!);
        await _loadCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.categoryDeletedSuccess)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.failedToDeleteCategoryError(e.toString()))),
          );
        }
      }
    }
  }

  Widget _buildCategoryList(List<Category> categories) {
    if (categories.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)!.noCategoriesYet),
      );
    }

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                category.icon,
                color: category.color,
              ),
            ),
            title: Text(category.displayName),
            subtitle: Text(
              category.isDefault ? AppLocalizations.of(context)!.defaultCategory : AppLocalizations.of(context)!.customCategory,
              style: TextStyle(
                color: category.isDefault ? Colors.grey : Colors.blue,
                fontSize: 12,
              ),
            ),
            trailing: category.isDefault
                ? null
                : PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.edit),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: Colors.red)),
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
                              builder: (context) => AddCategoryScreen(
                                category: category,
                                isIncomeCategory: category.isIncomeCategory,
                              ),
                            ),
                          );
                          if (result == true) {
                            await _loadCategories();
                          }
                          break;
                        case 'delete':
                          await _deleteCategory(category);
                          break;
                      }
                    },
                  ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.categories),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.expense),
            Tab(text: AppLocalizations.of(context)!.income),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryList(_expenseCategories),
                _buildCategoryList(_incomeCategories),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final isIncomeCategory = _tabController.index == 1;
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => AddCategoryScreen(
                isIncomeCategory: isIncomeCategory,
              ),
            ),
          );
          if (result == true) {
            await _loadCategories();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}