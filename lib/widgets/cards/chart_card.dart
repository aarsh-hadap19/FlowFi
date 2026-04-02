import 'package:flutter/material.dart';
import 'package:flowfi/constants/app_theme.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onTap;

  const ChartCard({
    Key? key,
    required this.title,
    required this.child,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.headline3),
              if (onTap != null)
                GestureDetector(
                  onTap: onTap,
                  child: Icon(
                    Icons.more_horiz,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}
