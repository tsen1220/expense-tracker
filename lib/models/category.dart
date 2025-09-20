import 'package:flutter/material.dart';

class Category {
  final int? id;
  final String name;
  final String displayName;
  final IconData icon;
  final Color color;
  final bool isDefault;
  final bool isIncomeCategory;

  Category({
    this.id,
    required this.name,
    required this.displayName,
    required this.icon,
    required this.color,
    this.isDefault = false,
    this.isIncomeCategory = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'icon_code': icon.codePoint,
      'color_value': color.value,
      'is_default': isDefault ? 1 : 0,
      'is_income_category': isIncomeCategory ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['category_table_id'] ?? map['id'], // Support both aliases
      name: map['name'],
      displayName: map['display_name'],
      icon: IconData(map['icon_code'], fontFamily: 'MaterialIcons'),
      color: Color(map['color_value']),
      isDefault: map['is_default'] == 1,
      isIncomeCategory: map['is_income_category'] == 1,
    );
  }

  Category copyWith({
    int? id,
    String? name,
    String? displayName,
    IconData? icon,
    Color? color,
    bool? isDefault,
    bool? isIncomeCategory,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      isIncomeCategory: isIncomeCategory ?? this.isIncomeCategory,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

// Default categories for initial setup
class DefaultCategories {
  static List<Category> get expenseCategories => [
    Category(
      name: 'food',
      displayName: 'Food',
      icon: Icons.restaurant,
      color: const Color(0xFFFF6B6B),
      isDefault: true,
    ),
    Category(
      name: 'transport',
      displayName: 'Transport',
      icon: Icons.directions_car,
      color: const Color(0xFF96CEB4),
      isDefault: true,
    ),
    Category(
      name: 'housing',
      displayName: 'Housing',
      icon: Icons.home,
      color: const Color(0xFF45B7D1),
      isDefault: true,
    ),
    Category(
      name: 'utilities',
      displayName: 'Utilities',
      icon: Icons.electrical_services,
      color: const Color(0xFFFFAB40),
      isDefault: true,
    ),
    Category(
      name: 'entertainment',
      displayName: 'Entertainment',
      icon: Icons.sports_esports,
      color: const Color(0xFFD63384),
      isDefault: true,
    ),
    Category(
      name: 'clothing',
      displayName: 'Clothing',
      icon: Icons.shopping_bag,
      color: const Color(0xFF4ECDC4),
      isDefault: true,
    ),
    Category(
      name: 'health',
      displayName: 'Health',
      icon: Icons.local_hospital,
      color: const Color(0xFF81C784),
      isDefault: true,
    ),
    Category(
      name: 'education',
      displayName: 'Education',
      icon: Icons.school,
      color: const Color(0xFFFECEA8),
      isDefault: true,
    ),
    Category(
      name: 'social',
      displayName: 'Social',
      icon: Icons.people,
      color: const Color(0xFFBA68C8),
      isDefault: true,
    ),
    Category(
      name: 'other',
      displayName: 'Other',
      icon: Icons.more_horiz,
      color: const Color(0xFF90A4AE),
      isDefault: true,
    ),
  ];

  static List<Category> get incomeCategories => [
    Category(
      name: 'salary',
      displayName: 'Salary',
      icon: Icons.work,
      color: const Color(0xFF28A745),
      isDefault: true,
      isIncomeCategory: true,
    ),
    Category(
      name: 'bonus',
      displayName: 'Bonus',
      icon: Icons.card_giftcard,
      color: const Color(0xFF20C997),
      isDefault: true,
      isIncomeCategory: true,
    ),
    Category(
      name: 'investment',
      displayName: 'Investment',
      icon: Icons.trending_up,
      color: const Color(0xFF17A2B8),
      isDefault: true,
      isIncomeCategory: true,
    ),
    Category(
      name: 'freelance',
      displayName: 'Freelance',
      icon: Icons.laptop,
      color: const Color(0xFF6F42C1),
      isDefault: true,
      isIncomeCategory: true,
    ),
    Category(
      name: 'other',
      displayName: 'Other',
      icon: Icons.attach_money,
      color: const Color(0xFF198754),
      isDefault: true,
      isIncomeCategory: true,
    ),
  ];

  static List<Category> get allDefaultCategories => [
    ...expenseCategories,
    ...incomeCategories,
  ];
}