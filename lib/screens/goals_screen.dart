import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowfi/models/models.dart';
import 'package:flowfi/constants/app_theme.dart';
import 'package:flowfi/providers.dart';
import 'package:flowfi/services/goal_service.dart';
import 'package:flowfi/widgets/widgets.dart';
import 'package:flowfi/utils/formatters.dart';

class GoalsScreenWidget extends ConsumerStatefulWidget {
  const GoalsScreenWidget({super.key});

  @override
  ConsumerState<GoalsScreenWidget> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreenWidget> {
  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(allGoalsProvider);
    final goalService = ref.read(goalServiceProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        title: Text('Goals & Challenges', style: AppTypography.headline2),
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return EmptyState(
              icon: '🎯',
              title: 'No Goals Yet',
              description: 'Create a goal to track your financial progress',
              actionLabel: 'Create Goal',
              onActionPressed: () => _showCreateGoalDialog(context, goalService),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Active Goals', style: AppTypography.headline3),
                const SizedBox(height: AppSpacing.sm),
                ...goals
                    .where((g) => g.isActive)
                    .map(
                      (goal) => Column(
                        children: [
                          GoalCard(
                            goal: goal,
                            onTap: () => _showGoalDetailDialog(context, goal, goalService),
                            onDelete: () async {
                              await goalService.deleteGoal(goal.id);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Goal deleted')),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    ),
                if (goals.any((g) => !g.isActive)) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text('Completed Goals', style: AppTypography.headline3),
                  const SizedBox(height: AppSpacing.sm),
                  ...goals
                      .where((g) => !g.isActive)
                      .map(
                        (goal) => Column(
                          children: [
                            GoalCard(
                              goal: goal,
                              onTap: () => _showGoalDetailDialog(context, goal, goalService),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        ),
                      ),
                ],
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Loading goals...'),
        error: (err, st) => ErrorStateWidget(
          title: 'Error',
          description: err.toString(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGoalDialog(context, goalService),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCreateGoalDialog(BuildContext context, GoalService goalService) {
    showDialog(
      context: context,
      builder: (_) => _CreateGoalDialog(onGoalCreated: (goal) async {
        await goalService.addGoal(goal);
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Goal created')),
          );
        }
      }),
    );
  }

  void _showGoalDetailDialog(BuildContext context, Goal goal, GoalService goalService) {
    showDialog(
      context: context,
      builder: (_) => _GoalDetailDialog(
        goal: goal,
        onIncrementDay: () async {
          final updatedGoal = goal.copyWith(
            currentDays: goal.currentDays + 1,
          );
          await goalService.updateGoal(updatedGoal);
          if (context.mounted) Navigator.of(context).pop();
        },
        onResetStreak: () async {
          final updatedGoal = goal.copyWith(
            currentDays: 0,
            lastResetDate: DateTime.now(),
          );
          await goalService.updateGoal(updatedGoal);
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _CreateGoalDialog extends StatefulWidget {
  final Function(Goal) onGoalCreated;

  const _CreateGoalDialog({required this.onGoalCreated});

  @override
  State<_CreateGoalDialog> createState() => _CreateGoalDialogState();
}

class _CreateGoalDialogState extends State<_CreateGoalDialog> {
  final _nameController = TextEditingController();
  final _daysController = TextEditingController(text: '7');
  String _goalType = 'noSpendChallenge';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Create New Goal', style: AppTypography.headline3),
            const SizedBox(height: AppSpacing.lg),

            // Goal Type
            Text('Goal Type', style: AppTypography.subtitle1),
            const SizedBox(height: AppSpacing.sm),
            DropdownButton<String>(
              value: _goalType,
              isExpanded: true,
              items: [
                DropdownMenuItem(
                  value: 'noSpendChallenge',
                  child: Text('No-Spend Challenge', style: AppTypography.body1),
                ),
                DropdownMenuItem(
                  value: 'savingsTarget',
                  child: Text('Savings Target', style: AppTypography.body1),
                ),
                DropdownMenuItem(
                  value: 'budgetLimit',
                  child: Text('Budget Limit', style: AppTypography.body1),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _goalType = value);
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Goal Name
            Text('Goal Name', style: AppTypography.subtitle1),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _nameController,
              style: AppTypography.body1,
              decoration: InputDecoration(
                hintText: 'e.g., 7-Day No-Spend Challenge',
                hintStyle: AppTypography.body1.copyWith(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.md),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Target Days
            Text('Target Days', style: AppTypography.subtitle1),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _daysController,
              keyboardType: TextInputType.number,
              style: AppTypography.body1,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.md),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: AppTypography.button.copyWith(color: AppColors.primary)),
                ),
                const SizedBox(width: AppSpacing.md),
                TextButton(
                  onPressed: () {
                    final name = _nameController.text.trim();
                    final days = int.tryParse(_daysController.text.trim()) ?? 7;

                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a goal name')),
                      );
                      return;
                    }

                    final goal = Goal(
                      name: name,
                      type: _goalType,
                      targetDays: days.clamp(1, 365),
                    );

                    widget.onGoalCreated(goal);
                  },
                  child: Text('Create', style: AppTypography.button.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _daysController.dispose();
    super.dispose();
  }
}

class _GoalDetailDialog extends StatelessWidget {
  final Goal goal;
  final VoidCallback onIncrementDay;
  final VoidCallback onResetStreak;

  const _GoalDetailDialog({
    required this.goal,
    required this.onIncrementDay,
    required this.onResetStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(goal.name, style: AppTypography.headline3),
            const SizedBox(height: AppSpacing.md),

            // Progress
            Text('Progress', style: AppTypography.subtitle2),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: goal.progressPercentage,
                minHeight: 10,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Days Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current', style: AppTypography.caption),
                    Text('${goal.currentDays} days', style: AppTypography.subtitle1),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Target', style: AppTypography.caption),
                    Text('${goal.targetDays} days', style: AppTypography.subtitle1),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Info
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Started: ${DateFormatter.formatDetailedDate(goal.startDate)}',
                    style: AppTypography.body2,
                  ),
                  if (goal.lastResetDate != null)
                    Text(
                      'Last reset: ${DateFormatter.formatDetailedDate(goal.lastResetDate!)}',
                      style: AppTypography.body2,
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Buttons
            Row(
              children: [
                if (!goal.isCompleted)
                  Expanded(
                    child: GestureDetector(
                      onTap: onResetStreak,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          border: Border.all(color: AppColors.error),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Reset',
                          style: AppTypography.button.copyWith(color: AppColors.error),
                        ),
                      ),
                    ),
                  ),
                if (!goal.isCompleted) const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: GestureDetector(
                    onTap: onIncrementDay,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        goal.isCompleted ? 'Done!' : '+1 Day',
                        style: AppTypography.button,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  'Close',
                  style: AppTypography.button.copyWith(color: AppColors.primary),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
