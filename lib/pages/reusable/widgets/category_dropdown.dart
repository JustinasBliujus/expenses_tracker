import 'package:flutter/material.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

class CategoryDropdown extends StatelessWidget {
  final String hint;
  final Map<String, Color> categoryColors;
  final ValueChanged<String?>? onChanged;
  final String? selectedValue;

  const CategoryDropdown({
    super.key,
    required this.hint,
    required this.categoryColors,
    required this.onChanged,
    this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: AppColors.main),
        border: const OutlineInputBorder(),
        focusedBorder:OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.main),
        ),
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
      onChanged: onChanged,
    );
  }
}
