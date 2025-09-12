import 'package:expenses_tracker/pages/reusable/reusable_export.dart';
import 'package:flutter/material.dart';

import '../../reusable/widgets/category_dropdown.dart';
import '../../reusable/widgets/styled_sized_box.dart';
import '../../reusable/widgets/styled_text_form_field.dart';

class FieldInputSection extends StatefulWidget {
  final Map<String, Color> categoryColors;
  final TextEditingController amountController;
  final void Function(Map<String, double>) onCategoryChanged;

  const FieldInputSection({
    super.key,
    required this.categoryColors,
    required this.amountController,
    required this.onCategoryChanged,
  });

  @override
  State<FieldInputSection> createState() => _FieldInputSectionState();
}

class _FieldInputSectionState extends State<FieldInputSection> {
  List<_CategoryPercentage> rows = [];
  Map<String, double> categoryAmounts = {};

  @override
  void initState() {
    super.initState();
    rows.add(_CategoryPercentage(selectedCategory: null, percentage: 100));
  }

  double get totalPercentage =>
      rows.fold(0, (sum, row) => sum + row.percentage);

  void addRow() {
    setState(() {
      rows.add(_CategoryPercentage(selectedCategory: null, percentage: 0));
    });
  }

  void updatePercentage(int index, double newValue) {
    double remaining = 100 - rows
        .asMap()
        .entries
        .where((entry) => entry.key != index)
        .fold(0.0, (sum, e) => sum + e.value.percentage);

    if (newValue > remaining) newValue = remaining;

    setState(() {
      rows[index].percentage = newValue;
      _updateCategoryAmount(index);
    });
  }

  void _updateCategoryAmount(int index) {
    final row = rows[index];
    if (row.selectedCategory != null) {
      categoryAmounts[row.selectedCategory!] = row.percentage;

      widget.onCategoryChanged(categoryAmounts);
    }
  }

  void _onDropdownChanged(int index, String? category) {
    setState(() {
      rows[index].selectedCategory = category;
      _updateCategoryAmount(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StyledTextFormField(
          controller: widget.amountController,
          labelText: 'Enter Amount',
          keyboardType: TextInputType.number,
        ),
        const StyledSizedBox(height: 25),
        ...rows.asMap().entries.map((entry) {
          int index = entry.key;
          _CategoryPercentage row = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: CategoryDropdown(
                    hint: "Select Category",
                    categoryColors: widget.categoryColors,
                    selectedValue: row.selectedCategory,
                    onChanged: (val) => _onDropdownChanged(index, val),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: [
                      Slider(
                        value: row.percentage,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: "${row.percentage.round()}%",
                        onChanged: (val) => updatePercentage(index, val),
                      ),
                      Text("${row.percentage.round()}%"),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),
        StyledActionButton(
          buttonColor: AppColors.affirmative,
          buttonIcon: Icons.add,
          onPressed: rows.length >= widget.categoryColors.length
              ? null
              : addRow,
        ),

        const SizedBox(height: 10),
        Text("Total: ${totalPercentage.round()}%"),
      ],
    );
  }
}

class _CategoryPercentage {
  String? selectedCategory;
  double percentage;

  _CategoryPercentage({required this.selectedCategory, required this.percentage});
}
