import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'transaction.g.dart';

enum TransactionType {
  income,
  expense,
}

enum TransactionCategory {
  salary,
  freelance,
  investment,
  food,
  transport,
  entertainment,
  utilities,
  shopping,
  health,
  education,
  other,
}

extension TransactionCategoryExtension on TransactionCategory {
  String get displayName {
    return toString().split('.').last.replaceAllMapped(
          RegExp(r'(?<=[a-z])(?=[A-Z])'),
          (Match m) => ' ',
        );
  }

  String get emoji {
    switch (this) {
      case TransactionCategory.salary:
        return '💼';
      case TransactionCategory.freelance:
        return '💻';
      case TransactionCategory.investment:
        return '📈';
      case TransactionCategory.food:
        return '🍔';
      case TransactionCategory.transport:
        return '🚗';
      case TransactionCategory.entertainment:
        return '🎬';
      case TransactionCategory.utilities:
        return '💡';
      case TransactionCategory.shopping:
        return '🛍️';
      case TransactionCategory.health:
        return '🏥';
      case TransactionCategory.education:
        return '📚';
      case TransactionCategory.other:
        return '📌';
    }
  }
}

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late double amount;

  @HiveField(2)
  late String type;

  @HiveField(3)
  late String category;

  @HiveField(4)
  late DateTime date;

  @HiveField(5)
  late String? note;

  @HiveField(6)
  late DateTime createdAt;

  Transaction({
    String? id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
    DateTime? createdAt,
  }) {
    this.id = id ?? const Uuid().v4();
    this.createdAt = createdAt ?? DateTime.now();
  }

  TransactionType get transactionType =>
      type == 'income' ? TransactionType.income : TransactionType.expense;

  TransactionCategory get categoryEnum {
    try {
      return TransactionCategory.values.firstWhere((e) => e.toString().split('.').last == category);
    } catch (e) {
      return TransactionCategory.other;
    }
  }

  Transaction copyWith({
    String? id,
    double? amount,
    String? type,
    String? category,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'Transaction(id: $id, amount: $amount, type: $type, category: $category, date: $date)';
}
