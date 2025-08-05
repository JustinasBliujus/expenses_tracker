import '../../../Classes/expense.dart';
import '../../reusable/constants/app_colors.dart';
import '../../reusable/constants/app_constants.dart';
import '../../reusable/constants/text_styles.dart';
import '../functions/show_delete_dialog.dart';
import 'package:flutter/material.dart';

class HistoryListView extends StatelessWidget {
  final List<Expense> expenses;
  final Map<String, Color> categoryColors;
  final String Function(DateTime) formatDate;
  final VoidCallback refreshCallback;

  const HistoryListView({
    super.key,
    required this.expenses,
    required this.categoryColors,
    required this.formatDate,
    required this.refreshCallback,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        final color = categoryColors[expense.category] ?? AppColors.unknown;

        return ListTile(
          leading: Container(
            width: 16,
            height: 16,
            color: color,
            margin: const EdgeInsets.only(right: 8),
          ),
          title: Text(expense.category),
          subtitle: Text(formatDate(expense.date), style: TextStyles.small),
          trailing: Text('${AppConstants.currencySign}${expense.amount.toStringAsFixed(2)}'),
          onLongPress: () => showDeleteDialog(context, expense, refreshCallback),
        );
      },
    );
  }
}
