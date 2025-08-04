import 'package:expenses_tracker/pages/overviewPage/overview_page.dart';
import 'package:expenses_tracker/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'classes/category.dart';

final DatabaseService databaseService = DatabaseService();

class CategoryStreamProvider extends StatelessWidget {

  const CategoryStreamProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Category>>.value(
      value: databaseService.categories,
      initialData: const [],
      catchError: (_, __) => const [],
      child: const OverviewPage(),
    );
  }
}
