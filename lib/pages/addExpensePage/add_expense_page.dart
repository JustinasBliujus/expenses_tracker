import 'package:expenses_tracker/classes/category.dart';
import 'package:expenses_tracker/pages/reusableWidgets/category_dropdown.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_action_button.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_sized_box.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_text_form_field.dart';
import 'package:expenses_tracker/services/auth.dart';
import 'package:expenses_tracker/services/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:expenses_tracker/pages/reusableWidgets/app_colors.dart';
import 'package:expenses_tracker/pages/reusableWidgets/text_styles.dart';

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

  Future<void> submitExpense(DatabaseService databaseService) async {
    final amountText = amountController.text.trim();

    if (selectedCategory == null || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in all fields'),
            backgroundColor: AppColors.suggestion),
      );
      return;
    }

    try {
      final amount = double.parse(amountText);
      await databaseService.addExpenseToCategory(
        selectedDate,
        amount,
        selectedCategory!,
      );

      amountController.clear();
      setState(() {
        selectedCategory = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Expense added successfully'),
            backgroundColor: AppColors.affirmative),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error),
      );
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamProvider<List<Category>>.value(
        initialData: const [],
        value: databaseService.categories,
        catchError: (_, __) => [],
        child: Consumer<List<Category>>(
          builder: (context, categories, child) {
            final categoryColors = {
              for (var item in categories) item.category: item.colorFromString()
            };

            return OrientationBuilder(
              builder: (context, orientation) {
                final bool isLandscape = orientation == Orientation.landscape;

                Widget fieldInputSection = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StyledTextFormField(
                      controller: amountController,
                      labelText: 'Enter Amount',
                      keyboardType: TextInputType.number,
                    ),
                    const StyledSizedBox(height: 25),
                    CategoryDropdown(
                      hint: 'Select Category',
                      categoryColors: categoryColors,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                  ],
                );
                Widget timeSection = Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('MMM d, yyyy – hh:mm a').format(selectedDate),
                      style: TextStyles.header,
                    ),
                    StyledSizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StyledActionButton(
                            buttonColor: AppColors.main,
                            buttonIcon: Icons.calendar_month,
                            onPressed: () => selectDate(context)),
                        const SizedBox(width: 15),
                        StyledActionButton(
                            buttonColor: AppColors.main,
                            buttonIcon: Icons.watch_later_outlined,
                            onPressed: () => selectTime(context)),
                      ],
                    ),
                  ],
                );

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: isLandscape
                      ? Column(
                          children: [
                            Center(
                                child: const Text("Add An Expense",
                                    style: TextStyles.header)),
                            StyledSizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: fieldInputSection),
                                const SizedBox(width: 20),
                                Expanded(child: timeSection),
                              ],
                            ),
                            StyledSizedBox(height: 40),
                            Center(
                              child: StyledActionButton(
                                buttonColor: AppColors.affirmative,
                                buttonIcon: Icons.check,
                                onPressed: () => submitExpense(databaseService),
                              ),
                            ),
                          ],
                        )
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                  child: const Text("Add An Expense",
                                      style: TextStyles.header)),
                              const SizedBox(height: 25),
                              fieldInputSection,
                              StyledSizedBox(height: 30),
                              timeSection,
                              StyledSizedBox(height: 60),
                              Center(
                                child: StyledActionButton(
                                  buttonColor: AppColors.affirmative,
                                  buttonIcon: Icons.check,
                                  onPressed: () =>
                                      submitExpense(databaseService),
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
      ),
    );
  }
}
