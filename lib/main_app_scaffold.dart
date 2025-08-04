import 'package:expenses_tracker/pages/addExpensePage/add_expense_page.dart';
import 'package:expenses_tracker/pages/historyPage/history_page.dart';
import 'package:expenses_tracker/pages/manageCategoriesPage/manage_categories_page.dart';
import 'package:expenses_tracker/pages/overviewPage/overview_page.dart';
import 'package:flutter/material.dart';

class MainAppScaffold extends StatelessWidget {
  const MainAppScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eTracker',
      initialRoute: '/overview',
      routes: {
        '/overview': (context) => const OverviewPage(),
        '/manageCategories': (context) => const ManageCategoriesPage(),
        '/addExpense': (context) => const AddExpensePage(),
        '/history': (context) => const HistoryPage()
      },
    );
  }
}
