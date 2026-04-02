import 'package:flutter/material.dart';
import 'package:flowfi/models/transaction.dart';
import 'package:flowfi/constants/app_theme.dart';

class CategorySelector extends StatefulWidget {
  final String label;
  final List<TransactionCategory> categories;
  final TransactionCategory? selectedCategory;
  final ValueChanged<TransactionCategory> onChanged;
  final String? errorText;

  const CategorySelector({
    Key? key,
    required this.label,
    required this.categories,
    this.selectedCategory,
    required this.onChanged,
    this.errorText,
  }) : super(key: key);

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  late TransactionCategory _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedCategory ?? widget.categories.first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTypography.subtitle1),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: widget.categories.map((category) {
            final isSelected = _selected == category;
            return GestureDetector(
              onTap: () {
                setState(() => _selected = category);
                widget.onChanged(category);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      category.displayName,
                      style: AppTypography.body2.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.errorText!,
            style: AppTypography.caption.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
