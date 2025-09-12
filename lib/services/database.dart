import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses_tracker/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Classes/expense.dart';
import '../classes/category.dart';

class DatabaseService {
  final String? uid;
  final Auth _auth = Auth();

  DatabaseService({this.uid});

  // Firestore references
  CollectionReference get usersCollection => FirebaseFirestore.instance.collection('users');
  CollectionReference get categoriesCollection => usersCollection.doc(uid).collection('categories');

  // Create the user's document
  Future<void> initializeUser() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    final userDocRef = usersCollection.doc(user.uid);
    final userDoc = await userDocRef.get();

    if (!userDoc.exists) {
      await userDocRef.set({
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
  // Add a new category
  Future<DocumentReference> addCategory(String category, String colorHex) async {
    return await categoriesCollection.add({
      'category': category,
      'color': colorHex,
    });
  }
  void checkIfSynced(DocumentReference docRef) async {
    DocumentSnapshot snapshot = await docRef.get();

    bool fromCache = snapshot.metadata.isFromCache;
    bool hasPendingWrites = snapshot.metadata.hasPendingWrites;

    if (fromCache || hasPendingWrites) {
      print("Document is in cache or pending write to server (offline or unsynced).");
    } else {
      print("Document is confirmed on server (online write).");
    }
  }
  Future<void> deleteCategory(String category) async{
    final db = DatabaseService(uid: uid);

    final fromSnapshot = await db.categoriesCollection
        .where('category', isEqualTo: category)
        .limit(1)
        .get();

    if (fromSnapshot.docs.isEmpty) {
      throw Exception('Category not found');
    }
    final fromRef = fromSnapshot.docs.first.reference;

    final expenses = await fromRef.collection('expenses').get();

    for (final expenseDoc in expenses.docs) {
      await expenseDoc.reference.delete();
    }

    await fromRef.delete();
  }

  Future<void> mergeCategories(String fromCategory, String toCategory) async {
    final db = DatabaseService(uid: uid);

    final fromSnapshot = await db.categoriesCollection
        .where('category', isEqualTo: fromCategory)
        .limit(1)
        .get();

    final toSnapshot = await db.categoriesCollection
        .where('category', isEqualTo: toCategory)
        .limit(1)
        .get();

    if (fromSnapshot.docs.isEmpty || toSnapshot.docs.isEmpty) {
      throw Exception('One or both categories not found');
    }

    final fromRef = fromSnapshot.docs.first.reference;
    final toRef = toSnapshot.docs.first.reference;

    final expenses = await fromRef.collection('expenses').get();

    for (final expenseDoc in expenses.docs) {
      final expenseData = expenseDoc.data();

      expenseData['category'] = toCategory;

      await toRef.collection('expenses').add(expenseData);
      await expenseDoc.reference.delete();
    }

    await fromRef.delete();
  }

  // Delete expense
  Future<void> deleteExpenseFromCategory(String categoryName, String expenseId) async {
    final categoryQuery = await categoriesCollection
        .where('category', isEqualTo: categoryName)
        .limit(1)
        .get();

    if (categoryQuery.docs.isNotEmpty) {
      final categoryDoc = categoryQuery.docs.first;
      final expenseRef = categoryDoc.reference.collection('expenses').doc(expenseId);
      await expenseRef.delete();
    } else {
      throw Exception("Category $categoryName not found.");
    }
  }

  // Add expense
  Future<void> addExpenseToCategory(DateTime date, double amount, String categoryName) async {
    final expenseData = {
      'date': date,
      'amount': amount,
      'category': categoryName,
    };

    final categoryQuery = await categoriesCollection
        .where('category', isEqualTo: categoryName)
        .limit(1)
        .get();

    if (categoryQuery.docs.isNotEmpty) {
      final categoryDoc = categoryQuery.docs.first;
      final expensesSubcollection = categoryDoc.reference.collection('expenses');
      await expensesSubcollection.add(expenseData);
    } else {
      throw Exception('Category "$categoryName" not found.');
    }
  }

  // Get a stream of all categories
  Stream<List<Category>> get categories {
    return categoriesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Category.fromMap(data, doc.id);
      }).toList();
    });
  }

  // Get a stream of expenses for a specific category
  Stream<QuerySnapshot> getExpensesForCategory(String categoryId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('categories')
        .doc(categoryId)
        .collection('expenses')
        .snapshots();
  }
  Future<double> getCategoryExpenseSum(String categoryId) async {
    final snapshot = await fetchExpensesForCategory(categoryId);
    double total = 0.0;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = (data['amount'] ?? 0).toDouble();
      total += amount;
    }

    return total;
  }
  Future<Map<String, dynamic>> getCategoryExpenseStats(String categoryId) async {
    final snapshot = await fetchExpensesForCategory(categoryId);

    if (snapshot.docs.isEmpty) {
      return {
        "total": 0.0,
        "dailyAvg": 0.0,
        "monthlyAvg": 0.0,
        "firstDate": null,
        "lastDate": null,
      };
    }

    double total = 0.0;
    DateTime? firstDate;
    DateTime? lastDate;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = (data['amount'] ?? 0).toDouble();
      final timestamp = data['date'] as Timestamp; // Firestore stores as Timestamp
      final date = timestamp.toDate();

      total += amount;

      if (firstDate == null || date.isBefore(firstDate)) {
        firstDate = date;
      }
      if (lastDate == null || date.isAfter(lastDate)) {
        lastDate = date;
      }
    }

    final daysActive = lastDate != null && firstDate != null
        ? lastDate!.difference(firstDate!).inDays + 1
        : 1;

    final dailyAvg = total / daysActive;
    final monthlyAvg = dailyAvg * 30;

    return {
      "total": total,
      "dailyAvg": dailyAvg,
      "monthlyAvg": monthlyAvg,
      "firstDate": firstDate,
      "lastDate": lastDate,
    };
  }

  // Fetches once
  Future<QuerySnapshot> fetchExpensesForCategory(String categoryId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('categories')
        .doc(categoryId)
        .collection('expenses')
        .get();
  }

  // Add a category (with login check)
  Future<void> addNewCategory(String category, String color) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await DatabaseService(uid: user.uid).addCategory(category, color);
    } else {
      throw Exception('User not signed in');
    }
  }

  //fetch all expenses
  Future<List<Expense>> fetchAllExpenses(List<Category> categories) async {
    final List<Expense> allExpenses = [];

    for (final category in categories) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('categories')
          .doc(category.id)
          .collection('expenses')
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final expense = Expense.fromMap(data, doc.id);
        allExpenses.add(expense);
      }
    }

    return allExpenses;
  }
}
