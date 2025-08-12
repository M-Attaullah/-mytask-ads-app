import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  // Initialize auth state
  Future<void> initializeAuth() async {
    User? firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      _currentUser = await _authService.getUserData(firebaseUser.uid);
      notifyListeners();
    }
  }

  // Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      _currentUser = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );

      _setLoading(false);
      return _currentUser != null;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign in existing user
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _setLoading(true);
      _clearError();

      _currentUser = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _setLoading(false);
      return _currentUser != null;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _currentUser = null;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Update user data
  Future<bool> updateUser(UserModel updatedUser) async {
    try {
      _setLoading(true);
      await _authService.updateUserData(updatedUser);
      _currentUser = updatedUser;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _clearError();
  }
}
