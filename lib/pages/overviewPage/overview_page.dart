import 'package:expenses_tracker/pages/overviewPage/overview_page_body.dart';
import 'package:expenses_tracker/pages/reusableWidgets/navigation_drawer.dart';
import 'package:flutter/material.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const OverviewPageBody(),
      appBar: AppBar(),
      drawer: const NavigationDrawerCustom(),
    );
  }
}
