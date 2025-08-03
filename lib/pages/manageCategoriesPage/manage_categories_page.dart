import 'package:expenses_tracker/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../classes/category.dart';
import '../../services/database.dart';
import 'add_category.dart';
import 'add_category_section_widget.dart';
import 'merge_categories.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

import 'merge_category_section_widget.dart';

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

                  return isLandscape
                      ? Padding(
                        padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                          [
                            Expanded(child: AddCategorySection(
                              categoryColors: categoryColors,
                              textControl: textControl,
                              selectedColor: selectedColor,
                              changeColor: changeColor,
                              addCategory: addCategory,
                            ),),
                            const SizedBox(width: 40),
                            Expanded(child: MergeCategorySection(
                              categoryColors: categoryColors,
                              mergeCategories: mergeCategories,
                            ),),
                          ],
                        ),
                        )
                      : Column(
                          children: [
                            const SizedBox(height: 85),
                            AddCategorySection(
                              categoryColors: categoryColors,
                              textControl: textControl,
                              selectedColor: selectedColor,
                              changeColor: changeColor,
                              addCategory: addCategory,
                            ),
                            const StyledSizedBox(height: 60),
                            MergeCategorySection(
                              categoryColors: categoryColors,
                              mergeCategories: mergeCategories,
                            ),
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
