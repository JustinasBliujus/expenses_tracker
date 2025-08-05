import 'package:flutter/material.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

Future<void> timePickerHandler(
    BuildContext context,
    TimeOfDay initialTime,
    DateTime selectedDate,
    void Function(DateTime) onTimeSelected,
    ) async {
  final TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: initialTime,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.main,
            secondary: AppColors.main,
            onSecondary: AppColors.opposite,
            onPrimary: AppColors.opposite,
            onSurface: AppColors.main,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.main,
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (pickedTime != null) {
    final updatedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    onTimeSelected(updatedDateTime);
  }
}
