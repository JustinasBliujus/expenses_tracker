import 'package:flutter/material.dart';
import 'package:expenses_tracker/Pages/OverviewPage/tabBarCustom.dart';
import 'package:expenses_tracker/Pages/SharedWidgets/navigationDrawerCustom.dart';
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
