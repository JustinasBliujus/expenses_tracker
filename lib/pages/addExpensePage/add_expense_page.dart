import 'package:expenses_tracker/classes/category.dart';
import 'package:expenses_tracker/pages/addExpensePage/functions/submit_expense.dart';
import 'package:expenses_tracker/pages/addExpensePage/functions/time_picker_handler.dart';
import 'package:expenses_tracker/pages/addExpensePage/widgets/time_section_widget.dart';
import 'package:expenses_tracker/pages/overviewPage/overview_page.dart';
import 'package:expenses_tracker/services/auth.dart';
import 'package:expenses_tracker/services/database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';
import 'functions/date_picker_handler.dart';
import 'widgets/field_input_section_widget.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpensePage> {
  final TextEditingController amountController = TextEditingController();
  Map<String,double> selectedCategories = {};
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  void selectDate(BuildContext context) async {
    await datePickerHandler(
      context: context,
      selectedDate: selectedDate,
      selectedTime: selectedTime,
      onDateSelected: (picked) {
        setState(() {
          selectedDate = picked;
        });
        },
    );
  }


  void selectTime(BuildContext context) async {
    await timePickerHandler(
      context,
      selectedTime,
      selectedDate,
          (pickedDateTime) {
        setState(() {
          selectedDate = pickedDateTime;
          selectedTime = TimeOfDay(
              hour: pickedDateTime.hour,
              minute: pickedDateTime.minute);
        });
      },
    );
  }

  void submitExpenses(DatabaseService databaseService) {
    double percentageCheck = 0;
    selectedCategories.forEach((category, percentage){
      percentageCheck += percentage;
    });
    if(selectedCategories.isEmpty){
      Get.rawSnackbar(
        message: 'Select Some Categories and Enter The Amount.',
        backgroundColor: AppColors.suggestion,
        snackPosition: SnackPosition.BOTTOM,
        duration: AppConstants.snackBarDurationLonger,
      );
    }
    else if(percentageCheck != 100.0){
      Get.rawSnackbar(
        message: 'Percentage Should Add Up To 100%.',
        backgroundColor: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
        duration: AppConstants.snackBarDurationLonger,
      );
    }
    else{
      selectedCategories.forEach((category, percentage) {
        submitExpense(
          databaseService,
          amountController,
          context,
          selectedDate,
          selectedTime,
          category,
          percentage,
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
                      child: SingleChildScrollView(
                        child: Column(
                            children: [
                              Center(
                                  child: const Text("Add An Expense",
                                      style: TextStyles.header)),
                              StyledSizedBox(height: 20),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child:
                                    FieldInputSection(
                                      amountController: amountController,
                                      categoryColors: categoryColors,
                                       onCategoryChanged: (value) {
                                         setState(() {
                                           selectedCategories = value;
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
                                  onPressed: () => submitExpenses(databaseService),
                                ),
                              ),
                            ],
                          ),
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
                                   selectedCategories = value;
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
                                    submitExpenses(databaseService),
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
