import 'package:expenses_tracker/services/auth.dart';
import 'package:expenses_tracker/services/database.dart';
import 'package:expenses_tracker/services/dependency_injection.dart';
import 'package:expenses_tracker/services/firebase_options.dart';
import 'package:expenses_tracker/services/network_controller.dart';
import 'package:expenses_tracker/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'classes/category.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Firebase initialization error: $e");
  }
  final user = Auth().currentUser;
  if (user == null) {
    return;
  }
  final databaseService = DatabaseService(uid: user.uid);
  runApp(
    StreamProvider<List<Category>>.value(
      value: databaseService.categories,
      initialData: const [],
      catchError: (_, __) => const [],
      child: MyApp(),
    ),
  );
  DependencyInjection.init();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    Get.put(NetworkController());
    return const GetMaterialApp(
      title: 'Expenses Tracker',
      home: WidgetTree(),
    );
  }
}

