import 'package:flutter/material.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

class StyledCheckBox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final double size;
  final String hintText;

  const StyledCheckBox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 60.0,
    this.hintText = "Set First Page To\n Add Expense",
  });

  @override
  State<StyledCheckBox> createState() => _StyledCheckBoxState();
}

class _StyledCheckBoxState extends State<StyledCheckBox> {
  @override
  Widget build(BuildContext context) {
    final isChecked = widget.value;
    final iconColor = isChecked ? AppColors.opposite : AppColors.main;
    final borderColor = iconColor;
    final backgroundColor = isChecked ? AppColors.affirmative : AppColors.suggestion;

    return Tooltip(
      message: widget.hintText,
      waitDuration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () => widget.onChanged(!isChecked),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: borderColor,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              isChecked ? Icons.check : Icons.question_mark,
              color: iconColor,
              size: widget.size * 0.6,
            ),
          ),
        ),
      ),
    );
  }
}
