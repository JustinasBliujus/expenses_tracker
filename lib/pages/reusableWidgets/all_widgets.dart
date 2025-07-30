import 'package:flutter/material.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_sized_box.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_header_text.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_action_button.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_text_form_field.dart';

class CategoryDropdown extends StatelessWidget {
  final String hint;
  final Map<String, Color> categoryColors;
  final ValueChanged<String?>? onChanged;

  const CategoryDropdown({
    super.key,
    required this.hint,
    required this.categoryColors,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: hint,
        border: const OutlineInputBorder(),
      ),
      items: categoryColors.keys.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                color: categoryColors[category],
                margin: const EdgeInsets.only(right: 8),
              ),
              Text(category),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged, // Pass the onChanged callback
    );
  }
}

class CategoryActionRow extends StatelessWidget {
  final String? dropdownHint;
  final String? textFormFieldHint;
  final Color buttonColor;
  final IconData buttonIcon;
  final TextEditingController? controller;
  final bool isTextFormField;
  final VoidCallback onPressed;
  final ValueChanged<String?>? onChanged; // Callback for dropdown change
  final Map<String, Color> categoryColors; // Map for CategoryDropdown

  const CategoryActionRow({
    super.key,
    this.dropdownHint,
    this.textFormFieldHint,
    required this.buttonColor,
    required this.buttonIcon,
    this.controller,
    this.isTextFormField = false,
    required this.onPressed,
    this.onChanged,
    required this.categoryColors, // Initialize categoryColors
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
            categoryColors: categoryColors, // Pass categoryColors to CategoryDropdown
            onChanged: onChanged, // Pass the onChanged callback
          ),
        ),
        const SizedBox(width: 8),
        StyledActionButton(
          buttonColor: buttonColor,
          buttonIcon: buttonIcon,
          onPressed: onPressed,
        ),
      ],
    );
  }
}

const List<Color> predefinedColors = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.yellow,
  Colors.orange,
  Colors.purple,
  Colors.cyan,
  Colors.brown,
  Colors.grey,
];

// Define the ColorDropdown widget
class ColorDropdown extends StatelessWidget {
  final String hint;
  final ValueChanged<Color?>? onChanged;
  final Color? selectedColor;

  const ColorDropdown({
    super.key,
    required this.hint,
    required this.onChanged,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Color>(
      decoration: InputDecoration(
        labelText: hint,
        border: const OutlineInputBorder(),
      ),
      value: selectedColor,
      items: predefinedColors.map((Color color) {
        return DropdownMenuItem<Color>(
          value: color,
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                color: color,
                margin: const EdgeInsets.only(right: 8),
              ),
              Text(_getColorName(color)),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  String _getColorName(Color color) {
    switch (color) {
      case Colors.red:
        return 'Red';
      case Colors.green:
        return 'Green';
      case Colors.blue:
        return 'Blue';
      case Colors.yellow:
        return 'Yellow';
      case Colors.orange:
        return 'Orange';
      case Colors.purple:
        return 'Purple';
      case Colors.cyan:
        return 'Cyan';
      case Colors.brown:
        return 'Brown';
      case Colors.black:
        return 'Black';
      case Colors.pink:
        return 'Pink';
      case Colors.indigo:
        return 'Indigo';
      default:
        return 'Unknown';
    }
  }
}
