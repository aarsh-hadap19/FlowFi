import 'package:flowfi/models/models.dart';
import 'package:flowfi/services/transaction_service.dart';
import 'package:flowfi/services/goal_service.dart';

class DummyDataService {
  final TransactionService transactionService;
  final GoalService goalService;

  DummyDataService(this.transactionService, this.goalService);

  Future<void> initializeDummyData() async {
    // Check if data already exists (both transactions and goals)
    final existingTransactions = transactionService.getAllTransactions();
    final existingGoals = goalService.getAllGoals();
    
    if (existingTransactions.isNotEmpty && existingGoals.isNotEmpty) {
      return; // Data already initialized
    }

    // Create dummy transactions only if they don't exist
    if (existingTransactions.isEmpty) {
      await _createDummyTransactions();
    }

    // Create dummy goal only if goals don't exist
    if (existingGoals.isEmpty) {
      await _createDummyGoal();
    }
  }

  Future<void> _createDummyTransactions() async {
    final now = DateTime.now();
    final transactions = <Transaction>[];

    // Helper function to create a date
    DateTime createDate(int daysAgo, {int hour = 10}) {
      return DateTime(now.year, now.month, now.day - daysAgo, hour);
    }

    // Today's transactions
    transactions.addAll([
      Transaction(
        amount: 25.50,
        type: 'expense',
        category: 'food',
        date: createDate(0, hour: 12),
        note: 'Lunch at coffee shop',
      ),
      Transaction(
        amount: 5000.00,
        type: 'income',
        category: 'salary',
        date: createDate(0, hour: 9),
        note: 'Monthly salary',
      ),
    ]);

    // Yesterday
    transactions.addAll([
      Transaction(
        amount: 45.00,
        type: 'expense',
        category: 'entertainment',
        date: createDate(1, hour: 19),
        note: 'Movie tickets',
      ),
      Transaction(
        amount: 120.00,
        type: 'expense',
        category: 'food',
        date: createDate(1, hour: 13),
        note: 'Grocery shopping',
      ),
    ]);

    // 2 days ago
    transactions.addAll([
      Transaction(
        amount: 60.00,
        type: 'expense',
        category: 'transport',
        date: createDate(2, hour: 14),
        note: 'Uber to office',
      ),
      Transaction(
        amount: 200.00,
        type: 'expense',
        category: 'shopping',
        date: createDate(2, hour: 15),
        note: 'New shoes',
      ),
    ]);

    // 3 days ago
    transactions.addAll([
      Transaction(
        amount: 150.00,
        type: 'expense',
        category: 'utilities',
        date: createDate(3, hour: 10),
        note: 'Electricity bill',
      ),
      Transaction(
        amount: 30.00,
        type: 'expense',
        category: 'health',
        date: createDate(3, hour: 11),
        note: 'Pharmacy',
      ),
    ]);

    // 4 days ago
    transactions.addAll([
      Transaction(
        amount: 55.00,
        type: 'expense',
        category: 'food',
        date: createDate(4, hour: 19),
        note: 'Dinner with friends',
      ),
      Transaction(
        amount: 500.00,
        type: 'income',
        category: 'freelance',
        date: createDate(4, hour: 10),
        note: 'Project payment',
      ),
    ]);

    // 5 days ago
    transactions.addAll([
      Transaction(
        amount: 89.99,
        type: 'expense',
        category: 'education',
        date: createDate(5, hour: 14),
        note: 'Online course',
      ),
      Transaction(
        amount: 25.00,
        type: 'expense',
        category: 'entertainment',
        date: createDate(5, hour: 18),
        note: 'Music subscription renewal',
      ),
    ]);

    // 6 days ago
    transactions.addAll([
      Transaction(
        amount: 15.00,
        type: 'expense',
        category: 'food',
        date: createDate(6, hour: 12),
        note: 'Breakfast',
      ),
      Transaction(
        amount: 75.00,
        type: 'expense',
        category: 'transport',
        date: createDate(6, hour: 8),
        note: 'Gas',
      ),
    ]);

    // 7 days ago
    transactions.addAll([
      Transaction(
        amount: 200.00,
        type: 'expense',
        category: 'shopping',
        date: createDate(7, hour: 16),
        note: 'Clothes shopping',
      ),
      Transaction(
        amount: 35.00,
        type: 'expense',
        category: 'health',
        date: createDate(7, hour: 13),
        note: 'Doctor visit copay',
      ),
    ]);

    // 8-14 days ago - varied transactions
    transactions.addAll([
      Transaction(
        amount: 2500.00,
        type: 'income',
        category: 'freelance',
        date: createDate(8, hour: 11),
        note: 'Consulting project',
      ),
      Transaction(
        amount: 110.00,
        type: 'expense',
        category: 'utilities',
        date: createDate(9, hour: 10),
        note: 'Internet bill',
      ),
      Transaction(
        amount: 65.00,
        type: 'expense',
        category: 'food',
        date: createDate(10, hour: 12),
        note: 'Lunch',
      ),
      Transaction(
        amount: 40.00,
        type: 'expense',
        category: 'transport',
        date: createDate(11, hour: 9),
        note: 'Parking',
      ),
      Transaction(
        amount: 150.00,
        type: 'expense',
        category: 'shopping',
        date: createDate(12, hour: 15),
        note: 'Books',
      ),
      Transaction(
        amount: 25.00,
        type: 'expense',
        category: 'food',
        date: createDate(13, hour: 13),
        note: 'Snacks',
      ),
      Transaction(
        amount: 300.00,
        type: 'income',
        category: 'investment',
        date: createDate(14, hour: 9),
        note: 'Dividend payment',
      ),
    ]);

    // Save all transactions
    for (var transaction in transactions) {
      await transactionService.addTransaction(transaction);
    }
  }

  Future<void> _createDummyGoal() async {
    final goal = Goal(
      name: 'No-Spend Challenge',
      type: 'noSpendChallenge',
      targetDays: 7,
      startDate: DateTime.now(),
    );

    goal.currentDays = 1; // Started 1 day ago

    await goalService.addGoal(goal);
  }

  // Clear all dummy data (for testing)
  Future<void> clearAllData() async {
    await transactionService.clearAll();
    await goalService.clearAll();
  }
}
