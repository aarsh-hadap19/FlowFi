import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flowfi/constants/app_theme.dart';

class CategoryPieChart extends StatefulWidget {
  final Map<String, double> categoryData;

  const CategoryPieChart({
    Key? key,
    required this.categoryData,
  }) : super(key: key);

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int _touchedIndex = -1;

  final List<Color> _colors = const [
    AppColors.categoryFood,
    AppColors.categoryTransport,
    AppColors.categoryEntertainment,
    AppColors.categoryUtilities,
    AppColors.categoryShopping,
    AppColors.categoryHealth,
    AppColors.categoryEducation,
    AppColors.primary,
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.categoryData.isEmpty) {
      return Center(
        child: Text(
          'No spending data available',
          style: AppTypography.body2,
        ),
      );
    }

    final total = widget.categoryData.values.fold<double>(0, (sum, val) => sum + val);
    final sortedEntries = widget.categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              centerSpaceRadius: 40,
              sections: List.generate(
                sortedEntries.length,
                (index) {
                  final entry = sortedEntries[index];
                  final isTouched = index == _touchedIndex;
                  final fontSize = isTouched ? 16.0 : 12.0;
                  final radius = isTouched ? 60.0 : 50.0;
                  final value = (entry.value / total * 100);

                  return PieChartSectionData(
                    color: _colors[index % _colors.length],
                    value: entry.value,
                    title: '${value.toStringAsFixed(0)}%',
                    radius: radius,
                    titleStyle: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.md,
          children: List.generate(
            sortedEntries.length,
            (index) {
              final entry = sortedEntries[index];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _colors[index % _colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: AppTypography.caption,
                      ),
                      Text(
                        '\$${entry.value.toStringAsFixed(2)}',
                        style: AppTypography.body2.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
