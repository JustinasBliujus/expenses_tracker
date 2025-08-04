import 'package:flutter/material.dart';
import 'package:expenses_tracker/pages/reusable/constants/app_colors.dart';

class TextStyles {

  static const TextStyle dataMissing = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static const TextStyle small = TextStyle(fontSize: 12);
  static const TextStyle pieChartTotal = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.main,
  );
  static const TextStyle userEmail = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.opposite,
    letterSpacing: 1.2,
  );
  static const TextStyle header = TextStyle(fontSize: 25);
  static const TextStyle delete = TextStyle(color: AppColors.error);
  static const TextStyle black = TextStyle(color: AppColors.main);
}