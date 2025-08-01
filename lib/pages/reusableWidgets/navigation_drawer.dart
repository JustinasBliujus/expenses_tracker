import 'package:expenses_tracker/pages/reusableWidgets/styled_sized_box.dart';
import 'package:flutter/material.dart';
import 'package:expenses_tracker/Pages/OverviewPage/overview.dart';
import 'package:expenses_tracker/Pages/history.dart';
import 'package:expenses_tracker/Pages/manage_categories.dart';
import 'package:expenses_tracker/Pages/login_register.dart';
import 'package:expenses_tracker/Services/auth.dart';

class NavigationDrawerCustom extends StatelessWidget {
  const NavigationDrawerCustom({super.key});

  Future<void> signOut(BuildContext context) async {
    try {
      await Auth().signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginRegister()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            buildHeader(context),
            buildItems(context),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black87,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Text(
                Auth().currentUser?.email ?? 'Email',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget buildItems(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.pie_chart),
            title: const Text("Overview",),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const Overview()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("History"),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const History()),
              );
            },
          ),
          const StyledSizedBox(height: 50),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Manage Categories"),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const ManageCategories()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Log out"),
            onTap: () => signOut(context),
          ),
        ],
      ),
    );
  }
}
