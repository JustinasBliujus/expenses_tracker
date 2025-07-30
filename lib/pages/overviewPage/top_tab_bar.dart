import 'package:flutter/material.dart';
import 'package:expenses_tracker/Classes/expense.dart';
import 'package:expenses_tracker/Pages/OverviewPage/pie_chart.dart';
import 'package:expenses_tracker/Services/database.dart';
import 'package:expenses_tracker/Services/auth.dart';
import 'package:provider/provider.dart';
import 'package:expenses_tracker/Classes/category.dart';

class TabBarCustom extends StatelessWidget {
  const TabBarCustom({super.key});

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
      case 1: // Daily
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
        break;
      case 2: // Weekly
        startDate = DateTime(now.year, now.month, now.day - (now.weekday - 1));
        endDate = DateTime(now.year, now.month, now.day + (DateTime.daysPerWeek - now.weekday));
        endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);
        break;
      case 3: // Monthly
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
        break;
      default: // Total (all time)
        return expenses;
    }

    return expenses.where((expense) {
      return expense.date.isAfter(startDate) && expense.date.isBefore(endDate);
    }).toList();
  }

  List<MapEntry<String, double>> calculateTotalsByCategory(List<Expense> expenses) {
    final Map<String, double> dataMap = {};
    for (var expense in expenses) {
      if (dataMap.containsKey(expense.category)) {
        dataMap[expense.category] = dataMap[expense.category]! + expense.amount;
      } else {
        dataMap[expense.category] = expense.amount.toDouble();
      }
    }

    final sortedEntries = dataMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries;
  }

  @override
  Widget build(BuildContext context) {
    final user = Auth().currentUser;

    if (user == null) {
      return const Center(child: Text('User not signed in'));
    }

    final databaseService = DatabaseService(uid: user.uid);

    return MultiProvider(
      providers: [
        StreamProvider<List<Expense>>.value(
          initialData: const [],
          value: databaseService.expenses.map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Expense.fromMap(data, doc.id);
            }).toList();
          }),
          catchError: (_, __) => const [],
        ),
        StreamProvider<List<Category>>.value(
          initialData: const [],
          value: databaseService.categories,
          catchError: (_, __) => const [],
        ),
      ],
      child: Consumer2<List<Expense>, List<Category>>(
        builder: (context, expenses, categories, child) {
          expenses.sort((a, b) => b.date.compareTo(a.date));

          // Map categories to their color
          final categoryColors = {
            for (var item in categories) item.category: item.colorFromString()
          };

          final filteredExpenses = filterExpenses(expenses, widget.durationType);
          final sortedCategoryTotals = calculateTotalsByCategory(filteredExpenses);

          return Column(
            children: [
              SizedBox(
                height: 400,
                child: filteredExpenses.isEmpty
                    ? const Center(
                  child: Text(
                    'No expenses to track yet.',
                    style: TextStyle(fontSize: 20),
                  ),
                )
                    : ExpensePieChart(expenses: filteredExpenses, categoryColors: categoryColors),
              ),
              Expanded(
                child: ListView(
                  children: sortedCategoryTotals.map((entry) {
                    final category = entry.key;
                    final totalAmount = entry.value;
                    final color = categoryColors[category] ?? Colors.grey;

                    return ListTile(
                        leading: Container(
                          width: 16,
                          height: 16,
                          color: color,
                          margin: const EdgeInsets.only(right: 8),
                        ),
                        title: Text(category),
                        trailing: Text('\$${totalAmount.toStringAsFixed(2)}'),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
