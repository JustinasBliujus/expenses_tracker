import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Classes/expense.dart';
import '../../classes/category.dart';
import '../../services/auth.dart';
import '../../services/database.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Auth().currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not signed in')),
      );
    }

    final databaseService = DatabaseService(uid: user.uid);

    return Scaffold(
      appBar: AppBar(),
      drawer: const NavigationDrawerCustom(),
      body: StreamProvider<List<Category>>.value(
        initialData: const [],
        value: databaseService.categories,
        catchError: (_, __) => [],
        child: const HistoryListView(),
      ),
    );
  }
}

class HistoryListView extends StatefulWidget {
  const HistoryListView({super.key});

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<List<Category>>(context);
    final databaseService = DatabaseService(uid: Auth().currentUser!.uid);
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    double lPadding = isPortrait ? 0 : 70;
    double rPadding = lPadding;

    final categoryColors = {
      for (var cat in categories) cat.category: cat.colorFromString()
    };

    if (categories.isEmpty) {
      return const Center(child: Text('No History Found',style: TextStyles.dataMissing,));
    }

    return FutureBuilder<List<Expense>>(
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
          padding: EdgeInsets.fromLTRB(lPadding,0,rPadding,0),
          child: ListView.builder(
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
                subtitle: Text(formatDate(expense.date),
                    style: TextStyles.small),
                trailing: Text('\$${expense.amount.toStringAsFixed(2)}'),
                onLongPress: () => showDeleteDialog(context, expense),
              );
            },
          ),
        );
      },
    );
  }

  void showDeleteDialog(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Expense',),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: <Widget>[
            StyledActionButton(
              onPressed: () async {
                final db = DatabaseService(uid: Auth().currentUser!.uid);
                await db.deleteExpenseFromCategory(expense.category, expense.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      duration: AppConstants.snackBarDuration,
                      content: Text('Expense deleted successfully'),
                      backgroundColor: AppColors.affirmative),
                );
                setState(() {

                });
              },
              buttonColor: AppColors.error,
              buttonText: "Yes",
            ),
          ],
        );
      },
    );
  }
}
