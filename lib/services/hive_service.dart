import 'package:hive_flutter/hive_flutter.dart';
import 'package:flowfi/models/models.dart';

class HiveService {
  static const String transactionsBox = 'transactions';
  static const String goalsBox = 'goals';
  static const String streakBox = 'savingsStreak';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(GoalAdapter());
    Hive.registerAdapter(SavingsStreakAdapter());

    await Hive.openBox<Transaction>(transactionsBox);
    await Hive.openBox<Goal>(goalsBox);
    await Hive.openBox<SavingsStreak>(streakBox);
  }

  static Box<Transaction> getTransactionsBox() {
    return Hive.box<Transaction>(transactionsBox);
  }

  static Box<Goal> getGoalsBox() {
    return Hive.box<Goal>(goalsBox);
  }

  static Box<SavingsStreak> getStreakBox() {
    return Hive.box<SavingsStreak>(streakBox);
  }

  static Future<void> clearAll() async {
    await Hive.box<Transaction>(transactionsBox).clear();
    await Hive.box<Goal>(goalsBox).clear();
    await Hive.box<SavingsStreak>(streakBox).clear();
  }

  static Future<void> close() async {
    await Hive.close();
  }
}
