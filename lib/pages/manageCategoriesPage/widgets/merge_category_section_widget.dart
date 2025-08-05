import 'package:flutter/material.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

import '../../../classes/category.dart';


class MergeCategorySection extends StatefulWidget {
  final List<Category> categories;
  final Function(String?, String?, BuildContext, VoidCallback) mergeCategories;

  const MergeCategorySection({
    super.key,
    required this.categories,
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
    final categoryColors = {
      for (var item in widget.categories) item.category: item.colorFromString()
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: const Text("Merge Categories", style: TextStyles.header)),
        const StyledSizedBox(height: 15),
        CategoryDropdown(
          hint: "Category To Delete",
          categoryColors: categoryColors,
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
                categoryColors: categoryColors,
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
