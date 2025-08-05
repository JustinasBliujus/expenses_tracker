import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../classes/category.dart';
import '../../../helperFunctions/color_to_hex_string.dart';
import '../../../services/auth.dart';
import '../../../services/database.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';
import '../../../services/network_controller.dart';

Future<void> addCategory(
    List<Category> categories,
    BuildContext context,
    TextEditingController textControl,
    Color? selectedColor,
    VoidCallback clearSelections,
    ) async {

  final NetworkController networkController = Get.find();

  bool requestIsFresh = true;

  if (textControl.text.isNotEmpty && selectedColor != null) {
    final existingNames = categories.map((c) => c.category).toList();

    // CATEGORY LIMIT PER USER
    if(categories.length >= AppConstants.maxCategoryAmount){
      Get.rawSnackbar(
        message: 'Category Limit is ${AppConstants.maxCategoryAmount}',
        backgroundColor: AppColors.suggestion,
        snackPosition: SnackPosition.BOTTOM,
        duration: AppConstants.snackBarDuration,
      );
      return;
    }

    if (existingNames.contains(textControl.text.toLowerCase())) {
      Get.rawSnackbar(
        message: 'Category name already exists',
        backgroundColor: AppColors.suggestion,
        snackPosition: SnackPosition.BOTTOM,
        duration: AppConstants.snackBarDuration,
      );
      return;
    }

    final categoryService = DatabaseService(uid: Auth().currentUser!.uid);

    try {
      // If offline, show cache message
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

      String tempText = textControl.text; //Clear textField before
      clearSelections();

      // Firebase method. this queues silently when offline, code under waits
      await categoryService.addCategory(
        tempText,
        colorToHexString(selectedColor),
      );
      if(requestIsFresh){
        Get.rawSnackbar(
          message: 'Category added successfully',
          backgroundColor: AppColors.affirmative,
          snackPosition: SnackPosition.BOTTOM,
          duration: AppConstants.snackBarDuration,
        );
      }
    } catch (e) { // firebase error
      // Failed to add category
      if(requestIsFresh){
        Get.rawSnackbar(
          message: 'Failed to add category.',
          backgroundColor: AppColors.error,
          snackPosition: SnackPosition.BOTTOM,
          duration: AppConstants.snackBarDuration,
        );
      }
    }
  } else { //else then name or color not selected
    Get.rawSnackbar(
      message: 'Please enter a name and select a color',
      backgroundColor: AppColors.suggestion,
      snackPosition: SnackPosition.BOTTOM,
      duration: AppConstants.snackBarDuration,
    );
  }
}
