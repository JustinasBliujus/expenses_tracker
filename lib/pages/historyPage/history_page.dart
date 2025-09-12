import 'package:expenses_tracker/pages/historyPage/widgets/history_list_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../classes/category.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {

    return Consumer<List<Category>>(
      builder: (context, categories, child) {

        var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
        double lPadding = isPortrait ? 0 : 70;
        double rPadding = lPadding;

        if (categories.isEmpty) {
          return  Scaffold(
            appBar: AppBar(),
            drawer: NavigationDrawerCustom(),
            body: Center(
              child: Text(
                'No History Found',
                style: TextStyles.dataMissing,
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(),
          drawer: const NavigationDrawerCustom(),
          body: Padding(
                padding: EdgeInsets.fromLTRB(lPadding, 0, rPadding, 0),
                child: HistoryListView(
                  categories: categories,
                  refreshCallback: () {
                    setState(() {});
                  },
                ),
            )
        );
      },
    );
  }
}

