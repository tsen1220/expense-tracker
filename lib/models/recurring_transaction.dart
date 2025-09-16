import 'category.dart';
import 'transaction.dart';

enum RecurrenceFrequency {
  daily,
  weekly,
  monthly,
  yearly,
}

extension RecurrenceFrequencyExtension on RecurrenceFrequency {
  String get displayName {
    switch (this) {
      case RecurrenceFrequency.daily:
        return 'Daily';
      case RecurrenceFrequency.weekly:
        return 'Weekly';
      case RecurrenceFrequency.monthly:
        return 'Monthly';
      case RecurrenceFrequency.yearly:
        return 'Yearly';
    }
  }

  String get description {
    switch (this) {
      case RecurrenceFrequency.daily:
        return 'Every day';
      case RecurrenceFrequency.weekly:
        return 'Every week';
      case RecurrenceFrequency.monthly:
        return 'Every month';
      case RecurrenceFrequency.yearly:
        return 'Every year';
    }
  }
}

class RecurringTransaction {
  final int? id;
  final String title;
  final double amount;
  final Category category;
  final String? description;
  final TransactionType type;
  final RecurrenceFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate; // null means no end date
  final DateTime nextDueDate;
  final DateTime? lastExecutedDate;
  final bool isActive;

  RecurringTransaction({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    this.description,
    required this.type,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.nextDueDate,
    this.lastExecutedDate,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category_id': category.id,
      'description': description,
      'type': type.name,
      'frequency': frequency.name,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate?.millisecondsSinceEpoch,
      'next_due_date': nextDueDate.millisecondsSinceEpoch,
      'last_executed_date': lastExecutedDate?.millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory RecurringTransaction.fromMap(Map<String, dynamic> map, Category category) {
    return RecurringTransaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: category,
      description: map['description'],
      type: TransactionType.values.firstWhere(
        (type) => type.name == map['type'],
      ),
      frequency: RecurrenceFrequency.values.firstWhere(
        (freq) => freq.name == map['frequency'],
      ),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date']),
      endDate: map['end_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['end_date'])
          : null,
      nextDueDate: DateTime.fromMillisecondsSinceEpoch(map['next_due_date']),
      lastExecutedDate: map['last_executed_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_executed_date'])
          : null,
      isActive: map['is_active'] == 1,
    );
  }

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  bool get hasEndDate => endDate != null;

  bool get isOverdue => DateTime.now().isAfter(nextDueDate) && isActive;

  bool get isDueToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(nextDueDate.year, nextDueDate.month, nextDueDate.day);
    return today == dueDay && isActive;
  }

  bool get shouldExpire {
    if (!hasEndDate) return false;
    return DateTime.now().isAfter(endDate!);
  }

  DateTime calculateNextDueDate() {
    final currentNext = nextDueDate;

    switch (frequency) {
      case RecurrenceFrequency.daily:
        return DateTime(
          currentNext.year,
          currentNext.month,
          currentNext.day + 1,
        );
      case RecurrenceFrequency.weekly:
        return DateTime(
          currentNext.year,
          currentNext.month,
          currentNext.day + 7,
        );
      case RecurrenceFrequency.monthly:
        final nextMonth = currentNext.month == 12
            ? DateTime(currentNext.year + 1, 1, currentNext.day)
            : DateTime(currentNext.year, currentNext.month + 1, currentNext.day);

        // Handle edge case for dates like Feb 30 -> Feb 28/29
        try {
          return DateTime(nextMonth.year, nextMonth.month, currentNext.day);
        } catch (e) {
          // If the day doesn't exist in the next month, use the last day of that month
          return DateTime(nextMonth.year, nextMonth.month + 1, 0);
        }
      case RecurrenceFrequency.yearly:
        return DateTime(
          currentNext.year + 1,
          currentNext.month,
          currentNext.day,
        );
    }
  }

  RecurringTransaction copyWith({
    int? id,
    String? title,
    double? amount,
    Category? category,
    String? description,
    TransactionType? type,
    RecurrenceFrequency? frequency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextDueDate,
    DateTime? lastExecutedDate,
    bool? isActive,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      lastExecutedDate: lastExecutedDate ?? this.lastExecutedDate,
      isActive: isActive ?? this.isActive,
    );
  }

  Transaction toTransaction({DateTime? customDate}) {
    return Transaction(
      title: title,
      amount: amount,
      category: category,
      date: customDate ?? DateTime.now(),
      description: description,
      type: type,
    );
  }
}