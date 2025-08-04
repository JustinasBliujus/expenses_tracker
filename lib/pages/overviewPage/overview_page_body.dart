import 'package:expenses_tracker/classes/category.dart';
import 'package:expenses_tracker/pages/manageCategoriesPage/manage_categories_page.dart';
import 'package:expenses_tracker/pages/overviewPage/styled_pie_chart.dart';
import 'package:expenses_tracker/helperFunctions/aggregate_expenses_by_category.dart';
import 'package:expenses_tracker/services/auth.dart';
import 'package:expenses_tracker/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Classes/expense.dart';
import '../../helperFunctions/filter_expenses_by_period.dart';
import '../addExpensePage/add_expense_page.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

class OverviewPageBody extends StatefulWidget {
  const OverviewPageBody({super.key});

  @override
  State<OverviewPageBody> createState() => _OverviewPageBodyState();
}

class _OverviewPageBodyState extends State<OverviewPageBody> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 4,
      child: Builder(builder: (context) {
        final categories = Provider.of<List<Category>>(context);
        final hasCategories = categories.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            bottom: TabBar(
              dividerColor: AppColors.unknown,
              unselectedLabelColor: AppColors.unknown,
              labelColor: AppColors.main,
              indicatorColor: AppColors.main,
              overlayColor: WidgetStateProperty.all<Color>(AppColors.unknown),
              tabs: const [
                Tab(text: "Total"),
                Tab(text: "Daily"),
                Tab(text: "Weekly"),
                Tab(text: "Monthly"),
              ],
            ),
          ),
          body: const TabBarView(
            children: <Widget>[
              TabBarViewPage(durationType: 0),
              TabBarViewPage(durationType: 1),
              TabBarViewPage(durationType: 2),
              TabBarViewPage(durationType: 3),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: hasCategories ? AppColors.affirmative : AppColors.unknown,
            foregroundColor: AppColors.opposite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onPressed: () {
              if (hasCategories) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const AddExpensePage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    duration: AppConstants.snackBarDuration,
                    content: Text("Please add a category first."),
                    backgroundColor: AppColors.suggestion,
                  ),
                );
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const ManageCategoriesPage()),
                );
              }
            },
            child: const Icon(Icons.add),
          ),
        );
      }),
    );
  }
}

class TabBarViewPage extends StatefulWidget {
  final int durationType;

  const TabBarViewPage({super.key, required this.durationType});

  @override
  State<TabBarViewPage> createState() => _TabBarViewPageState();
}

class _TabBarViewPageState extends State<TabBarViewPage> {
  @override
  Widget build(BuildContext context) {
    final user = Auth().currentUser;
    if (user == null) return const Center(child: Text("User not signed in"));

    final db = DatabaseService(uid: user.uid);

    return Consumer<List<Category>>(
      builder: (context, categories, _) {
        final categoryColors = {
          for (var cat in categories) cat.category: cat.colorFromString(),
        };
        return FutureBuilder<List<Expense>>(
          future: db.fetchAllExpenses(categories),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: StyledCircularProgressIndicator());
            }

            final allExpenses = snapshot.data!;
            final filteredExpenses = filterExpensesByPeriod(allExpenses, widget.durationType);
            final dataMap = aggregateExpensesByCategory(filteredExpenses);

            return ExpenseOverview(
              filteredExpenses: filteredExpenses,
              categoryColors: categoryColors,
              dataMap: dataMap,
            );
          },
        );
      },
    );
  }
}

class ExpenseOverview extends StatelessWidget {
  final List<Expense> filteredExpenses;
  final Map<String, Color> categoryColors;
  final Map<String, double> dataMap;

  const ExpenseOverview({
    super.key,
    required this.filteredExpenses,
    required this.categoryColors,
    required this.dataMap,
  });

  @override
  Widget build(BuildContext context) {
    final totals = dataMap.entries.toList();

    final bool noExpenses = filteredExpenses.isEmpty;

    final pieChartWidget = StyledPieChart(expenses: filteredExpenses, categoryColors: categoryColors);

    final listViewWidget = ListView.builder(
      itemCount: totals.length,
      itemBuilder: (context, index) {
        final entry = totals[index];
        final color = categoryColors[entry.key] ?? AppColors.unknown;
        return ListTile(
          leading: Container(
            width: 16,
            height: 16,
            color: color,
            margin: const EdgeInsets.only(right: 8),
          ),
          title: Text(entry.key),
          trailing: Text('\$${entry.value.toStringAsFixed(2)}'),
        );
      },
    );

    return OrientationBuilder(
      builder: (context, orientation) {
        if (noExpenses) {
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
  }

}
