import 'package:flutter/material.dart';
import 'package:expenses_tracker/Pages/OverviewPage/top_tab_bar.dart';
import 'package:expenses_tracker/Pages/reusableWidgets/navigation_drawer.dart';
class Overview extends StatefulWidget {
  const Overview({super.key});

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const TabBarCustom(),
      appBar: AppBar(),
      drawer: const NavigationDrawerCustom(),
    );
  }
}
