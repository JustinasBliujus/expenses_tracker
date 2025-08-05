import 'package:flutter/material.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

class TextInputWithTwoButtons extends StatelessWidget {
  final String? dropdownHint;
  final String? textFormFieldHint;
  final Color buttonColorFirst;
  final Color buttonColorSecond;
  final IconData buttonIcon;
  final TextEditingController? controller;
  final bool isTextFormField;
  final VoidCallback onPressedFirst;
  final VoidCallback onPressedSecond;
  final ValueChanged<String?>? onChanged;
  final Map<String, Color> categoryColors;

  const TextInputWithTwoButtons({
    super.key,
    this.dropdownHint,
    this.textFormFieldHint,
    required this.buttonColorFirst,
    required this.buttonColorSecond,
    required this.buttonIcon,
    this.controller,
    this.isTextFormField = false,
    required this.onPressedFirst,
    required this.onPressedSecond,
    this.onChanged,
    required this.categoryColors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: isTextFormField
              ? StyledTextFormField(
            controller: controller!,
            labelText: textFormFieldHint!,
          )
              : CategoryDropdown(
            hint: dropdownHint ?? '',
            categoryColors: categoryColors,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 8),
        StyledActionButton(
          buttonColor: buttonColorFirst,
          buttonIcon: Icons.palette,
          onPressed: onPressedFirst,
        ),
        const SizedBox(width: 8),
        StyledActionButton(
          buttonColor: buttonColorSecond,
          buttonIcon: buttonIcon,
          onPressed: onPressedSecond,
        ),
      ],
    );
  }
}

