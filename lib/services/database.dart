import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expenses_tracker/Services/auth.dart';
import 'package:expenses_tracker/Classes/category.dart';

class DatabaseService {
  final String? uid;
  final Auth _auth = Auth();
  DatabaseService({this.uid});

  CollectionReference get expensesCollection => FirebaseFirestore.instance.collection('users').doc(uid).collection('expenses');
  CollectionReference get categoriesCollection => FirebaseFirestore.instance.collection('users').doc(uid).collection('categories');

  Future<DocumentReference<Object?>> addExpense(DateTime date, double amount, String category) async {
    return await expensesCollection.add(
        {
          'date': date,
          'amount': amount,
          'category': category,
        }
    );
  }
  Future<void> deleteExpense(String expenseId) async {
    try {
      // Delete the expense document from Firestore
      await expensesCollection.doc(expenseId).delete();
      print('Expense deleted successfully');
    } catch (e) {
      print('Failed to delete expense: $e');
      rethrow; // Propagate the error
    }
  }
  Future<void> updateCategoryColor(String categoryId, Color newColor) async {
    await categoriesCollection.doc(categoryId).update({
      'color': newColor.value.toString(),
    });
  }

  Future<DocumentReference<Object?>> addCategory(String category, String color) async {
    return await categoriesCollection.add(
        {
          'category': category,
          'color': color,
        }
    );
  }

  Future<void> updateExpense(String expenseId, DateTime date, double amount, String category) async {
    return await expensesCollection.doc(expenseId).set(
        {
          'date': date,
          'amount': amount,
          'category': category,
        }
    );
  }

  Stream<List<Category>> get categories {
    return categoriesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Category.fromMap(data, doc.id);
      }).toList();
    });
  }


  Future<void> addNewExpense(DateTime date, double amount, String category) async {
    User? user = _auth.currentUser;

    if (user != null) {
      DatabaseService databaseService = DatabaseService(uid: user.uid);
      await databaseService.addExpense(date, amount, category);
    } else {
      throw Exception('User not signed in');
    }
  }

  Future<void> addNewCategory(String category, String color) async {
    User? user = _auth.currentUser;

    if (user != null) {
      DatabaseService databaseService = DatabaseService(uid: user.uid);
      await databaseService.addCategory(category, color);
    } else {
      throw Exception('User not signed in');
    }
  }

  Stream<QuerySnapshot> get expenses {
    return expensesCollection.snapshots();
  }

  // Initialize categories based on the first expense
  Future<void> initializeCategories() async {
    // Define a map of default categories and colors
    final Map<String, String> defaultCategories = {
      'Food': 'Blue',
      'Transport': 'Orange',
      'Clothes': 'Green',
      'Entertainment': 'Purple',
      'Housing': 'Red'
    };

    // Iterate over the default categories and add them
    for (var entry in defaultCategories.entries) {
      await addCategory(entry.key, entry.value);
    }
  }

  // Update expenses where category is `oldCategory` to `newCategory`
  Future<void> updateExpensesCategory(String oldCategory, String newCategory) async {
    User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not signed in');
    }

    try {
      final querySnapshot = await expensesCollection.where('category', isEqualTo: oldCategory).get();

      final batch = FirebaseFirestore.instance.batch();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'category': newCategory});
      }

      await batch.commit();
      print('Categories updated successfully');
    } catch (e) {
      print('Failed to update categories: $e');
      rethrow; // Propagate the error
    }
  }
}
