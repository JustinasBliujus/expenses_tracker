import 'package:flutter/material.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

Future<void> datePickerHandler({
  required BuildContext context,
  required DateTime selectedDate,
  required TimeOfDay selectedTime,
  required void Function(DateTime) onDateSelected,
}) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: selectedDate,
    firstDate: DateTime.now().subtract(const Duration(days: 365)),
    lastDate: DateTime.now(),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.main,
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

  if (pickedDate != null) {
    onDateSelected(DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    ));
  }
}
