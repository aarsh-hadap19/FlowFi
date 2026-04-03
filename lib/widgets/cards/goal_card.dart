import 'package:flutter/material.dart';
import 'package:flowfi/models/models.dart';
import 'package:flowfi/constants/app_theme.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const GoalCard({
    Key? key,
    required this.goal,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  String _getGoalEmoji() {
    switch (goal.type) {
      case 'noSpendChallenge':
        return '🎯';
      case 'savingsTarget':
        return '🏦';
      case 'budgetLimit':
        return '💰';
      default:
        return '📌';
    }
  }

  Color _getGoalColor() {
    if (goal.isCompleted) return AppColors.success;
    if (goal.progressPercentage > 0.5) return AppColors.primary;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getGoalColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  alignment: Alignment.center,
                  child: Text(_getGoalEmoji(), style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.name, style: AppTypography.subtitle1),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${goal.currentDays}/${goal.targetDays} days',
                        style: AppTypography.body2,
                      ),
                    ],
                  ),
                ),
                if (goal.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      'Done',
                      style: AppTypography.caption.copyWith(color: Colors.white),
                    ),
                  ),
                if (onDelete != null)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.md),
                    child: GestureDetector(
                      onTap: onDelete,
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.error,
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: goal.progressPercentage,
                minHeight: 8,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
