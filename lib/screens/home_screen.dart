import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowfi/constants/app_theme.dart';
import 'package:flowfi/providers.dart';
import 'package:flowfi/widgets/widgets.dart';
import 'package:flowfi/screens/add_edit_transaction_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(currentBalanceProvider);
    final income = ref.watch(totalIncomeProvider);
    final expenses = ref.watch(totalExpensesProvider);
    final savingProgress = ref.watch(savingProgressProvider);
    final insight = ref.watch(smartInsightProvider);
    final primaryGoal = ref.watch(primaryNoSpendGoalProvider);
    final weeklyTrend = ref.watch(weeklySpendingTrendProvider);
    final weekLabels = ref.watch(weekLabelsProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        title: Text('FlowFi', style: AppTypography.headline2),
        actions: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Icon(Icons.settings_rounded, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            balance.when(
              data: (balanceData) => income.when(
                data: (incomeData) => expenses.when(
                  data: (expensesData) => savingProgress.when(
                    data: (progressData) => BalanceCard(
                      balance: balanceData,
                      income: incomeData,
                      expenses: expensesData,
                      savingsProgress: progressData,
                    ),
                    loading: () => const LoadingWidget(message: 'Loading balance...'),
                    error: (err, st) => ErrorStateWidget(
                      title: 'Error',
                      description: err.toString(),
                    ),
                  ),
                  loading: () => const LoadingWidget(),
                  error: (err, st) => ErrorStateWidget(
                    title: 'Error',
                    description: err.toString(),
                  ),
                ),
                loading: () => const LoadingWidget(),
                error: (err, st) => ErrorStateWidget(
                  title: 'Error',
                  description: err.toString(),
                ),
              ),
              loading: () => const LoadingWidget(),
              error: (err, st) => ErrorStateWidget(
                title: 'Error',
                description: err.toString(),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Smart Insight
            insight.when(
              data: (insightText) => Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, color: AppColors.primary, size: 24),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        insightText,
                        style: AppTypography.body1.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(),
              error: (err, st) => const SizedBox(),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Primary Goal
            primaryGoal.when(
              data: (goal) {
                if (goal == null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Active Goal', style: AppTypography.headline3),
                      const SizedBox(height: AppSpacing.md),
                      EmptyState(
                        icon: '🎯',
                        title: 'No Active Goal',
                        description: 'Create a goal to track your progress',
                        actionLabel: 'Create Goal',
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Active Goal', style: AppTypography.headline3),
                    const SizedBox(height: AppSpacing.md),
                    GoalCard(
                      goal: goal,
                      onTap: () {
                        // Navigate to goal details
                      },
                    ),
                  ],
                );
              },
              loading: () => const SizedBox(),
              error: (err, st) => const SizedBox(),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Weekly Spending Chart
            Text('Weekly Spending', style: AppTypography.headline3),
            const SizedBox(height: AppSpacing.md),
            weeklyTrend.when(
              data: (trend) => weekLabels.when(
                data: (labels) => ChartCard(
                  title: 'This Week',
                  child: WeeklyChart(
                    data: trend,
                    labels: labels,
                  ),
                ),
                loading: () => const LoadingWidget(),
                error: (err, st) => ErrorStateWidget(
                  title: 'Error',
                  description: err.toString(),
                ),
              ),
              loading: () => const LoadingWidget(),
              error: (err, st) => ErrorStateWidget(
                title: 'Error',
                description: err.toString(),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Floating Action Button area info
            Center(
              child: Text(
                'Tap the + button to add a new transaction',
                style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
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
}
