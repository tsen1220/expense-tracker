import 'category.dart';

class Budget {
  final int? id;
  final Category? category; // null means overall budget
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  Budget({
    this.id,
    this.category,
    required this.amount,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': category?.id,
      'amount': amount,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate.millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map, Category? category) {
    return Budget(
      id: map['id'],
      category: category,
      amount: map['amount'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['end_date']),
      isActive: map['is_active'] == 1,
    );
  }

  bool get isOverallBudget => category == null;
  bool get isCategoryBudget => category != null;

  bool isValidForDate(DateTime date) {
    return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
           date.isBefore(endDate.add(const Duration(days: 1)));
  }

  Duration get duration => endDate.difference(startDate);
  bool get isCurrentlyActive => 
      isActive && 
      DateTime.now().isAfter(startDate.subtract(const Duration(days: 1))) &&
      DateTime.now().isBefore(endDate.add(const Duration(days: 1)));

  Budget copyWith({
    int? id,
    Category? category,
    double? amount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }
}