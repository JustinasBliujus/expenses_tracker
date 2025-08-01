import 'package:expenses_tracker/pages/manageCategoriesPage//text_input_with_two_buttons.dart';
import 'package:expenses_tracker/pages/reusableWidgets/category_dropdown.dart';
import 'package:expenses_tracker/pages/reusableWidgets/navigation_drawer.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_action_button.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_header_text.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_sized_box.dart';
import 'package:expenses_tracker/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../../classes/category.dart';
import '../../services/database.dart';

class ManageCategories extends StatefulWidget {
  const ManageCategories({super.key});

  @override
  State<ManageCategories> createState() => _ManageCategoriesState();
}

class _ManageCategoriesState extends State<ManageCategories> {
  final TextEditingController textControl = TextEditingController();
  String? selectedCategoryFrom;
  String? selectedCategoryTo;
  Color pickerColor = Color(0xff443a49);
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

        const SnackBar(content: Text('Please select both categories to merge'),backgroundColor: Colors.orange),
      );
    }
    else if(categoryToMergeFirst == categoryToMergeSecond){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot merge the same category'),backgroundColor: Colors.orange),
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
          SnackBar(content: Text('Categories merged'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to merge categories: ${e.toString()}'), backgroundColor: Colors.red),
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
            backgroundColor: Colors.orange,
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
            backgroundColor: Colors.green,
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
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a name and select a color'),
          backgroundColor: Colors.orange,
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
            appBar: AppBar(),
            drawer: const NavigationDrawerCustom(),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 85),
                  const StyledHeaderText(text: "Add New Category"),
                  SizedBox(height: 15),
                  TextInputWithTwoButtons(
                    textFormFieldHint: 'Enter Category Name',
                    buttonColorFirst: selectedColor ?? Colors.grey,
                    buttonColorSecond: Colors.green,
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
                  const StyledSizedBox(height: 60),
                  const StyledHeaderText(text: "Merge Categories"),
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
                      SizedBox(width: 8,),
                      StyledActionButton(
                        buttonColor: Colors.green,
                        onPressed: () {
                          mergeCategories();
                        },
                        buttonIcon: Icons.check,
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}
