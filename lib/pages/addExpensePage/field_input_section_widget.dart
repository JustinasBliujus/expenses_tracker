import 'package:flutter/material.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

class FieldInputSection extends StatelessWidget {
  final TextEditingController amountController;
  final Map<String, Color> categoryColors;
  final void Function(String?) onCategoryChanged;

  const FieldInputSection({
    super.key,
    required this.amountController,
    required this.categoryColors,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StyledTextFormField(
          controller: amountController,
          labelText: 'Enter Amount',
          keyboardType: TextInputType.number,
        ),
        const StyledSizedBox(height: 25),
        CategoryDropdown(
          hint: 'Select Category',
          categoryColors: categoryColors,
          onChanged: onCategoryChanged,
        ),
      ],
    );
  }
}
