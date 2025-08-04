import '../Classes/expense.dart';

List<Expense> filterExpensesByPeriod(List<Expense> expenses, int durationType) {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  DateTime startDate;
  DateTime endDate;

  switch (durationType) {
    case 1: //daily
      startDate = startOfDay;
      endDate = startDate.add(const Duration(days: 1));
      break;
    case 2: //weekly
      startDate = startOfDay.subtract(Duration(days: now.weekday - 1)); // Monday
      endDate = startDate.add(const Duration(days: 7));
      break;
    case 3: //monthly
      startDate = DateTime(now.year, now.month);
      endDate = DateTime(now.year, now.month + 1);
      break;
    default: //all
      return expenses;
  }

  return expenses.where((e) => e.date.isAfter(startDate) && e.date.isBefore(endDate)).toList();
}