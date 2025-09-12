import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../Classes/expense.dart';
import '../../../services/auth.dart';
import '../../../services/database.dart';
import '../../../services/network_controller.dart';
import '../../reusable/constants/app_colors.dart';
import '../../reusable/constants/app_constants.dart';
import '../../reusable/widgets/styled_action_button.dart';

void showDeleteDialog(BuildContext context, Expense expense, VoidCallback setState) {
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
                requestIsFresh = false; // prevent snack bar queueing when offline
                setState();
              }

              Navigator.of(context).pop();
              await db.deleteExpenseFromCategory(expense.category, expense.id);

              if (requestIsFresh) {
                Get.rawSnackbar(
                  message: 'Expense deleted successfully',
                  backgroundColor: AppColors.affirmative,
                  snackPosition: SnackPosition.BOTTOM,
                  duration: AppConstants.snackBarDuration,
                );
              }

              setState(); // refresh UI after deletion
            },
            buttonColor: AppColors.error,
            buttonText: "Yes",
          ),
        ],
      );
    },
  );
}