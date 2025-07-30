import 'package:expenses_tracker/Services/auth.dart';
import 'package:expenses_tracker/Pages/loginRegister.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expenses_tracker/Pages/OverviewPage/overview.dart';
class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Something went wrong! Please try again later.',
                  style: TextStyle(fontSize: 18, color: Colors.red)),
            ),
          );
        } else if (snapshot.hasData) {
          return const Overview();
        } else {
          return const LoginRegister();
        }
      },
    );
  }
}
