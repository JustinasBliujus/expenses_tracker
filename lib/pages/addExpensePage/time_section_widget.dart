import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

class TimeSection extends StatelessWidget {
  final DateTime selectedDate;
  final void Function(BuildContext) selectDate;
  final void Function(BuildContext) selectTime;

  const TimeSection({
    super.key,
    required this.selectedDate,
    required this.selectDate,
    required this.selectTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          DateFormat('MMM d, yyyy – hh:mm a').format(selectedDate),
          style: TextStyles.header,
        ),
        const StyledSizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StyledActionButton(
              buttonColor: AppColors.main,
              buttonIcon: Icons.calendar_month,
              onPressed: () => selectDate(context),
            ),
            const SizedBox(width: 15),
            StyledActionButton(
              buttonColor: AppColors.main,
              buttonIcon: Icons.watch_later_outlined,
              onPressed: () => selectTime(context),
            ),
          ],
        ),
      ],
    );
  }
}
