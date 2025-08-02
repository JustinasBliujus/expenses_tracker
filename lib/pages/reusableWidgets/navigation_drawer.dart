import 'package:expenses_tracker/pages/historyPage/history_page.dart';
import 'package:expenses_tracker/pages/loginRegisterPage/login_register_page.dart';
import 'package:expenses_tracker/pages/manageCategoriesPage/manage_categories_page.dart';
import 'package:expenses_tracker/pages/overviewPage/overview_page.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_sized_box.dart';
import 'package:expenses_tracker/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_horizontal_divider.dart';
import 'package:expenses_tracker/pages/reusableWidgets/app_colors.dart';
import 'package:expenses_tracker/pages/reusableWidgets/text_styles.dart';

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
          color: AppColors.main,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Text(
                Auth().currentUser?.email ?? 'Email',
                style: TextStyles.userEmail,
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
                MaterialPageRoute(builder: (context) => const OverviewPage()),
              );
            },
          ),
          const StyledHorizontalDivider(),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("History"),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            },
          ),
          const StyledSizedBox(height: 50),
          ListTile(
            leading: const Icon(Icons.settings,),
            title: const Text("Manage Categories"),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const ManageCategoriesPage()),
              );
            },
          ),
          const StyledHorizontalDivider(),
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
