import 'package:hive_flutter/hive_flutter.dart';
import 'package:flowfi/models/transaction.dart';
import 'package:flowfi/services/hive_service.dart';

class TransactionService {
  late Box<Transaction> _transactionsBox;

  TransactionService() {
    _transactionsBox = HiveService.getTransactionsBox();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
  }

  List<Transaction> getAllTransactions() {
    return _transactionsBox.values.toList();
  }

  Stream<List<Transaction>> watchTransactions() async* {
    yield getAllTransactions();
    await for (final _ in _transactionsBox.watch()) {
      yield getAllTransactions();
    }
  }

  Transaction? getTransaction(String id) {
    return _transactionsBox.get(id);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionsBox.delete(id);
  }

  List<Transaction> getTransactionsByType(String type) {
    return _transactionsBox.values.where((t) => t.type == type).toList();
  }

  List<Transaction> getTransactionsForDate(DateTime date) {
    return _transactionsBox.values
        .where((t) =>
            t.date.year == date.year && t.date.month == date.month && t.date.day == date.day)
        .toList();
  }

  List<Transaction> getTransactionsInRange(DateTime startDate, DateTime endDate) {
    return _transactionsBox.values
        .where((t) => t.date.isAfter(startDate) && t.date.isBefore(endDate.add(Duration(days: 1))))
        .toList();
  }

  List<Transaction> getTransactionsByCategory(String category) {
    return _transactionsBox.values.where((t) => t.category == category).toList();
  }

  List<Transaction> searchTransactions(String query) {
    final lowerQuery = query.toLowerCase();
    return _transactionsBox.values
        .where((t) =>
            t.note?.toLowerCase().contains(lowerQuery) ?? false ||
            t.amount.toString().contains(query) ||
            t.transactionType.toString().contains(lowerQuery))
        .toList();
  }

  List<Transaction> getSortedTransactions({bool newestFirst = true}) {
    final transactions = getAllTransactions();
    transactions.sort((a, b) => newestFirst ? b.date.compareTo(a.date) : a.date.compareTo(b.date));
    return transactions;
  }

  Future<void> clearAll() async {
    await _transactionsBox.clear();
  }

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
