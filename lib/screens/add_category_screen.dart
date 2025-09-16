import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/category.dart';

class AddCategoryScreen extends StatefulWidget {
  final Category? category; // null for add, not null for edit
  final bool isIncomeCategory;

  const AddCategoryScreen({
    super.key,
    this.category,
    this.isIncomeCategory = false,
  });

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _displayNameController = TextEditingController();
  
  IconData _selectedIcon = Icons.category;
  Color _selectedColor = Colors.blue;
  bool _isLoading = false;

  // Common icons for categories
  final List<IconData> _availableIcons = [
    Icons.restaurant,
    Icons.shopping_bag,
    Icons.home,
    Icons.directions_car,
    Icons.school,
    Icons.sports_esports,
    Icons.medical_services,
    Icons.pets,
    Icons.fitness_center,
    Icons.local_gas_station,
    Icons.phone,
    Icons.wifi,
    Icons.electric_bolt,
    Icons.water_drop,
    Icons.work,
    Icons.card_giftcard,
    Icons.trending_up,
    Icons.laptop,
    Icons.attach_money,
    Icons.savings,
    Icons.business,
    Icons.category,
    Icons.shopping_cart,
    Icons.coffee,
    Icons.movie,
    Icons.book,
    Icons.flight,
    Icons.hotel,
  ];

  // Color options
  final List<Color> _availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _displayNameController.text = widget.category!.displayName;
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final category = Category(
        id: widget.category?.id,
        name: _nameController.text.toLowerCase().replaceAll(' ', '_'),
        displayName: _displayNameController.text,
        icon: _selectedIcon,
        color: _selectedColor,
        isIncomeCategory: widget.isIncomeCategory,
      );

      if (widget.category == null) {
        await DatabaseHelper.instance.insertCategory(category);
      } else {
        await DatabaseHelper.instance.updateCategory(category);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving category: $e')),
        );
      }
    }
  }

  void _showIconPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Icon'),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              childAspectRatio: 1,
            ),
            itemCount: _availableIcons.length,
            itemBuilder: (context, index) {
              final icon = _availableIcons[index];
              return InkWell(
                onTap: () {
                  setState(() => _selectedIcon = icon);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: icon == _selectedIcon ? Colors.blue : Colors.grey,
                      width: icon == _selectedIcon ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 24),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Color'),
        content: Container(
          width: double.maxFinite,
          height: 200,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              childAspectRatio: 1,
            ),
            itemCount: _availableColors.length,
            itemBuilder: (context, index) {
              final color = _availableColors[index];
              return InkWell(
                onTap: () {
                  setState(() => _selectedColor = color);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(
                      color: color == _selectedColor ? Colors.black : Colors.grey,
                      width: color == _selectedColor ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: color == _selectedColor
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Category' : 'Add Category'),
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
              onPressed: _saveCategory,
              child: Text(isEditing ? 'Update' : 'Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _selectedColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _selectedIcon,
                            color: _selectedColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _displayNameController.text.isNotEmpty
                                    ? _displayNameController.text
                                    : 'Category Name',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                widget.isIncomeCategory ? 'Income Category' : 'Expense Category',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                hintText: 'e.g., Food & Dining',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a display name';
                }
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Internal Name',
                hintText: 'e.g., food_dining',
                border: OutlineInputBorder(),
                helperText: 'Used internally, will be auto-generated if empty',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: ListTile(
                      leading: Icon(_selectedIcon, color: _selectedColor),
                      title: const Text('Icon'),
                      subtitle: const Text('Tap to change'),
                      onTap: _showIconPicker,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: ListTile(
                      leading: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: const Text('Color'),
                      subtitle: const Text('Tap to change'),
                      onTap: _showColorPicker,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}