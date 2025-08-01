import 'package:expenses_tracker/classes/category.dart';
import 'package:expenses_tracker/pages/reusableWidgets/category_dropdown.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_action_button.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_header_text.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_sized_box.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_text_form_field.dart';
import 'package:expenses_tracker/services/auth.dart';
import 'package:expenses_tracker/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


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
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
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
        const SnackBar(content: Text('Please fill in all fields'),backgroundColor: Colors.orange),
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
        const SnackBar(content: Text('Expense added successfully'),backgroundColor: Colors.grey),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'),backgroundColor: Colors.red),
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

            return Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const StyledSizedBox(height: 35),
                    const StyledHeaderText(text: "Add An Expense"),
                    const StyledSizedBox(height: 25),
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
                    const StyledSizedBox(height: 25),
                    GestureDetector(
                      onTap: () => selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Select Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text("${selectedDate.toLocal()}".split(' ')[0]),
                      ),
                    ),
                    const StyledSizedBox(height: 25),
                    GestureDetector(
                      onTap: () => selectTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Select Time',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(selectedTime.format(context)),
                      ),
                    ),
                    const StyledSizedBox(height: 25),
                    StyledActionButton(
                      buttonColor: Colors.green.withOpacity(0.8),
                      buttonIcon: Icons.check,
                      onPressed: () => submitExpense(databaseService),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
