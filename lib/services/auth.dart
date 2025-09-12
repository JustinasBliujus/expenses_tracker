import 'package:expenses_tracker/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Getter for the current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print("Login error: ${e.code} - ${e.message}");
      rethrow;
    }
  }


  // Create a new user with email and password
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try{
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      if (currentUser != null) {
        // initialize user in firebase
        await DatabaseService(uid: currentUser!.uid).initializeUser();
      }
    } on FirebaseAuthException catch (e) {
      print("Register error: ${e.code} - ${e.message}");
      rethrow;
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
