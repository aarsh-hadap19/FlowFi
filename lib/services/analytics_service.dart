import 'package:flowfi/services/transaction_service.dart';

class AnalyticsService {
  final TransactionService _transactionService;

  AnalyticsService(this._transactionService);

  double calculateBalance() {
    final transactions = _transactionService.getAllTransactions();
    double income = 0;
    double expenses = 0;

    for (var transaction in transactions) {
      if (transaction.type == 'income') {
        income += transaction.amount;
      } else {
        expenses += transaction.amount;
      }
    }

    return income - expenses;
  }

  double calculateTotalIncome() {
    return _transactionService
        .getTransactionsByType('income')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double calculateTotalExpenses() {
    return _transactionService
        .getTransactionsByType('expense')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  String getHighestSpendingCategory() {
    final expenses = _transactionService.getTransactionsByType('expense');
    if (expenses.isEmpty) return 'None';

    final categoryMap = <String, double>{};
    for (var transaction in expenses) {
      categoryMap[transaction.category] =
          (categoryMap[transaction.category] ?? 0) + transaction.amount;
    }

    final highestCategory = categoryMap.entries.reduce((a, b) => a.value > b.value ? a : b);
    return highestCategory.key;
  }

  Map<String, double> getSpendingByCategory() {
    final expenses = _transactionService.getTransactionsByType('expense');
    final categoryMap = <String, double>{};

    for (var transaction in expenses) {
      categoryMap[transaction.category] =
          (categoryMap[transaction.category] ?? 0) + transaction.amount;
    }

    return categoryMap;
  }

  List<double> getWeeklySpendingTrend() {
    final now = DateTime.now();
    final weeklyData = List<double>.filled(7, 0.0);

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayTransactions = _transactionService.getTransactionsForDate(day);
      final dayExpenses = dayTransactions.where((t) => t.type == 'expense');
      final totalExpense = dayExpenses.fold<double>(0, (sum, t) => sum + t.amount);
      weeklyData[i] = totalExpense;
    }

    return weeklyData;
  }

  List<String> getWeekLabels() {
    final now = DateTime.now();
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Adjust if today is not Sunday
    final adjustedLabels = <String>[];
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: 6 - i));
      adjustedLabels.add(labels[day.weekday - 1]);
    }

    return adjustedLabels;
  }

  Map<String, double> compareWeeklySpending() {
    final now = DateTime.now();
    final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfLastWeek = startOfThisWeek.subtract(Duration(days: 7));
    final endOfLastWeek = startOfThisWeek.subtract(Duration(days: 1));

    final thisWeekTransactions =
        _transactionService.getTransactionsInRange(startOfThisWeek, now);
    final lastWeekTransactions =
        _transactionService.getTransactionsInRange(startOfLastWeek, endOfLastWeek);

    final thisWeekExpenses =
        thisWeekTransactions.where((t) => t.type == 'expense').fold<double>(0, (s, t) => s + t.amount);
    final lastWeekExpenses =
        lastWeekTransactions.where((t) => t.type == 'expense').fold<double>(0, (s, t) => s + t.amount);

    return {
      'thisWeek': thisWeekExpenses,
      'lastWeek': lastWeekExpenses,
      'difference': thisWeekExpenses - lastWeekExpenses,
    };
  }

  List<double> getMonthlySpendings() {
    final now = DateTime.now();
    final monthlyData = List<double>.filled(12, 0.0);

    for (int i = 0; i < 12; i++) {
      final year = i < now.month ? now.year : now.year - 1;
      final month = i < now.month ? i + 1 : i + 1 - 12;

      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);

      final monthTransactions = _transactionService.getTransactionsInRange(startDate, endDate);
      final monthExpenses = monthTransactions.where((t) => t.type == 'expense');
      final totalExpense = monthExpenses.fold<double>(0, (sum, t) => sum + t.amount);

      monthlyData[i] = totalExpense;
    }

    return monthlyData;
  }

  String getSmartInsight() {
    final today = DateTime.now();
    final yesterdayTransactions =
        _transactionService.getTransactionsForDate(today.subtract(Duration(days: 1)));
    final todayTransactions = _transactionService.getTransactionsForDate(today);

    final yesterdayExpenses =
        yesterdayTransactions.where((t) => t.type == 'expense').fold<double>(0, (s, t) => s + t.amount);
    final todayExpenses =
        todayTransactions.where((t) => t.type == 'expense').fold<double>(0, (s, t) => s + t.amount);

    if (todayExpenses == 0) {
      return '🎉 Great job! No spending today.';
    } else if (todayExpenses > yesterdayExpenses) {
      return '⚠️ You spent more than yesterday.';
    } else if (todayExpenses > 0) {
      return '💰 Keep it up! Less spending than yesterday.';
    } else {
      return '📊 Track your spending to get insights.';
    }
  }

  double getSavingProgress() {
    final totalIncome = calculateTotalIncome();
    final totalExpenses = calculateTotalExpenses();
    final savings = totalIncome - totalExpenses;
    if (totalIncome == 0) return 0;
    return (savings / totalIncome).clamp(0, 1);
  }

  String getFrequentTransactionType() {
    final transactions = _transactionService.getAllTransactions();
    if (transactions.isEmpty) return 'Unknown';

    int incomeCount = 0;
    int expenseCount = 0;

    for (var transaction in transactions) {
      if (transaction.type == 'income') {
        incomeCount++;
      } else {
        expenseCount++;
      }
    }

    return incomeCount > expenseCount ? 'Income' : 'Expense';
  }

  double getDailyAverageSpending() {
    final transactions = _transactionService.getAllTransactions();
    if (transactions.isEmpty) return 0;

    // Get unique dates
    final dates = <DateTime>{};
    for (var transaction in transactions) {
      dates.add(DateTime(transaction.date.year, transaction.date.month, transaction.date.day));
    }

    final totalExpenses = calculateTotalExpenses();
    return totalExpenses / dates.length;
  }
}
