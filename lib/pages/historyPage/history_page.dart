import 'package:expenses_tracker/pages/historyPage/widgets/history_list_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Classes/expense.dart';
import '../../classes/category.dart';
import '../../services/auth.dart';
import '../../services/database.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {

    return Consumer<List<Category>>(
      builder: (context, categories, child) {

        final databaseService = DatabaseService(uid: Auth().currentUser!.uid);

        var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
        double lPadding = isPortrait ? 0 : 70;
        double rPadding = lPadding;

        final categoryColors = {
          for (var cat in categories)
            cat.category: cat.colorFromString(),
        };

        if (categories.isEmpty) {
          return  Scaffold(
            appBar: AppBar(),
            drawer: NavigationDrawerCustom(),
            body: Center(
              child: Text(
                'No History Found',
                style: TextStyles.dataMissing,
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(),
          drawer: const NavigationDrawerCustom(),
          body: FutureBuilder<List<Expense>>(
            future: databaseService.fetchAllExpenses(categories),
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: StyledCircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No expenses found.', style: TextStyles.dataMissing),
                );
              }

              final expenses = snapshot.data!;
              expenses.sort((a, b) => b.date.compareTo(a.date));

              String formatDate(DateTime date) {
                final formatter = DateFormat('MMMM d, yyyy h:mm a');
                return formatter.format(date);
              }

              return Padding(
                padding: EdgeInsets.fromLTRB(lPadding, 0, rPadding, 0),
                child: HistoryListView(
                  expenses: expenses,
                  categoryColors: categoryColors,
                  formatDate: formatDate,
                  refreshCallback: () {
                    setState(() {});
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

