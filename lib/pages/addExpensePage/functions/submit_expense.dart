import 'package:flutter/material.dart';
import '../../../services/database.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';
import 'package:get/get.dart';

import '../../../services/network_controller.dart';

Future<void> submitExpense(
    DatabaseService databaseService,
    TextEditingController amountController,
    BuildContext context,
    DateTime selectedDate,
    TimeOfDay selectedTime,
    String? selectedCategory,
    double percentage,
    ) async {

  final amountText = amountController.text.trim();

  final NetworkController networkController = Get.find();

  bool requestIsFresh = true;

  if (selectedCategory == null || amountText.isEmpty) {
      Get.rawSnackbar(
          duration: AppConstants.snackBarDuration,
          message: 'Please fill in all fields',
          backgroundColor: AppColors.suggestion,
      );
    return;
  }

  try {

    if (!networkController.isOnline.value) {
      Get.rawSnackbar(
        message: 'You are offline. Changes will be cached locally.',
        backgroundColor: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
        duration: AppConstants.snackBarDurationLonger,
        icon: Icon(Icons.wifi_off, color: AppColors.opposite),
      );
      requestIsFresh = false;//to prevent snack bar queueing when offline
    }

    final amount = double.parse(amountText)*(percentage/100);

    // await firebase method to add expense. When offline code stalls until back online
    await databaseService.addExpenseToCategory(
      selectedDate,
      amount,
      selectedCategory,
    );

    if(requestIsFresh){
      Get.rawSnackbar(
        duration: AppConstants.snackBarDuration,
        message: 'Expense added successfully',
        backgroundColor: AppColors.affirmative,
      );
    }
  } catch (e) {
    if(requestIsFresh){
      Get.rawSnackbar(
        duration: AppConstants.snackBarDuration,
        message: 'Error adding expense',
        backgroundColor: AppColors.error,
      );
    }
  }
}