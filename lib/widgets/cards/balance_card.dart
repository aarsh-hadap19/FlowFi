import 'package:flutter/material.dart';
import 'package:flowfi/constants/app_theme.dart';
import 'package:flowfi/utils/formatters.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expenses;

  const BalanceCard({
    Key? key,
    required this.balance,
    required this.income,
    required this.expenses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Balance',
            style: AppTypography.subtitle2.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            CurrencyFormatter.formatAmount(balance),
            style: AppTypography.headline1.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _StatItem(
                label: 'Income',
                amount: income,
                color: AppColors.success,
              ),
              const Spacer(),
              _StatItem(
                label: 'Expenses',
                amount: expenses,
                color: AppColors.error,
              ),
            ],
          ),

        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _StatItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          CurrencyFormatter.formatAmount(amount),
          style: AppTypography.subtitle1.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}
