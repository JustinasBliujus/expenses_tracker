import 'package:flutter/material.dart';
import '../../services/auth.dart';
import '../../services/database.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

Future<void> mergeCategories(String? categoryToMergeFirst,
    String? categoryToMergeSecond,
    BuildContext context,
    VoidCallback clearSelections,
    ) async {
  final service = DatabaseService(uid: Auth().currentUser!.uid);

  if(categoryToMergeFirst == null || categoryToMergeSecond == null){
    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(
          duration: AppConstants.snackBarDuration,
          content: Text('Please select both categories to merge'),
          backgroundColor: AppColors.suggestion),
    );
  }
  else if(categoryToMergeFirst == categoryToMergeSecond){
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          duration: AppConstants.snackBarDuration,
          content: Text('You cannot merge the same category'),
          backgroundColor: AppColors.suggestion
      ),
    );
  }
  else{
    try {
      await service.mergeCategories(categoryToMergeFirst, categoryToMergeSecond);

      clearSelections();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            duration: AppConstants.snackBarDuration,
            content: Text('Categories merged'),
            backgroundColor: AppColors.affirmative
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            duration: AppConstants.snackBarDuration,
            content: Text('Failed to merge categories: ${e.toString()}'),
            backgroundColor: AppColors.error)
        ,
      );
    }
  }
}