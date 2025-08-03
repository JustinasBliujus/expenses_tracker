import 'package:flutter/material.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

class StyledHorizontalDivider extends StatelessWidget {
  const StyledHorizontalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.main, AppColors.transparent],
          stops: [0.01, 0.85],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }
}
