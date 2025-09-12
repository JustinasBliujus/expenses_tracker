import 'package:expenses_tracker/classes/category.dart';
import 'package:expenses_tracker/helperFunctions/get_category_colors.dart';
import 'package:expenses_tracker/pages/overviewPage/widgets/expense_list_view.dart';
import 'package:expenses_tracker/pages/overviewPage/widgets/styled_pie_chart.dart';
import 'package:expenses_tracker/helperFunctions/aggregate_expenses_by_category.dart';
import 'package:expenses_tracker/services/auth.dart';
import 'package:expenses_tracker/services/database.dart';
import 'package:flutter/material.dart';
import '../../../Classes/expense.dart';
import '../../../helperFunctions/filter_expenses_by_period.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

class TabBarViewPage extends StatefulWidget {
  final int durationType;
  final List<Category> categories;

  const TabBarViewPage({super.key, required this.durationType, required this.categories});

  @override
  State<TabBarViewPage> createState() => _TabBarViewPageState();
}

class _TabBarViewPageState extends State<TabBarViewPage> {
  @override
  Widget build(BuildContext context) {
    final user = Auth().currentUser;
    if (user == null) return const Center(child: Text("User not signed in",style: TextStyles.dataMissing,));
    final db = DatabaseService(uid: user.uid);

    var isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return FutureBuilder<List<Expense>>(
      future: db.fetchAllExpenses(widget.categories),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: StyledCircularProgressIndicator());
        }
        // filter expenses based on chosen time period
        final filteredExpenses = filterExpensesByPeriod(snapshot.data!, widget.durationType);
        // aggregate expenses into by categories
        final totals = aggregateExpensesByCategory(filteredExpenses).entries.toList();
        //pie chart widget to be used in orientation builder
        final pieChartWidget = StyledPieChart(
            expenses: filteredExpenses,
            categoryColors: getCategoryColors(widget.categories)
        );
        //expense list view widget to be used in orientation builder
        final listViewWidget = ExpenseListView(
          totals: totals,
          categoryColors: getCategoryColors(widget.categories),
          isLandscape: isLandscape,
        );

        return OrientationBuilder(
          builder: (context, orientation) {
            if (filteredExpenses.isEmpty) {
              return Center(
                child: Text(
                  'No Expenses to Track Yet',
                  style: TextStyles.dataMissing,
                  textAlign: TextAlign.center,
                ),
              );
            }
            if (orientation == Orientation.portrait) {
              return Column(
                children: [
                  SizedBox(height: 400, child: pieChartWidget),
                  Expanded(child: listViewWidget),
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(child: pieChartWidget),
                  Expanded(child: listViewWidget),
                ],
              );
            }
          },
        );
      },
    );
  }
}


