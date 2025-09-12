import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../classes/category.dart';
import '../../services/auth.dart';
import '../../services/database.dart';
import '../reusable/constants/text_styles.dart';
import '../reusable/widgets/navigation_drawer.dart';


class TrendsPage extends StatefulWidget {
  const TrendsPage({super.key});

  @override
  State<TrendsPage> createState() => _TrendsPageState();
}

class _TrendsPageState extends State<TrendsPage> {
  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<List<Category>>(context);
    final user = Auth().currentUser;
    if (user == null) return const Center(child: Text("User not signed in",style: TextStyles.dataMissing,));
    final db = DatabaseService(uid: user.uid);
    return Scaffold(
      drawer: NavigationDrawerCustom(),
      appBar: AppBar(),
      body: categories.isEmpty
          ? const Center(child: Text("No categories available"))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          return FutureBuilder<Map<String, dynamic>>(
            future: db.getCategoryExpenseStats(category.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(category.category),
                    subtitle: const Text("Loading stats..."),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(category.category),
                    subtitle: const Text("Error loading expenses"),
                  ),
                );
              }

              final stats = snapshot.data!;
              final total = stats["total"] as double;
              final daily = stats["dailyAvg"] as double;
              final monthly = stats["monthlyAvg"] as double;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: category.colorFromString().withOpacity(0.15),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: category.colorFromString(),
                        child: Text(
                          category.category[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.category,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: category.colorFromString()
                                    .withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text("Total Spent: \$${total.toStringAsFixed(2)}"),
                            Text(
                                "Daily Average: \$${daily.toStringAsFixed(2)}"),
                            Text(
                                "Expected Spending in a Month: \$${monthly.toStringAsFixed(2)}"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
