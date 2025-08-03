import 'package:flutter/material.dart';
import '../../services/database.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

Future<void> submitExpense(
    DatabaseService databaseService,
    TextEditingController amountController,
    BuildContext context,
    DateTime selectedDate,
    TimeOfDay selectedTime,
    String? selectedCategory,
    VoidCallback clearSelection,
    ) async {

  final amountText = amountController.text.trim();

  if (selectedCategory == null || amountText.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          duration: AppConstants.snackBarDuration,
          content: const Text('Please fill in all fields'),
          backgroundColor: AppColors.suggestion),
    );
    return;
  }

  try {
    final amount = double.parse(amountText);
    await databaseService.addExpenseToCategory(
      selectedDate,
      amount,
      selectedCategory,
    );
    clearSelection();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          duration: AppConstants.snackBarDuration,
          content: Text('Expense added successfully'),
          backgroundColor: AppColors.affirmative),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          duration: AppConstants.snackBarDuration,
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error),
    );
  }
}