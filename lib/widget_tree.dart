import 'package:expenses_tracker/pages/loginRegisterPage/login_register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenses_tracker/classes/category.dart';
import 'package:expenses_tracker/services/database.dart';

import 'main_app_scaffold.dart';

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (user == null) {
          return const LoginRegister();
        }

        return StreamProvider<List<Category>>.value(
          value: DatabaseService(uid: user.uid).categories,
          initialData: const [],
          catchError: (_, __) => const [],
          child: const MainAppScaffold(),
        );
      },
    );
  }
}
