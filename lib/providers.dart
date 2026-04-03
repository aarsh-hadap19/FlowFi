import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowfi/models/models.dart';
import 'package:flowfi/services/services.dart';

// Service providers - cached as app-lifetime singletons
final transactionServiceProvider = Provider((ref) {
  return TransactionService();
});

final goalServiceProvider = Provider((ref) {
  return GoalService();
});

final analyticsServiceProvider = Provider((ref) {
  final transactionService = ref.watch(transactionServiceProvider);
  return AnalyticsService(transactionService);
});

// Transaction providers
final allTransactionsProvider = StreamProvider((ref) {
  final transactionService = ref.watch(transactionServiceProvider);
  return transactionService.watchTransactions();
});

final transactionsByTypeProvider = FutureProvider.family<List<Transaction>, String>((ref, type) async {
  final transactionService = ref.watch(transactionServiceProvider);
  return transactionService.getTransactionsByType(type);
});

final sortedTransactionsProvider = FutureProvider((ref) async {
  final transactionService = ref.watch(transactionServiceProvider);
  return transactionService.getSortedTransactions();
});

// Goal providers
final allGoalsProvider = StreamProvider((ref) {
  final goalService = ref.watch(goalServiceProvider);
  return goalService.watchGoals();
});

final activeGoalsProvider = FutureProvider((ref) async {
  final _ = ref.watch(allGoalsProvider);
  final goalService = ref.watch(goalServiceProvider);
  return goalService.getActiveGoals();
});

final primaryNoSpendGoalProvider = FutureProvider((ref) async {
  final _ = ref.watch(allGoalsProvider);
  final goalService = ref.watch(goalServiceProvider);
  return goalService.getPrimaryNoSpendGoal();
});

// Analytics providers - watch transaction stream to ensure reactivity
final currentBalanceProvider = FutureProvider((ref) async {
  // Watch allTransactionsProvider to trigger recalculation when transactions change
  final _ = ref.watch(allTransactionsProvider);
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.calculateBalance();
});

final totalIncomeProvider = FutureProvider((ref) async {
  final _ = ref.watch(allTransactionsProvider);
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.calculateTotalIncome();
});

final totalExpensesProvider = FutureProvider((ref) async {
  final _ = ref.watch(allTransactionsProvider);
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.calculateTotalExpenses();
});

final highestSpendingCategoryProvider = FutureProvider((ref) async {
  final _ = ref.watch(allTransactionsProvider);
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.getHighestSpendingCategory();
});

final spendingByCategoryProvider = FutureProvider((ref) async {
  final _ = ref.watch(allTransactionsProvider);
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.getSpendingByCategory();
});

final weeklySpendingTrendProvider = FutureProvider((ref) async {
  final _ = ref.watch(allTransactionsProvider);
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.getWeeklySpendingTrend();
});

final weekLabelsProvider = FutureProvider((ref) async {
  final _ = ref.watch(allTransactionsProvider);
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.getWeekLabels();
});

final weeklyComparisonProvider = FutureProvider((ref) async {
  final _ = ref.watch(allTransactionsProvider);
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.compareWeeklySpending();
});

final smartInsightProvider = FutureProvider((ref) async {
  final _ = ref.watch(allTransactionsProvider);
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.getSmartInsight();
});

final savingProgressProvider = FutureProvider((ref) async {
  final _ = ref.watch(allTransactionsProvider);
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.getSavingProgress();
});

final frequentTransactionTypeProvider = FutureProvider((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.getFrequentTransactionType();
});

final dailyAverageSpendingProvider = FutureProvider((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.getDailyAverageSpending();
});
