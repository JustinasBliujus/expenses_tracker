import 'package:flutter/material.dart';
import '../../../services/auth.dart';
import '../../../services/database.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';
import 'package:get/get.dart';

import '../../../services/network_controller.dart';

Future<void> mergeCategories(
    String? categoryToMergeFirst,
    String? categoryToMergeSecond,
    BuildContext context,
    VoidCallback clearSelections,
    ) async {

  final service = DatabaseService(uid: Auth().currentUser!.uid);

  bool requestIsFresh = true;
  final NetworkController networkController = Get.find();

  if (categoryToMergeFirst == null || categoryToMergeSecond == null) {
    Get.rawSnackbar(
      message: 'Please select both categories to merge',
      backgroundColor: AppColors.suggestion,
      snackPosition: SnackPosition.BOTTOM,
      duration: AppConstants.snackBarDuration,
    );
  } else if (categoryToMergeFirst == categoryToMergeSecond) {
    Get.rawSnackbar(
      message: 'You cannot merge the same category',
      backgroundColor: AppColors.error,
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
        requestIsFresh = false;//to prevent snack bar queueing when offline
      }

      clearSelections();

      await service.mergeCategories(categoryToMergeFirst, categoryToMergeSecond);

      if(requestIsFresh) {
        Get.rawSnackbar(
          message: 'Categories merged',
          backgroundColor: AppColors.affirmative,
          snackPosition: SnackPosition.BOTTOM,
          duration: AppConstants.snackBarDuration,
        );
      }
    } catch (e) {
      if(requestIsFresh) {
        Get.rawSnackbar(
          message: 'Failed to merge categories',
          backgroundColor: AppColors.error,
          snackPosition: SnackPosition.BOTTOM,
          duration: AppConstants.snackBarDuration,
        );
      }
    }
  }
}
