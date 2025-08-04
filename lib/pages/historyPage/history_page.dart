import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Classes/expense.dart';
import '../../classes/category.dart';
import '../../services/auth.dart';
import '../../services/database.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

import '../../services/network_controller.dart';

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
                      subtitle: Text(formatDate(expense.date), style: TextStyles.small),
                      trailing: Text('\$${expense.amount.toStringAsFixed(2)}'),
                      onLongPress: () => showDeleteDialog(context, expense),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  void showDeleteDialog(BuildContext context, Expense expense) {
    final NetworkController networkController = Get.find();
    bool requestIsFresh = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: <Widget>[
            StyledActionButton(
              onPressed: () async {
                final db = DatabaseService(uid: Auth().currentUser!.uid);
                if (!networkController.isOnline.value) {
                  Get.rawSnackbar(
                    message: 'You are offline. Changes will be cached locally.',
                    backgroundColor: AppColors.error,
                    snackPosition: SnackPosition.BOTTOM,
                    duration: AppConstants.snackBarDurationLonger,
                    icon: Icon(Icons.wifi_off, color: AppColors.opposite),
                  );
                  requestIsFresh = false;//to prevent snack bar queueing when offline
                  setState(() {});
                }
                Navigator.of(context).pop();
                await db.deleteExpenseFromCategory(expense.category, expense.id);
                if(requestIsFresh){
                  Get.rawSnackbar(
                    message: 'Expense deleted successfully',
                    backgroundColor: AppColors.affirmative,
                    snackPosition: SnackPosition.BOTTOM,
                    duration: AppConstants.snackBarDuration,
                  );
                }
                setState(() {});  // refresh UI after deletion
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

