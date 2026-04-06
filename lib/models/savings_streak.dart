import 'package:hive/hive.dart';

part 'savings_streak.g.dart';

@HiveType(typeId: 2)
class SavingsStreak extends HiveObject {
  @HiveField(0)
  late int currentStreak;

  @HiveField(1)
  late int longestStreak;

  @HiveField(2)
  late DateTime? lastUpdated;

  @HiveField(3)
  late DateTime createdAt;

  SavingsStreak({
    int? currentStreak,
    int? longestStreak,
    this.lastUpdated,
    DateTime? createdAt,
  }) {
    this.currentStreak = currentStreak ?? 0;
    this.longestStreak = longestStreak ?? 0;
    this.createdAt = createdAt ?? DateTime.now();
  }

  void incrementStreak() {
    currentStreak++;
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }
    lastUpdated = DateTime.now();
  }

  void resetStreak() {
    currentStreak = 0;
    lastUpdated = DateTime.now();
  }

  SavingsStreak copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) {
    return SavingsStreak(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      createdAt: createdAt ?? this.createdAt,
    )
      ..lastUpdated = lastUpdated ?? this.lastUpdated;
  }

  @override
  String toString() => 'SavingsStreak(current: $currentStreak, longest: $longestStreak)';
}
