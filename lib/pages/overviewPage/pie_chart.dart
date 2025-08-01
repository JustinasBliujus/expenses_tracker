import 'package:expenses_tracker/Classes/expense.dart';
import 'package:expenses_tracker/services/database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:expenses_tracker/helperFunctions/aggregate_expenses_by_category.dart';

class ExpensePieChart extends StatefulWidget {
  final List<Expense> expenses;
  final Map<String, Color> categoryColors;

  const ExpensePieChart({
    required this.expenses,
    super.key,
    required this.categoryColors,
  });

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int? touchIndex;

  @override
  Widget build(BuildContext context) {
    final dataMap = aggregateExpensesByCategory(widget.expenses);
    final total = dataMap.values.isNotEmpty ? dataMap.values.reduce((a, b) => a + b) : 0;

    if (total == 0) {
      return const Center(child: Text("No expenses yet"));
    }

    return Stack(
      children: [
        PieChart(
          PieChartData(
            centerSpaceRadius: 105,
            sections: dataMap.entries.map((entry) {
              final index = dataMap.keys.toList().indexOf(entry.key);
              final category = entry.key;
              final amount = entry.value;
              final percentage = (amount / total * 100).toStringAsFixed(1);

              return PieChartSectionData(
                color: widget.categoryColors[category] ?? Colors.grey,
                value: amount,
                title: '$percentage%',
                radius: touchIndex == index ? 70 : 60,
                titleStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }).toList(),
            sectionsSpace: 2,
            pieTouchData: PieTouchData(
              enabled: true,
              touchCallback: (event, response) {
                if (response != null && response.touchedSection != null) {
                  setState(() {
                    touchIndex = response.touchedSection!.touchedSectionIndex;
                  });
                } else {
                  setState(() {
                    touchIndex = null;
                  });
                }
              },
            ),
          ),
          swapAnimationDuration: const Duration(milliseconds: 80),
        ),
        Positioned.fill(
          child: Center(
            child: Text(
              '\$${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
