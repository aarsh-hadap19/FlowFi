import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'goal.g.dart';

enum GoalType {
  noSpendChallenge,
  savingsTarget,
  budgetLimit,
}

@HiveType(typeId: 1)
class Goal extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String type;

  @HiveField(3)
  late int targetDays;

  @HiveField(4)
  late int currentDays;

  @HiveField(5)
  late double? targetAmount;

  @HiveField(6)
  late double currentAmount;

  @HiveField(7)
  late DateTime startDate;

  @HiveField(8)
  late DateTime? lastResetDate;

  @HiveField(9)
  late bool isActive;

  @HiveField(10)
  late DateTime createdAt;

  Goal({
    String? id,
    required this.name,
    required this.type,
    required this.targetDays,
    this.targetAmount,
    DateTime? startDate,
    this.lastResetDate,
    bool? isActive,
    DateTime? createdAt,
  }) {
    this.id = id ?? const Uuid().v4();
    this.startDate = startDate ?? DateTime.now();
    this.currentDays = 0;
    this.currentAmount = 0.0;
    this.isActive = isActive ?? true;
    this.createdAt = createdAt ?? DateTime.now();
  }

  GoalType get goalType {
    switch (type) {
      case 'savingsTarget':
        return GoalType.savingsTarget;
      case 'budgetLimit':
        return GoalType.budgetLimit;
      default:
        return GoalType.noSpendChallenge;
    }
  }

  double get progressPercentage {
    if (targetDays <= 0) return 0.0;
    return (currentDays / targetDays).clamp(0.0, 1.0);
  }

  bool get isCompleted => currentDays >= targetDays;

  Goal copyWith({
    String? id,
    String? name,
    String? type,
    int? targetDays,
    int? currentDays,
    double? targetAmount,
    double? currentAmount,
    DateTime? startDate,
    DateTime? lastResetDate,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      targetDays: targetDays ?? this.targetDays,
      targetAmount: targetAmount ?? this.targetAmount,
      startDate: startDate ?? this.startDate,
      lastResetDate: lastResetDate ?? this.lastResetDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    )
      ..currentDays = currentDays ?? this.currentDays
      ..currentAmount = currentAmount ?? this.currentAmount;
  }

  @override
  String toString() => 'Goal(id: $id, name: $name, currentDays: $currentDays, targetDays: $targetDays)';
}
