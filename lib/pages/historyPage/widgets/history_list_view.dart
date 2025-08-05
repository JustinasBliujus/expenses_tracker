import '../../../Classes/expense.dart';
import '../../../classes/category.dart';
import '../../../helperFunctions/format_date.dart';
import '../../../helperFunctions/get_category_colors.dart';
import '../../../services/auth.dart';
import '../../../services/database.dart';
import '../../reusable/constants/app_colors.dart';
import '../../reusable/constants/app_constants.dart';
import '../../reusable/constants/text_styles.dart';
import '../../reusable/widgets/styled_circular_progress_indicator.dart';
import '../functions/show_delete_dialog.dart';
import 'package:flutter/material.dart';

class HistoryListView extends StatelessWidget {
  final List<Category> categories;
  final VoidCallback refreshCallback;

  const HistoryListView({
    super.key,
    required this.categories,
    required this.refreshCallback,
  });

  @override
  Widget build(BuildContext context) {

    final databaseService = DatabaseService(uid: Auth().currentUser!.uid);

    final categoryColors = getCategoryColors(categories);

    return FutureBuilder<List<Expense>>(
      future: databaseService.fetchAllExpenses(categories),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: StyledCircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}',style: TextStyles.dataMissing,));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No expenses found',style: TextStyles.dataMissing,));
        }

        final expenses = snapshot.data!;
        expenses.sort((a, b) => b.date.compareTo(a.date));

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
              trailing: Text(
                '${AppConstants.currencySign}${expense.amount.toStringAsFixed(2)}',
              ),
              onLongPress: () => showDeleteDialog(context, expense, refreshCallback),
            );
          },
        );
      },
    );
  }
}

