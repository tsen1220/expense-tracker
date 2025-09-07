import 'category.dart';

enum TransactionType { income, expense }

class Transaction {
  final int? id;
  final String title;
  final double amount;
  final Category category;
  final DateTime date;
  final String? description;
  final TransactionType type;

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category_id': category.id,
      'date': date.millisecondsSinceEpoch,
      'description': description,
      'type': type.name,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map, Category category) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: category,
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      description: map['description'],
      type: TransactionType.values.firstWhere(
        (type) => type.name == map['type'],
      ),
    );
  }

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
}