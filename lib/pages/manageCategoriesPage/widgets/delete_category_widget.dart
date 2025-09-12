import 'package:flutter/material.dart';

import '../../../classes/category.dart';
import '../../reusable/constants/app_colors.dart';
import '../../reusable/constants/text_styles.dart';
import '../../reusable/widgets/category_dropdown.dart';
import '../../reusable/widgets/styled_action_button.dart';
import '../../reusable/widgets/styled_sized_box.dart';

class DeleteCategoryWidget extends StatefulWidget {
  final List<Category> categories;
  final Function(String?, BuildContext, VoidCallback) deleteCategory;

  const DeleteCategoryWidget({
    super.key,
    required this.categories,
    required this.deleteCategory,
  });

  @override
  State<DeleteCategoryWidget> createState() => _DeleteCategoryWidgetState();
}

class _DeleteCategoryWidgetState extends State<DeleteCategoryWidget> {
  String? categoryToDelete;

  @override
  Widget build(BuildContext context) {
    final categoryColors = {
      for (var item in widget.categories) item.category: item.colorFromString()
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text("Delete Category", style: TextStyles.header),
        ),
        const StyledSizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: CategoryDropdown(
                hint: "Category To Delete",
                categoryColors: categoryColors,
                selectedValue: categoryToDelete,
                onChanged: (value) {
                  setState(() {
                    categoryToDelete = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            StyledActionButton(
              buttonColor: AppColors.affirmative,
              onPressed: () async {
                if (categoryToDelete != null) {
                  widget.deleteCategory(categoryToDelete, context,
                        () {
                      setState(() {
                        categoryToDelete = null;
                      });
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select a category to delete."),
                    ),
                  );
                }
              },
              buttonIcon: Icons.check,
            ),
          ],
        ),
      ],
    );
  }
}
