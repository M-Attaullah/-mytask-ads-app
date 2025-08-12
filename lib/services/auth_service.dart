import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Create user model
        UserModel userModel = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          createdAt: DateTime.now(),
        );

        // Save user data to Realtime Database
        await _database.child('users').child(user.uid).set(userModel.toMap());

        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Get user data from Realtime Database
        DatabaseEvent event = await _database
            .child('users')
            .child(user.uid)
            .once();
        DataSnapshot snapshot = event.snapshot;

        if (snapshot.exists) {
          Map<String, dynamic> userData = Map<String, dynamic>.from(
            snapshot.value as Map,
          );
          return UserModel.fromMap(userData);
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Get user data from database
  Future<UserModel?> getUserData(String uid) async {
    try {
      DatabaseEvent event = await _database.child('users').child(uid).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<String, dynamic> userData = Map<String, dynamic>.from(
          snapshot.value as Map,
        );
        return UserModel.fromMap(userData);
      }
      return null;
    } catch (e) {
      throw 'Failed to retrieve user data.';
    }
  }

  // Update user data
  Future<void> updateUserData(UserModel user) async {
    try {
      await _database.child('users').child(user.uid).update(user.toMap());
    } catch (e) {
      throw 'Failed to update user data.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out.';
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
