import 'package:expenses_tracker/pages/reusableWidgets/styled_action_button.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_header_text.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_sized_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:expenses_tracker/services/auth.dart';
import '../../Services/database.dart';
import 'package:expenses_tracker/pages/ManageCategoriesPage//text_input_with_two_buttons.dart';
import 'package:expenses_tracker/Pages/reusableWidgets/navigation_drawer.dart';
import 'package:expenses_tracker/pages/reusableWidgets/category_dropdown.dart';
import '../../classes/category.dart';

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
      print(selectedColor);
      Navigator.of(context).pop();
    });
  }
  String colorToHexString(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
  Future<void> _deleteCategory(String categoryName) async {
    final databaseService = DatabaseService(uid: Auth().currentUser!.uid);
    try {
      await databaseService.deleteCategoryByName(categoryName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category "$categoryName" deleted'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete category'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Future<void> mergeCategories(String fromCategory, String toCategory) async {
    final db = DatabaseService(uid: Auth().currentUser!.uid);
    try {
      final fromSnapshot = await db.categoriesCollection
          .where('category', isEqualTo: fromCategory)
          .limit(1)
          .get();

      final toSnapshot = await db.categoriesCollection
          .where('category', isEqualTo: toCategory)
          .limit(1)
          .get();

      if (fromSnapshot.docs.isEmpty || toSnapshot.docs.isEmpty) {
        throw Exception('One or both categories not found');
      }

      final fromRef = fromSnapshot.docs.first.reference;
      final toRef = toSnapshot.docs.first.reference;

      final expenses = await fromRef.collection('expenses').get();
      for (final expenseDoc in expenses.docs) {
        await toRef.collection('expenses').add(expenseDoc.data());
        await expenseDoc.reference.delete(); // move
      }
      setState(() {
        categoryToMergeFirst = null;
        categoryToMergeSecond = null;
      });
      // Optional: delete the old category
      await fromRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Categories merged'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to merge categories'), backgroundColor: Colors.red),
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
                    onPressedSecond: () async {
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

                        try {
                          await databaseService.addNewCategory(
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
                    },

                    categoryColors: categoryColors,
                  ),
                  const StyledSizedBox(height: 60),
                  const StyledHeaderText(text: "Merge Categories"),
                  const StyledSizedBox(height: 15),
                  CategoryDropdown(
                    hint: "Category To Delete",
                    categoryColors: categoryColors,
                    selectedValue: categoryToMergeFirst, // <-- ADD THIS
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
                          selectedValue: categoryToMergeSecond, // <-- ADD THIS
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
                          if(categoryToMergeFirst == categoryToMergeSecond){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('You cannot merge the same category')),
                          );
                          }
                          else if (categoryToMergeFirst != null && categoryToMergeSecond != null) {
                            mergeCategories(categoryToMergeFirst!, categoryToMergeSecond!);
                          }
                          else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select both categories to merge')),
                            );
                          }
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
