import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expenses_tracker/Pages/SharedWidgets/navigationDrawerCustom.dart';
import 'package:expenses_tracker/Pages/SharedWidgets/formWidgets.dart';
import 'package:expenses_tracker/Services/database.dart';
import 'package:expenses_tracker/Services/auth.dart';
import 'package:provider/provider.dart';

import '../Classes/category.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  _AddExpenseState createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final TextEditingController amountController = TextEditingController();
  String? selectedCategory = "Unknown";
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023, 8, 20),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      });
    }
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Auth().currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not signed in')),
      );
    }

    final databaseService = DatabaseService(uid: user.uid);
    return Scaffold(
      appBar: AppBar(),
      drawer: const NavigationDrawerCustom(),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const CustomSizedBox(height: 35),
                  const CustomHeaderText(text: "Add An Expense"),
                  const CustomSizedBox(height: 25),
                  CustomTextFormField(
                    controller: amountController,
                    labelText: 'Enter Amount',
                    keyboardType: TextInputType.number,
                  ),
                  const CustomSizedBox(height: 25),
                  CategoryDropdown(
                    hint: 'Select Category',
                    onChanged: (newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    }, categoryColors: categoryColors,
                  ),
                  const CustomSizedBox(height: 25),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Select Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        "${selectedDate.toLocal()}".split(' ')[0],
                      ),
                    ),
                  ),
                  const CustomSizedBox(height: 25),
                  GestureDetector(
                    onTap: () => _selectTime(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Select Time',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        selectedTime.format(context),
                      ),
                    ),
                  ),
                  const CustomSizedBox(height: 25),
                  CustomActionButton(
                    buttonColor: Colors.green.withOpacity(0.8),
                    buttonIcon: Icons.check,
                    onPressed: () async {
                      if (selectedCategory != null &&
                          amountController.text.isNotEmpty) {
                        double amount = double.parse(amountController.text);
                        String category = selectedCategory ?? "Unknown";

                        // Use the DatabaseService to add the expense
                        User? user = Auth().currentUser;
                        if (user != null) {
                          DatabaseService databaseService = DatabaseService(uid: user.uid);

                          // Add expense
                          await databaseService.addExpense(
                            selectedDate,
                            amount,
                            category,
                          );

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Expense added successfully'),
                            ),
                          );
                        } else {
                          // Show error if user is not authenticated
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User not signed in'),
                            ),
                          );
                        }
                      } else {
                        // Show an error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in all fields'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
