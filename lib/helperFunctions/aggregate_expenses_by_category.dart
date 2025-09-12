import '../Classes/expense.dart';

Map<String, double> aggregateExpensesByCategory(List<Expense> expenses) {
  final Map<String, double> dataMap = {};
  for (var expense in expenses) {
    dataMap.update(expense.category, (value) => value + expense.amount, ifAbsent: () => expense.amount.toDouble());
  }
  return dataMap;
}