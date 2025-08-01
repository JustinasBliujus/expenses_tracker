

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../Classes/expense.dart';
import '../../classes/category.dart';
import '../../services/auth.dart';
import '../../services/database.dart';
import '../reusableWidgets/navigation_drawer.dart';

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
      body: StreamProvider<List<Category>>.value(
        initialData: const [],
        value: databaseService.categories,
        catchError: (_, __) => [],
        child: const HistoryListView(),
      ),
    );
  }
}

class HistoryListView extends StatelessWidget {
  const HistoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<List<Category>>(context);
    final databaseService = DatabaseService(uid: Auth().currentUser!.uid);

    final categoryColors = {
      for (var cat in categories) cat.category: cat.colorFromString()
    };

    if (categories.isEmpty) {
      return const Center(child: Text('No History Found.'));
    }

    return FutureBuilder<List<Expense>>(
      future: databaseService.fetchAllExpenses(categories),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No expenses found.', style: TextStyle(fontSize: 20)),
          );
        }

        final expenses = snapshot.data!;
        expenses.sort((a, b) => b.date.compareTo(a.date));

        String formatDate(DateTime date) {
          final formatter = DateFormat('MMMM d, yyyy h:mm a');
          return formatter.format(date);
        }

        return ListView.builder(
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            final color = categoryColors[expense.category] ?? Colors.grey;

            return ListTile(
              leading: Container(
                width: 16,
                height: 16,
                color: color,
                margin: const EdgeInsets.only(right: 8),
              ),
              title: Text(expense.category),
              subtitle: Text(formatDate(expense.date),
                  style: const TextStyle(fontSize: 12)),
              trailing: Text('\$${expense.amount.toStringAsFixed(2)}'),
              onLongPress: () => _showDeleteDialog(context, expense),
            );
          },
        );
      },
    );
  }


  void _showDeleteDialog(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                final db = DatabaseService(uid: Auth().currentUser!.uid);
                await db.deleteExpenseFromCategory(expense.category, expense.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Expense deleted successfully'),backgroundColor: Colors.green),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
