import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowfi/models/models.dart';
import 'package:flowfi/constants/app_theme.dart';
import 'package:flowfi/providers.dart';
import 'package:flowfi/widgets/widgets.dart';
import 'package:flowfi/screens/add_edit_transaction_screen.dart';
import 'package:flowfi/utils/formatters.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _filterType = 'all'; // all, income, expense
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    var filtered = transactions;

    // Filter by type
    if (_filterType != 'all') {
      filtered = filtered.where((t) => t.type == _filterType).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) {
        final noteMatch = t.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
        final amountMatch = t.amount.toString().contains(_searchQuery);
        return noteMatch || amountMatch;
      }).toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final allTransactions = ref.watch(sortedTransactionsProvider);
    final transactionService = ref.read(transactionServiceProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        title: Text('Transactions', style: AppTypography.headline2),
      ),
      body: Column(
        children: [
          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  style: AppTypography.body1,
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    hintStyle:
                        AppTypography.body1.copyWith(color: AppColors.textTertiary),
                    prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      const SizedBox(width: AppSpacing.sm),
                      _buildFilterChip('Income', 'income'),
                      const SizedBox(width: AppSpacing.sm),
                      _buildFilterChip('Expense', 'expense'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Transactions List
          Expanded(
            child: allTransactions.when(
              data: (transactions) {
                final filtered = _filterTransactions(transactions);

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: '📋',
                    title: 'No Transactions',
                    description: _searchQuery.isNotEmpty
                        ? 'No matching transactions found'
                        : 'Start by adding your first transaction',
                    actionLabel: 'Add Transaction',
                    onActionPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddEditTransactionScreen(),
                        ),
                      );
                    },
                  );
                }

                // Group transactions by date
                final groupedTransactions = <String, List<Transaction>>{};
                for (var transaction in filtered) {
                  final dateKey = DateFormatter.formatDate(transaction.date);
                  if (!groupedTransactions.containsKey(dateKey)) {
                    groupedTransactions[dateKey] = [];
                  }
                  groupedTransactions[dateKey]!.add(transaction);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  itemCount: groupedTransactions.length,
                  itemBuilder: (ctx, index) {
                    final dateKey = groupedTransactions.keys.toList()[index];
                    final dayTransactions = groupedTransactions[dateKey]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormatter.formatDateForList(dayTransactions.first.date),
                          style: AppTypography.subtitle2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ...dayTransactions.map((transaction) {
                          return TransactionItem(
                            transaction: transaction,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AddEditTransactionScreen(transaction: transaction),
                                ),
                              );
                            },
                            onDelete: () async {
                              await transactionService.deleteTransaction(transaction.id);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Transaction deleted')),
                                );
                              }
                            },
                          );
                        }).toList(),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(message: 'Loading transactions...'),
              error: (err, st) => ErrorStateWidget(
                title: 'Error',
                description: err.toString(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddEditTransactionScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    return GestureDetector(
      onTap: () => setState(() => _filterType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: AppTypography.body2.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
