import 'package:expenses_tracker/pages/reusableWidgets/styled_action_button.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_header_text.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_sized_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:expenses_tracker/services/auth.dart';
import '../Classes/category.dart';
import '../Services/database.dart';
import 'package:expenses_tracker/pages/reusableWidgets/all_widgets.dart';
import 'package:expenses_tracker/Pages/reusableWidgets/navigation_drawer.dart';

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
                  const StyledSizedBox(height: 15),
                  CategoryActionRow(
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
                        await databaseService.addNewCategory(
                          textControl.text,
                          selectedColor!.toHexString(),
                        );
                      }
                    },
                    categoryColors: categoryColors,
                  ),
                  const StyledSizedBox(height: 60),
                  const StyledHeaderText(text: "Merge Categories"),
                  const StyledSizedBox(height: 15),
                  CategoryDropdown(
                    hint: "Choose First Category",
                    categoryColors: categoryColors,
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
                          hint: "Choose Second Category",
                          categoryColors: categoryColors,
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
                          onPressed: () => {},
                        buttonIcon: Icons.check,
                      )
                    ],
                  ),
                  const StyledSizedBox(height: 60),
                  const StyledHeaderText(text: "Delete Category"),
                  const StyledSizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: CategoryDropdown(
                          hint: "Choose a Category",
                          categoryColors: categoryColors,
                          onChanged: (value) {
                            setState(() {
                              categoryToDelete = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 8,),
                      StyledActionButton(
                          buttonColor: Colors.red,
                          onPressed: () => {},
                          buttonIcon: Icons.delete,
                      ),
                    ],
                  ),
                  const StyledSizedBox(height: 15),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}
