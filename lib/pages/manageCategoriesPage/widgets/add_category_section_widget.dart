import 'package:expenses_tracker/pages/manageCategoriesPage/widgets/text_input_with_two_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

import '../../../classes/category.dart';

class AddCategorySection extends StatefulWidget {
  final List<Category> categories;
  final TextEditingController textControl;
  final void Function(Color) changeColor;
  final void Function(
      List<Category>,
      BuildContext,
      TextEditingController,
      Color?,
      VoidCallback,
      ) addCategory;

  const AddCategorySection({
    super.key,
    required this.categories,
    required this.textControl,
    required this.changeColor,
    required this.addCategory,
  });

  @override
  State<AddCategorySection> createState() => _AddCategorySectionState();
}

class _AddCategorySectionState extends State<AddCategorySection> {
  Color? selectedColor = AppColors.unknown;

  @override
  Widget build(BuildContext context) {
    final categoryColors = {
      for (var item in widget.categories) item.category: item.colorFromString()
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text("Add New Category", style: TextStyles.header),
        ),
        const SizedBox(height: 15),
        TextInputWithTwoButtons(
          textFormFieldHint: 'Enter Category Name',
          buttonColorFirst: selectedColor ?? AppColors.unknown,
          buttonColorSecond: AppColors.affirmative,
          buttonIcon: Icons.check,
          controller: widget.textControl,
          isTextFormField: true,
          onPressedFirst: () async {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Pick a color'),
                content: SingleChildScrollView(
                  child: BlockPicker(
                    pickerColor: selectedColor ?? AppColors.unknown,
                    onColorChanged: (color) {
                      setState(() {
                        selectedColor = color;
                      });
                      widget.changeColor(color);
                    },
                  ),
                ),
              ),
            );
            FocusManager.instance.primaryFocus?.unfocus(); //remove keyboard
          },
          onPressedSecond: () {
            widget.addCategory(
              widget.categories,
              context,
              widget.textControl,
              selectedColor,
                  () {
                setState(() {
                  widget.textControl.clear();
                  selectedColor = AppColors.unknown;
                });
              },
            );
          },
          categoryColors: categoryColors,
        ),
      ],
    );
  }
}
