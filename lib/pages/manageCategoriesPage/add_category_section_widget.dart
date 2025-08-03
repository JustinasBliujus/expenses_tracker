import 'package:expenses_tracker/pages/manageCategoriesPage/text_input_with_two_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

class AddCategorySection extends StatefulWidget {
  final Map<String, Color> categoryColors;
  final TextEditingController textControl;
  final Color? selectedColor;
  final void Function(Color) changeColor;
  final void Function(
      Map<String, Color>,
      BuildContext,
      TextEditingController,
      Color?,
      VoidCallback,
      ) addCategory;

  const AddCategorySection({
    super.key,
    required this.categoryColors,
    required this.textControl,
    required this.selectedColor,
    required this.changeColor,
    required this.addCategory,
  });

  @override
  State<AddCategorySection> createState() => _AddCategorySectionState();
}

class _AddCategorySectionState extends State<AddCategorySection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text("Add New Category", style: TextStyles.header),
        ),
        const SizedBox(height: 15),
        TextInputWithTwoButtons(
          textFormFieldHint: 'Enter Category Name',
          buttonColorFirst: widget.selectedColor ?? AppColors.unknown,
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
                    pickerColor: widget.selectedColor ?? Colors.grey,
                    onColorChanged: widget.changeColor,
                  ),
                ),
              ),
            );
          },
          onPressedSecond: () {
            widget.addCategory(
              widget.categoryColors,
              context,
              widget.textControl,
              widget.selectedColor,
                  () {
                setState(() {
                  widget.textControl.clear();
                });
              },
            );
          },
          categoryColors: widget.categoryColors,
        ),
      ],
    );
  }
}
