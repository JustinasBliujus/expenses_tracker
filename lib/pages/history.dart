import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses_tracker/Services/auth.dart';
import 'package:expenses_tracker/Services/database.dart';
import 'package:expenses_tracker/Pages/reusableWidgets/navigation_drawer.dart';
import 'package:intl/intl.dart';
import 'package:expenses_tracker/Classes/expense.dart';
import 'package:expenses_tracker/Classes/category.dart';

class History extends StatelessWidget {
  const History({super.key});

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
      body: MultiProvider(
        providers: [
          StreamProvider<QuerySnapshot?>.value(
            initialData: null,
            value: databaseService.expenses,
            catchError: (_, __) => null,
          ),
          StreamProvider<List<Category>>.value(
            initialData: const [],
            value: databaseService.categories,
            catchError: (_, __) => [],
          ),
        ],
        child: const HistoryListView(),
      ),
    );
  }
}

class HistoryListView extends StatelessWidget {
  const HistoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    final expensesSnapshot = Provider.of<QuerySnapshot?>(context);
    final categories = Provider.of<List<Category>>(context);

    if (expensesSnapshot == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (expensesSnapshot.docs.isEmpty) {
      return const Center(child: Text('No expenses found.',style: TextStyle(fontSize: 20),));
    }

    final expenses = expensesSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Expense.fromMap(data,doc.id);
    }).toList();

    expenses.sort((a, b) => b.date.compareTo(a.date));

    // Map categories to their color
    final categoryColors = { for (var item in categories) item.category : item.colorFromString() };

    String formatDate(DateTime date) {
      final formatter = DateFormat('MMMM d, yyyy h:mm a');
      return formatter.format(date);
    }

    // Function to delete an expense
    Future<void> deleteExpense(BuildContext context, String expenseId) async {
      final databaseService = DatabaseService(uid: Auth().currentUser!.uid);
      try {
        await databaseService.deleteExpense(expenseId);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Expense deleted successfully'),
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to delete expense: $e'),
        ));
      }
    }

    return ListView(
      children: expenses.map((expense) {
        final category = expense.category;
        final totalAmount = expense.amount;
        final formattedDate = formatDate(expense.date);
        final color = categoryColors[category] ?? Colors.grey; // Default color if not found

        return ListTile(
          leading: Container(
            width: 16,
            height: 16,
            color: color,
            margin: const EdgeInsets.only(right: 8),
          ),
          title: Text(category),
          subtitle: Text(
            formattedDate,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          trailing: Text('\$${totalAmount.toStringAsFixed(2)}'),
          onLongPress: () {
            // Show confirmation dialog when long pressed
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Delete Expense'),
                  content: const Text('Are you sure you want to delete this expense?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        // Cancel and close the dialog
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Call delete function
                        deleteExpense(context, expense.id);
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );
          },
        );
      }).toList(),
    );
  }
}
