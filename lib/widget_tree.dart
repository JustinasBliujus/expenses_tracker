import 'package:expenses_tracker/pages/loginRegisterPage/login_register_page.dart';
import 'package:expenses_tracker/category_stream_provider.dart';
import 'package:expenses_tracker/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
          return const CategoryStreamProvider();
        } else {
          return const LoginRegister();
        }
      },
    );
  }
}
