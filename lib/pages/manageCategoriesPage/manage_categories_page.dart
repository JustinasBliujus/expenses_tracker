import 'package:expenses_tracker/pages/manageCategoriesPage//text_input_with_two_buttons.dart';
import 'package:expenses_tracker/pages/reusableWidgets/category_dropdown.dart';
import 'package:expenses_tracker/pages/reusableWidgets/navigation_drawer.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_action_button.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_sized_box.dart';
import 'package:expenses_tracker/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../../classes/category.dart';
import '../../services/database.dart';
import 'package:expenses_tracker/pages/reusableWidgets/app_colors.dart';

import '../reusableWidgets/text_styles.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  final TextEditingController textControl = TextEditingController();
  String? selectedCategoryFrom;
  String? selectedCategoryTo;
  Color pickerColor = AppColors.affirmative;
  Color? selectedColor;
  String? categoryToDelete;
  String? categoryToMergeFirst;
  String? categoryToMergeSecond;

  void changeColor(Color color) {
    setState(() {
      pickerColor = color;
      selectedColor = pickerColor;
      Navigator.of(context).pop();
    });
  }

  String colorToHexString(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  Future<void> mergeCategories() async {
    final service = DatabaseService(uid: Auth().currentUser!.uid);

    if(categoryToMergeFirst == null || categoryToMergeSecond == null){
      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(content: Text('Please select both categories to merge'),backgroundColor: AppColors.suggestion),
      );
    }
    else if(categoryToMergeFirst == categoryToMergeSecond){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot merge the same category'),backgroundColor: AppColors.suggestion),
      );
    }
    else{
      try {
        await service.mergeCategories(categoryToMergeFirst!, categoryToMergeSecond!);

        setState(() {
          categoryToMergeFirst = null;
          categoryToMergeSecond = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Categories merged'), backgroundColor: AppColors.affirmative),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to merge categories: ${e.toString()}'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void addCategory(Map<String, dynamic> categoryColors) async {
    if (textControl.text.isNotEmpty && selectedColor != null) {
      final existingNames = categoryColors.keys.map((e) => e.toLowerCase()).toList();

      if (existingNames.contains(textControl.text.toLowerCase())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category name already exists'),
            backgroundColor: AppColors.suggestion,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final categoryService = DatabaseService(uid: Auth().currentUser!.uid);

      try {
        await categoryService.addCategory(
          textControl.text,
          colorToHexString(selectedColor!),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category added successfully'),
            backgroundColor: AppColors.affirmative,
            duration: Duration(seconds: 2),
          ),
        );

        setState(() {
          textControl.clear();
          selectedColor = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add category'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a name and select a color'),
          backgroundColor: AppColors.suggestion,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final user = Auth().currentUser;

    if (user == null) {
      return const Center(child: Text('User not signed in'));
    }

    final databaseService = DatabaseService(uid: user.uid);

    return MultiProvider(
      providers: [
        StreamProvider<List<Category>>.value(
          initialData: const [],
          value: databaseService.categories,
          catchError: (_, __) => const [],
        ),
      ],
      child: Consumer<List<Category>>(
        builder: (context, categories, child) {
          final categoryColors = {
            for (var item in categories) item.category: item.colorFromString()
          };
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(),
            drawer: const NavigationDrawerCustom(),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: OrientationBuilder(
                builder: (context, orientation) {
                  bool isLandscape = orientation == Orientation.landscape;

                  Widget addCategorySection = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: const Text("Add New Category", style: TextStyles.header)),
                      const SizedBox(height: 15),
                      TextInputWithTwoButtons(
                        textFormFieldHint: 'Enter Category Name',
                        buttonColorFirst: selectedColor ?? AppColors.unknown,
                        buttonColorSecond: AppColors.affirmative,
                        buttonIcon: Icons.check,
                        controller: textControl,
                        isTextFormField: true,
                        onPressedFirst: () async {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Pick a color'),
                              content: SingleChildScrollView(
                                child: BlockPicker(
                                  pickerColor: selectedColor,
                                  onColorChanged: changeColor,
                                ),
                              ),
                            ),
                          );
                        },
                        onPressedSecond: () => addCategory(categoryColors),
                        categoryColors: categoryColors,
                      ),
                    ],
                  );

                  Widget mergeCategorySection = Column(
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
                            onPressed: mergeCategories,
                            buttonIcon: Icons.check,
                          ),
                        ],
                      ),
                    ],
                  );

                  return isLandscape
                      ? Padding(
                        padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                        child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                        Expanded(child: addCategorySection),
                        const SizedBox(width: 40),
                        Expanded(child: mergeCategorySection),
                                            ],
                                          ),
                      )
                      : Column(
                    children: [
                      const SizedBox(height: 85),
                      addCategorySection,
                      const StyledSizedBox(height: 60),
                      mergeCategorySection,
                    ],
                  );
                },
              ),
            ),
          );

        },
      ),
    );
  }

}
