import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class StyledCircularProgressIndicator extends StatelessWidget {
  const StyledCircularProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(
      color: AppColors.main,
    );
  }
}
