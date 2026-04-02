import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowfi/models/models.dart';
import 'package:flowfi/constants/app_theme.dart';
import 'package:flowfi/providers.dart';
import 'package:flowfi/widgets/widgets.dart';
import 'package:flowfi/utils/formatters.dart';

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final Transaction? transaction;

  const AddEditTransactionScreen({
    Key? key,
    this.transaction,
  }) : super(key: key);

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends ConsumerState<AddEditTransactionScreen> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late String _transactionType;
  late TransactionCategory _selectedCategory;
  late DateTime _selectedDate;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _amountController = TextEditingController(
        text: widget.transaction!.amount.toStringAsFixed(2),
      );
      _noteController = TextEditingController(text: widget.transaction!.note);
      _transactionType = widget.transaction!.type;
      _selectedCategory = widget.transaction!.categoryEnum;
      _selectedDate = widget.transaction!.date;
    } else {
      _amountController = TextEditingController();
      _noteController = TextEditingController();
      _transactionType = 'expense';
      _selectedCategory = TransactionCategory.food;
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _validateAndSave() async {
    setState(() => _amountError = null);

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _amountError = 'Please enter a valid amount');
      return;
    }

    final transactionService = ref.read(transactionServiceProvider);

    if (widget.transaction != null) {
      final updated = widget.transaction!.copyWith(
        amount: amount,
        type: _transactionType,
        category: _selectedCategory.toString().split('.').last,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );
      await transactionService.updateTransaction(updated);
    } else {
      final newTransaction = Transaction(
        amount: amount,
        type: _transactionType,
        category: _selectedCategory.toString().split('.').last,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );
      await transactionService.addTransaction(newTransaction);
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.transaction != null ? 'Transaction updated' : 'Transaction added',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseCategories = [
      TransactionCategory.food,
      TransactionCategory.transport,
      TransactionCategory.entertainment,
      TransactionCategory.utilities,
      TransactionCategory.shopping,
      TransactionCategory.health,
      TransactionCategory.education,
      TransactionCategory.other,
    ];

    final incomeCategories = [
      TransactionCategory.salary,
      TransactionCategory.freelance,
      TransactionCategory.investment,
      TransactionCategory.other,
    ];

    final categories = _transactionType == 'income' ? incomeCategories : expenseCategories;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        title: Text(
          widget.transaction != null ? 'Edit Transaction' : 'Add Transaction',
          style: AppTypography.headline2,
        ),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction Type Selector
            Text('Type', style: AppTypography.subtitle1),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _buildTypeButton(
                    label: 'Expense',
                    isSelected: _transactionType == 'expense',
                    onTap: () => setState(() => _transactionType = 'expense'),
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildTypeButton(
                    label: 'Income',
                    isSelected: _transactionType == 'income',
                    onTap: () => setState(() => _transactionType = 'income'),
                    color: AppColors.success,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Amount Input
            AmountInput(
              label: 'Amount',
              hint: '0.00',
              controller: _amountController,
              errorText: _amountError,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Category Selector
            CategorySelector(
              label: 'Category',
              categories: categories,
              selectedCategory: _selectedCategory,
              onChanged: (category) => setState(() => _selectedCategory = category),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Date Picker
            Text('Date', style: AppTypography.subtitle1),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormatter.formatDetailedDate(_selectedDate),
                      style: AppTypography.body1,
                    ),
                    Icon(Icons.calendar_today, color: AppColors.primary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Note Input
            Text('Note (Optional)', style: AppTypography.subtitle1),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _noteController,
              style: AppTypography.body1,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add a note...',
                hintStyle: AppTypography.body1.copyWith(color: AppColors.textTertiary),
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.md),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: PrimaryButton(
                    label: widget.transaction != null ? 'Update' : 'Add',
                    onPressed: _validateAndSave,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : AppColors.surfaceVariant,
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.subtitle1.copyWith(
            color: isSelected ? color : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
