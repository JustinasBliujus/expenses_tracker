import 'package:expenses_tracker/pages/overviewPage/widgets/tab_bar_view_page.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../classes/category.dart';
import '../addExpensePage/add_expense_page.dart';
import '../manageCategoriesPage/manage_categories_page.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {

  @override
  Widget build(BuildContext context) {
    var isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: DefaultTabController(
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
          body: TabBarView(
            children: <Widget>[
              TabBarViewPage(durationType: 0, categories: categories),
              TabBarViewPage(durationType: 1, categories: categories),
              TabBarViewPage(durationType: 2, categories: categories),
              TabBarViewPage(durationType: 3, categories: categories),
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
          floatingActionButtonLocation: isLandscape ? FloatingActionButtonLocation.endFloat
              : FloatingActionButtonLocation.centerFloat,
        );
      }),
    ),
      appBar: AppBar(),
      drawer: const NavigationDrawerCustom(),
    );
  }
}
