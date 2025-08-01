import 'package:flutter/material.dart';
import 'package:expenses_tracker/Classes/expense.dart';
import 'package:expenses_tracker/Pages/OverviewPage/pie_chart.dart';
import 'package:expenses_tracker/Services/database.dart';
import 'package:expenses_tracker/Services/auth.dart';
import 'package:provider/provider.dart';
import 'package:expenses_tracker/classes/category.dart';

import '../addExpensePage/add_expense.dart';

class TopTabBar extends StatelessWidget {
  const TopTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: const TabBar(
            tabs: <Widget>[
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
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            onPressed: () => {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddExpensePage()),
              )
            },
            child: Icon(Icons.add)
        ),
      ),
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
  List<Expense> filterExpenses(List<Expense> expenses, int durationType) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (durationType) {
      case 1:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate.add(const Duration(days: 1));
        break;
      case 2:
        startDate = now.subtract(Duration(days: now.weekday - 1)); // Monday
        endDate = startDate.add(const Duration(days: 7));
        break;
      case 3:
        startDate = DateTime(now.year, now.month);
        endDate = DateTime(now.year, now.month + 1);
        break;
      default:
        return expenses; // Total
    }

    return expenses.where((e) => e.date.isAfter(startDate) && e.date.isBefore(endDate)).toList();
  }

  List<MapEntry<String, double>> calculateTotalsByCategory(List<Expense> expenses) {
    final Map<String, double> dataMap = {};
    for (var expense in expenses) {
      dataMap.update(expense.category, (v) => v + expense.amount, ifAbsent: () => expense.amount);
    }
    return dataMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  @override
  Widget build(BuildContext context) {
    final user = Auth().currentUser;
    if (user == null) return const Center(child: Text("User not signed in"));

    final db = DatabaseService(uid: user.uid);

    return StreamProvider<List<Category>>.value(
      initialData: const [],
      value: db.categories,
      child: Consumer<List<Category>>(
        builder: (context, categories, _) {
          final categoryColors = {
            for (var cat in categories) cat.category: cat.colorFromString(),
          };

          return FutureBuilder<List<Expense>>(
            future: _loadAllExpensesForUser(db, categories),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final allExpenses = snapshot.data!;
              final filteredExpenses = filterExpenses(allExpenses, widget.durationType);
              final totals = calculateTotalsByCategory(filteredExpenses);

              return Column(
                children: [
                  SizedBox(
                    height: 400,
                    child: filteredExpenses.isEmpty
                        ? const Center(
                      child: Text('No expenses to track yet.', style: TextStyle(fontSize: 20)),
                    )
                        : ExpensePieChart(expenses: filteredExpenses, categoryColors: categoryColors),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: totals.length,
                      itemBuilder: (context, index) {
                        final entry = totals[index];
                        final color = categoryColors[entry.key] ?? Colors.grey;
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
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// Loads all expenses across all categories for the current user
  Future<List<Expense>> _loadAllExpensesForUser(DatabaseService db, List<Category> categories) async {
    List<Expense> all = [];

    for (final cat in categories) {
      final snapshot = await db.getExpensesForCategory(cat.id).first;
      all.addAll(snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Expense.fromMap({...data, 'category': cat.category}, doc.id);
      }));
    }

    return all;
  }
}