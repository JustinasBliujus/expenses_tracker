import 'package:expenses_tracker/pages/manageCategoriesPage/widgets/delete_category_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../classes/category.dart';
import 'functions/add_category.dart';
import 'widgets/add_category_section_widget.dart';
import 'functions/merge_categories.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';
import 'widgets/merge_category_section_widget.dart';
import 'package:expenses_tracker/pages/manageCategoriesPage/functions/delete_category.dart';
class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  final TextEditingController textControl = TextEditingController();
  String? selectedCategoryFrom;
  String? selectedCategoryTo;
  Color? selectedColor;
  String? categoryToDelete;
  String? categoryToMergeFirst;
  String? categoryToMergeSecond;
  String? categoryToDeleteFully;

  void changeColor(Color color) {
    setState(() {
      selectedColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<List<Category>>(
      builder: (context, categories, child) {
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
                            categories: categories,
                            textControl: textControl,
                            changeColor: changeColor,
                            addCategory: addCategory,
                          ),),
                          const SizedBox(width: 40),
                          Expanded(child: MergeCategorySection(
                            categories: categories,
                            mergeCategories: mergeCategories,
                          ),),
                        ],
                      ),
                      )
                    : Column(
                        children: [
                          const SizedBox(height: 85),
                          AddCategorySection(
                            categories: categories,
                            textControl: textControl,
                            changeColor: changeColor,
                            addCategory: addCategory,
                          ),
                          const StyledSizedBox(height: 60),
                          MergeCategorySection(
                            categories: categories,
                            mergeCategories: mergeCategories,
                          ),
                          const StyledSizedBox(height: 60),
                          DeleteCategoryWidget(
                              categories: categories,
                              deleteCategory: deleteCategory,
                          ),
                        ],
                      );
              },
            ),
          ),
        );
      },
    );
  }

}
