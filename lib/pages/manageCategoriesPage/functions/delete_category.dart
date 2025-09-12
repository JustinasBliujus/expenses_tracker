import 'package:flutter/material.dart';
import '../../../services/auth.dart';
import '../../../services/database.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';
import 'package:get/get.dart';

import '../../../services/network_controller.dart';

Future<void> deleteCategory(
    String? categoryToDelete,
    BuildContext context,
    VoidCallback clearSelection,
    ) async {

  final service = DatabaseService(uid: Auth().currentUser!.uid);

  bool requestIsFresh = true;
  final NetworkController networkController = Get.find();

  if (categoryToDelete == null) {
    Get.rawSnackbar(
      message: 'Please select category to delete',
      backgroundColor: AppColors.suggestion,
      snackPosition: SnackPosition.BOTTOM,
      duration: AppConstants.snackBarDuration,
    );
  } else {
    try {
      if (!networkController.isOnline.value){
        Get.rawSnackbar(
          message: 'You are offline. Changes will be cached locally.',
          backgroundColor: AppColors.error,
          snackPosition: SnackPosition.BOTTOM,
          duration: AppConstants.snackBarDurationLonger,
          icon: Icon(Icons.wifi_off, color: AppColors.opposite),
        );
        requestIsFresh = false;
      }
      clearSelection();

      await service.deleteCategory(categoryToDelete);

      if(requestIsFresh) {
        Get.rawSnackbar(
          message: 'Category Deleted',
          backgroundColor: AppColors.affirmative,
          snackPosition: SnackPosition.BOTTOM,
          duration: AppConstants.snackBarDuration,
        );
      }
    } catch (e) {
      if(requestIsFresh) {
        Get.rawSnackbar(
          message: 'Failed to Delete',
          backgroundColor: AppColors.error,
          snackPosition: SnackPosition.BOTTOM,
          duration: AppConstants.snackBarDuration,
        );
      }
    }
  }
}
