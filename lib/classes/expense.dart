import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String category;
  final double amount;
  final DateTime date;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
  });

  // Factory constructor to create an Expense object from Firestore document data
  factory Expense.fromMap(Map<String, dynamic> map, String id) {
    return Expense(
      id: id,
      category: map['category'] ?? 'Unknown',
      amount: (map['amount'] as num).toDouble() ?? 0.0,
      date: (map['date'] as Timestamp).toDate() ?? DateTime.now(),
    );
  }

  // Method to convert Expense to a map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'amount': amount,
      'date': date,
    };
  }
}
