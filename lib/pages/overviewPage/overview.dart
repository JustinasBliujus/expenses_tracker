import 'package:expenses_tracker/pages/overviewPage/top_tab_bar.dart';
import 'package:expenses_tracker/pages/reusableWidgets/navigation_drawer.dart';
import 'package:flutter/material.dart';

class Overview extends StatefulWidget {
  const Overview({super.key});

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const TopTabBar(),
      appBar: AppBar(),
      drawer: const NavigationDrawerCustom(),
    );
  }
}
