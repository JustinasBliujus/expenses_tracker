import 'package:expenses_tracker/pages/historyPage/history_page.dart';
import 'package:expenses_tracker/pages/loginRegisterPage/login_register_page.dart';
import 'package:expenses_tracker/pages/manageCategoriesPage/manage_categories_page.dart';
import 'package:expenses_tracker/pages/overviewPage/overview_page.dart';
import 'package:expenses_tracker/pages/trendsPage/trends_page.dart';
import 'package:expenses_tracker/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

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
        SnackBar(
          duration: AppConstants.snackBarDuration,
          content: Text('Error signing out: $e'),
          backgroundColor: AppColors.error,
        ),
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
            const StyledSizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.main,
        ),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
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
              leading: const Icon(Icons.pie_chart,color: AppColors.main),
            title: const Text("Overview",style: TextStyles.black,),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const OverviewPage()),
              );
            },
          ),
          const StyledHorizontalDivider(),
          ListTile(
            leading: const Icon(Icons.history,color: AppColors.main),
            title: const Text("History", style: TextStyles.black,),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            },
          ),
          const StyledSizedBox(height: 50),
          ListTile(
            leading: const Icon(Icons.trending_up,color: AppColors.main),
            title: const Text("Trends", style: TextStyles.black,),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const TrendsPage()),
              );
            },
          ),
          const StyledSizedBox(height: 50),
          ListTile(
            leading: const Icon(Icons.settings, color: AppColors.main),
            title: const Text("Manage Categories", style: TextStyles.black,),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const ManageCategoriesPage()),
              );
            },
          ),
          const StyledHorizontalDivider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.main,),
            title: const Text("Log out", style: TextStyles.black,),
            onTap: () => signOut(context),
          ),
        ],
      ),
    );
  }
}
