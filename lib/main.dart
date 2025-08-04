import 'package:expenses_tracker/services/dependency_injection.dart';
import 'package:expenses_tracker/services/firebase_options.dart';
import 'package:expenses_tracker/services/network_controller.dart';
import 'package:expenses_tracker/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  runApp(
    MyApp(),
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
      title: 'eTracker',
      home: WidgetTree(),
    );
  }
}

