import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowfi/constants/app_theme.dart';
import 'package:flowfi/providers.dart';
import 'package:flowfi/widgets/widgets.dart';
import 'package:flowfi/utils/formatters.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highestCategory = ref.watch(highestSpendingCategoryProvider);
    final weeklyComparison = ref.watch(weeklyComparisonProvider);
    final spendingByCategory = ref.watch(spendingByCategoryProvider);
    final dailyAverage = ref.watch(dailyAverageSpendingProvider);
    final frequentType = ref.watch(frequentTransactionTypeProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        title: Text('Insights', style: AppTypography.headline2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Highest Spending Category
            Text('Top Spending Category', style: AppTypography.headline3),
            const SizedBox(height: AppSpacing.md),
            highestCategory.when(
              data: (category) {
                final emoji = _getCategoryEmoji(category);
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              StringFormatter.formatCategory(category),
                              style: AppTypography.subtitle1.copyWith(color: AppColors.primary),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Your most spent category',
                              style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const LoadingWidget(),
              error: (err, st) => ErrorStateWidget(
                title: 'Error',
                description: err.toString(),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Weekly Comparison
            Text('Weekly Trend', style: AppTypography.headline3),
            const SizedBox(height: AppSpacing.md),
            weeklyComparison.when(
              data: (comparison) {
                final thisWeek = comparison['thisWeek'] as double;
                final lastWeek = comparison['lastWeek'] as double;
                final diff = comparison['difference'] as double;
                final isHigher = diff > 0;

                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('This Week', style: AppTypography.caption),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                CurrencyFormatter.formatAmount(thisWeek),
                                style: AppTypography.subtitle1,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Last Week', style: AppTypography.caption),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                CurrencyFormatter.formatAmount(lastWeek),
                                style: AppTypography.subtitle1,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isHigher ? AppColors.error.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isHigher ? Icons.trending_up : Icons.trending_down,
                              color: isHigher ? AppColors.error : AppColors.success,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                isHigher
                                    ? 'Higher by ${CurrencyFormatter.formatAmount(diff.abs())}'
                                    : 'Lower by ${CurrencyFormatter.formatAmount(diff.abs())}',
                                style: AppTypography.body1.copyWith(
                                  color: isHigher ? AppColors.error : AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const LoadingWidget(),
              error: (err, st) => ErrorStateWidget(
                title: 'Error',
                description: err.toString(),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Daily Average
            Text('Daily Average', style: AppTypography.headline3),
            const SizedBox(height: AppSpacing.md),
            dailyAverage.when(
              data: (average) => Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  children: [
                    Text(
                      CurrencyFormatter.formatAmount(average),
                      style: AppTypography.headline2,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Spent per day on average',
                      style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              loading: () => const LoadingWidget(),
              error: (err, st) => ErrorStateWidget(
                title: 'Error',
                description: err.toString(),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Category Breakdown
            Text('Spending by Category', style: AppTypography.headline3),
            const SizedBox(height: AppSpacing.md),
            spendingByCategory.when(
              data: (categoryData) {
                if (categoryData.isEmpty) {
                  return EmptyState(
                    icon: '📊',
                    title: 'No Data',
                    description: 'Add some expenses to see your spending by category',
                  );
                }

                return ChartCard(
                  title: 'Breakdown',
                  child: CategoryPieChart(categoryData: categoryData),
                );
              },
              loading: () => const LoadingWidget(),
              error: (err, st) => ErrorStateWidget(
                title: 'Error',
                description: err.toString(),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // More Insights
            Text('More Stats', style: AppTypography.headline3),
            const SizedBox(height: AppSpacing.md),
            frequentType.when(
              data: (type) => Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Most Frequent', style: AppTypography.caption),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          type,
                          style: AppTypography.subtitle1,
                        ),
                      ],
                    ),
                    Icon(
                      type == 'Income' ? Icons.trending_up : Icons.trending_down,
                      color: type == 'Income' ? AppColors.success : AppColors.error,
                      size: 32,
                    ),
                  ],
                ),
              ),
              loading: () => const LoadingWidget(),
              error: (err, st) => ErrorStateWidget(
                title: 'Error',
                description: err.toString(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'food':
        return '🍔';
      case 'transport':
        return '🚗';
      case 'entertainment':
        return '🎬';
      case 'utilities':
        return '💡';
      case 'shopping':
        return '🛍️';
      case 'health':
        return '🏥';
      case 'education':
        return '📚';
      case 'salary':
        return '💼';
      case 'freelance':
        return '💻';
      case 'investment':
        return '📈';
      default:
        return '📌';
    }
  }
}
