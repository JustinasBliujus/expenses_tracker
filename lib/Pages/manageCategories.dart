import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Services/auth.dart';
import '../Classes/category.dart';
import '../Services/database.dart';
import 'SharedWidgets/formWidgets.dart';
import 'package:expenses_tracker/Pages/SharedWidgets/navigationDrawerCustom.dart';

class ManageCategories extends StatefulWidget {
  const ManageCategories({super.key});

  @override
  State<ManageCategories> createState() => _ManageCategoriesState();
}

class _ManageCategoriesState extends State<ManageCategories> {
  final TextEditingController textControl = TextEditingController();
  String? selectedCategoryFrom;
  String? selectedCategoryTo;
  Color? _selectedColor;

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
                  const SizedBox(height: 125),
                  const CustomHeaderText(text: "Add New Category"),
                  const CustomSizedBox(height: 15),
                  CategoryActionRow(
                    textFormFieldHint: 'Enter Category Name',
                    buttonColor: Colors.green.withOpacity(0.8),
                    buttonIcon: Icons.check,
                    controller: textControl,
                    isTextFormField: true,
                    onPressed: () async {
                      if (textControl.text.isNotEmpty && _selectedColor != null) {
                        await databaseService.addCategory(textControl.text, _getColorName(_selectedColor!));
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Category added!'),
                          ),
                        );
                      }
                    },
                    categoryColors: categoryColors,
                  ),
                  const CustomSizedBox(height: 25),
                  ColorDropdown(
                    hint: 'Choose color',
                    selectedColor: _selectedColor,
                    onChanged: (Color? newValue) {
                      setState(() {
                        _selectedColor = newValue;
                      });
                      // Print the color
                      if (newValue != null) {
                        _selectedColor = newValue;
                      }
                    },
                  ),
                  const CustomSizedBox(height: 55),
                  const CustomHeaderText(text: "Switch Categories"),
                  const CustomSizedBox(height: 25),
                  CategoryDropdown(
                    hint: 'Move expenses from',
                    categoryColors: categoryColors,
                    onChanged: (newValue) {
                      setState(() {
                        selectedCategoryFrom = newValue;
                      });
                    },
                  ),
                  const CustomSizedBox(height: 25),
                  CategoryActionRow(
                    dropdownHint: 'Move expenses into',
                    buttonColor: Colors.orange.withOpacity(0.8),
                    buttonIcon: Icons.swap_horiz,
                    onChanged: (newValue) {
                      setState(() {
                        selectedCategoryTo = newValue;
                      });
                    },
                    onPressed: () async {
                      if (selectedCategoryTo != null && selectedCategoryFrom != null) {
                        await databaseService.updateExpensesCategory(selectedCategoryFrom!, selectedCategoryTo!);
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Categories switched!'),
                          ),
                        );
                      }
                    },
                    categoryColors: categoryColors,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getColorName(Color color) {
    switch (color) {
      case Colors.red:
        return 'Red';
      case Colors.green:
        return 'Green';
      case Colors.blue:
        return 'Blue';
      case Colors.yellow:
        return 'Yellow';
      case Colors.orange:
        return 'Orange';
      case Colors.purple:
        return 'Purple';
      case Colors.cyan:
        return 'Cyan';
      case Colors.brown:
        return 'Brown';
      case Colors.grey:
        return 'Grey';
      default:
        return 'Unknown';
    }
  }
}
