import 'package:expenses_tracker/classes/category.dart';
import 'package:expenses_tracker/pages/addExpensePage/submit_expense.dart';
import 'package:expenses_tracker/pages/addExpensePage/time_section_widget.dart';
import 'package:expenses_tracker/pages/overviewPage/overview_page.dart';
import 'package:expenses_tracker/services/auth.dart';
import 'package:expenses_tracker/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';
import 'field_input_section_widget.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpensePage> {
  final TextEditingController amountController = TextEditingController();
  String? selectedCategory;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  void selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.main,
              onPrimary: AppColors.opposite,
              onSurface: AppColors.main,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.main,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      });
    }
  }

  void selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.main,
              secondary: AppColors.main,
              onSecondary: AppColors.opposite,
              onPrimary: AppColors.opposite,
              onSurface: AppColors.main,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.main,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Auth().currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not signed in')));
    }

    final databaseService = DatabaseService(uid: user.uid);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const OverviewPage()),
          ),
        ),
      ),
      body: Consumer<List<Category>>(
        builder: (context, categories, child) {
          final categoryColors = {
            for (var item in categories) item.category: item.colorFromString()
          };

          return OrientationBuilder(
            builder: (context, orientation) {
              final bool isLandscape = orientation == Orientation.landscape;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: isLandscape
                    ? Padding(
                      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                      child: Column(
                          children: [
                            Center(
                                child: const Text("Add An Expense",
                                    style: TextStyles.header)),
                            StyledSizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: FieldInputSection(
                                  amountController: amountController,
                                  categoryColors: categoryColors,
                                  onCategoryChanged: (value) {
                                    setState(() {
                                      selectedCategory = value;
                                    });
                                  },
                                ),),
                                const SizedBox(width: 20),
                                Expanded(child: TimeSection(
                                  selectedDate: selectedDate,
                                  selectDate: selectDate,
                                  selectTime: selectTime,
                                ),),
                              ],
                            ),
                            StyledSizedBox(height: 20),
                            Center(
                              child: StyledActionButton(
                                buttonColor: AppColors.affirmative,
                                buttonIcon: Icons.check,
                                onPressed: () => submitExpense(
                                    databaseService,
                                  amountController,
                                  context,
                                  selectedDate,
                                  selectedTime,
                                  selectedCategory,
                                    () {
                                      setState(() {
                                        amountController.clear();
                                      });
                                    }
                                ),
                              ),
                            ),
                          ],
                        ),
                    )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                                child: const Text("Add An Expense",
                                    style: TextStyles.header)),
                            const SizedBox(height: 25),
                            FieldInputSection(
                              amountController: amountController,
                              categoryColors: categoryColors,
                              onCategoryChanged: (value) {
                                setState(() {
                                  selectedCategory = value;
                                });
                              },
                            ),
                            StyledSizedBox(height: 30),
                            TimeSection(
                              selectedDate: selectedDate,
                              selectDate: selectDate,
                              selectTime: selectTime,
                            ),
                            StyledSizedBox(height: 60),
                            Center(
                              child: StyledActionButton(
                                buttonColor: AppColors.affirmative,
                                buttonIcon: Icons.check,
                                onPressed: () =>
                                    submitExpense(
                                        databaseService,
                                        amountController,
                                        context,
                                        selectedDate,
                                        selectedTime,
                                        selectedCategory,
                                            () {
                                          setState(() {
                                            amountController.clear();
                                          });
                                        }
                                    ),
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
