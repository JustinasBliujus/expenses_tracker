import 'package:flutter/material.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

class StyledActionButton extends StatelessWidget {
  final Color buttonColor;
  final IconData? buttonIcon;
  final String? buttonText;
  final VoidCallback? onPressed;

  const StyledActionButton({
    super.key,
    required this.buttonColor,
    this.buttonIcon,
    this.buttonText,
    required this.onPressed,
  }) : assert(buttonIcon != null || buttonText != null, 'Either buttonIcon or buttonText must be provided');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: buttonColor,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8),
      ),
      child: buttonIcon != null
          ? IconButton(
        icon: Icon(buttonIcon, color: AppColors.opposite),
        onPressed: onPressed,
      )
          : TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.opposite,
          padding: EdgeInsets.zero,
          minimumSize: Size(50, 50),
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(buttonText!),
      ),
    );
  }
}
