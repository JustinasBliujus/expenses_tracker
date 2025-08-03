import 'package:flutter/material.dart';
import '../../services/auth.dart';
import '../../services/database.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

String colorToHexString(Color color) {
  return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
}

Future<void> addCategory(
    Map<String, dynamic> categoryColors,
    BuildContext context,
    TextEditingController textControl,
    Color? selectedColor,
    VoidCallback clearSelections,
    ) async {
  if (textControl.text.isNotEmpty && selectedColor != null) {
    final existingNames =
    categoryColors.keys.map((e) => e.toLowerCase()).toList();

    if (existingNames.contains(textControl.text.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: AppConstants.snackBarDuration,
          content: Text('Category name already exists'),
          backgroundColor: AppColors.suggestion,
        ),
      );
      return;
    }

    final categoryService = DatabaseService(uid: Auth().currentUser!.uid);

    try {
      await categoryService.addCategory(
        textControl.text,
        colorToHexString(selectedColor),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: AppConstants.snackBarDuration,
          content: Text('Category added successfully'),
          backgroundColor: AppColors.affirmative,
        ),
      );

      clearSelections();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: AppConstants.snackBarDuration,
          content: Text('Failed to add category'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: AppConstants.snackBarDuration,
        content: Text('Please enter a name and select a color'),
        backgroundColor: AppColors.suggestion,
      ),
    );
  }
}
