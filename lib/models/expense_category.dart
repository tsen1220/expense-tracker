import 'package:flutter/material.dart';

enum ExpenseCategory {
  food('Food', Icons.restaurant, Color(0xFFFF6B6B)),
  clothing('Clothing', Icons.shopping_bag, Color(0xFF4ECDC4)),
  housing('Housing', Icons.home, Color(0xFF45B7D1)),
  transportation('Transportation', Icons.directions_car, Color(0xFF96CEB4)),
  education('Education', Icons.school, Color(0xFFFECEA8)),
  entertainment('Entertainment', Icons.sports_esports, Color(0xFFD63384));

  const ExpenseCategory(this.displayName, this.icon, this.color);

  final String displayName;
  final IconData icon;
  final Color color;
}