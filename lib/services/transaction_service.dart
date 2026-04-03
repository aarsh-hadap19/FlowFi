import 'package:hive_flutter/hive_flutter.dart';
import 'package:flowfi/models/transaction.dart';
import 'package:flowfi/services/hive_service.dart';

class TransactionService {
  late Box<Transaction> _transactionsBox;

  TransactionService() {
    _transactionsBox = HiveService.getTransactionsBox();
  }

  // Add a new transaction
  Future<void> addTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
  }

  // Get all transactions
  List<Transaction> getAllTransactions() {
    return _transactionsBox.values.toList();
  }

  // Get transactions as a stream
  Stream<List<Transaction>> watchTransactions() async* {
    // Emit current state first
    yield getAllTransactions();
    
    // Then listen for changes
    await for (final _ in _transactionsBox.watch()) {
      yield getAllTransactions();
    }
  }

  // Get transaction by ID
  Transaction? getTransaction(String id) {
    return _transactionsBox.get(id);
  }

  // Update transaction
  Future<void> updateTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
  }

  // Delete transaction
  Future<void> deleteTransaction(String id) async {
    await _transactionsBox.delete(id);
  }

  // Get transactions filtered by type
  List<Transaction> getTransactionsByType(String type) {
    return _transactionsBox.values.where((t) => t.type == type).toList();
  }

  // Get transactions for a specific date
  List<Transaction> getTransactionsForDate(DateTime date) {
    return _transactionsBox.values
        .where((t) =>
            t.date.year == date.year && t.date.month == date.month && t.date.day == date.day)
        .toList();
  }

  // Get transactions for a date range
  List<Transaction> getTransactionsInRange(DateTime startDate, DateTime endDate) {
    return _transactionsBox.values
        .where((t) => t.date.isAfter(startDate) && t.date.isBefore(endDate.add(Duration(days: 1))))
        .toList();
  }

  // Get transactions by category
  List<Transaction> getTransactionsByCategory(String category) {
    return _transactionsBox.values.where((t) => t.category == category).toList();
  }

  // Search transactions by note
  List<Transaction> searchTransactions(String query) {
    final lowerQuery = query.toLowerCase();
    return _transactionsBox.values
        .where((t) =>
            t.note?.toLowerCase().contains(lowerQuery) ?? false ||
            t.amount.toString().contains(query) ||
            t.transactionType.toString().contains(lowerQuery))
        .toList();
  }

  // Get sorted transactions (newest first)
  List<Transaction> getSortedTransactions({bool newestFirst = true}) {
    final transactions = getAllTransactions();
    transactions.sort((a, b) => newestFirst ? b.date.compareTo(a.date) : a.date.compareTo(b.date));
    return transactions;
  }

  // Clear all transactions
  Future<void> clearAll() async {
    await _transactionsBox.clear();
  }

  // Get transaction count
  int getTransactionCount() {
    return _transactionsBox.length;
  }

  // Delete transactions older than a date
  Future<void> deleteOlderThan(DateTime date) async {
    final keysToDelete = <dynamic>[];
    for (var transaction in _transactionsBox.values) {
      if (transaction.date.isBefore(date)) {
        keysToDelete.add(transaction.key);
      }
    }
    await _transactionsBox.deleteAll(keysToDelete);
  }
}
