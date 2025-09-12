import 'package:expenses_tracker/Classes/expense.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:expenses_tracker/helperFunctions/aggregate_expenses_by_category.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

class StyledPieChart extends StatefulWidget {
  final List<Expense> expenses;
  final Map<String, Color> categoryColors;

  const StyledPieChart({
    required this.expenses,
    super.key,
    required this.categoryColors,
  });

  @override
  State<StyledPieChart> createState() => _StyledPieChartState();
}

class _StyledPieChartState extends State<StyledPieChart> {
  int? touchIndex;

  @override
  Widget build(BuildContext context) {
    final dataMap = aggregateExpensesByCategory(widget.expenses);
    final total = dataMap.values.isNotEmpty
        ? dataMap.values.reduce((a, b) => a + b)
        : 0;

    if (total == 0) {
      return const Center(child: Text("No expenses yet",style: TextStyles.dataMissing,));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final minSide = size.shortestSide;
        final chartRadius = minSide / 5.3;
        final centerSpace = minSide / 3.5;
        final fontSizeCenter = centerSpace / 2;
        final fontSizeRadius = chartRadius / 3.5;

        return Stack(
          children: [
            PieChart(
              PieChartData(
                centerSpaceRadius: centerSpace,
                sections: dataMap.entries.map((entry) {
                  final index = dataMap.keys.toList().indexOf(entry.key);
                  final category = entry.key;
                  final amount = entry.value;

                  final percentage =
                      '${(amount / total * 100).toStringAsFixed(1)}%';

                  return PieChartSectionData(
                    color: widget.categoryColors[category] ?? AppColors.unknown,
                    value: amount,
                    title: percentage,
                    radius: touchIndex == index
                        ? chartRadius * 1.1
                        : chartRadius,
                    titleStyle: TextStyle(
                      fontSize: fontSizeRadius,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                pieTouchData: PieTouchData(
                  enabled: true,
                  touchCallback: (event, response) {
                    setState(() {
                      touchIndex = response?.touchedSection
                          ?.touchedSectionIndex;
                    });
                  },
                ),
              ),
              duration: const Duration(milliseconds: 80),
            ),
            Positioned.fill(
              child: Center(
                child: Builder(builder: (_) {
                  final totalText = '${AppConstants.currencySign}${total.toStringAsFixed(1)}';
                  final centerDigitCount = totalText.length;
                  return Text(
                    totalText,
                    style: TextStyle(
                      fontSize: (fontSizeCenter -
                          ((centerDigitCount ~/ 2) * 4))
                          .clamp(8.0, fontSizeCenter),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}
