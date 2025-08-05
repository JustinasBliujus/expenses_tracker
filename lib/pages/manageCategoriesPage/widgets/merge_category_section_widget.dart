import 'package:flutter/material.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';


class MergeCategorySection extends StatefulWidget {
  final Map<String, Color> categoryColors;
  final Function(String?, String?, BuildContext, VoidCallback) mergeCategories;

  const MergeCategorySection({
    super.key,
    required this.categoryColors,
    required this.mergeCategories,
  });

  @override
  State<MergeCategorySection> createState() => _MergeCategorySectionState();
}

class _MergeCategorySectionState extends State<MergeCategorySection> {
  String? categoryToMergeFirst;
  String? categoryToMergeSecond;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: const Text("Merge Categories", style: TextStyles.header)),
        const StyledSizedBox(height: 15),
        CategoryDropdown(
          hint: "Category To Delete",
          categoryColors: widget.categoryColors,
          selectedValue: categoryToMergeFirst,
          onChanged: (value) {
            setState(() {
              categoryToMergeFirst = value;
            });
          },
        ),
        const StyledSizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: CategoryDropdown(
                hint: "Merge Into",
                categoryColors: widget.categoryColors,
                selectedValue: categoryToMergeSecond,
                onChanged: (value) {
                  setState(() {
                    categoryToMergeSecond = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            StyledActionButton(
              buttonColor: AppColors.affirmative,
              onPressed: () {
                widget.mergeCategories(
                  categoryToMergeFirst,
                  categoryToMergeSecond,
                  context,
                      () {
                    setState(() {
                      categoryToMergeFirst = null;
                      categoryToMergeSecond = null;
                    });
                  },
                );
              },
              buttonIcon: Icons.check,
            ),
          ],
        ),
      ],
    );
  }
}
