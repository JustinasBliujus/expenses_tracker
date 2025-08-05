import 'package:flutter/material.dart';

import '../../reusable/constants/app_constants.dart';

class ExpenseListView extends StatelessWidget {
  final List<MapEntry<String, double>> totals;
  final Map<String, Color> categoryColors;
  final bool isLandscape;

  const ExpenseListView({
    super.key,
    required this.totals,
    required this.categoryColors,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: totals.length,
      itemBuilder: (context, index) {
        final entry = totals[index];
        final color = categoryColors[entry.key] ?? Colors.grey;

        return Padding(
          padding: isLandscape ? const EdgeInsets.fromLTRB(0, 0, 85, 0) : EdgeInsets.zero,
          child: ListTile(
            leading: Container(
              width: 16,
              height: 16,
              color: color,
              margin: const EdgeInsets.only(right: 8),
            ),
            title: Text(entry.key),
            trailing: Text('${AppConstants.currencySign}${entry.value.toStringAsFixed(2)}'),
          ),
        );
      },
    );
  }
}
