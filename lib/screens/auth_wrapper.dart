import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view_models/auth_view_model.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return StreamBuilder<User?>(
          stream: authViewModel.authStateChanges,
          builder: (context, snapshot) {
            // Show loading screen while checking auth state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // If user is authenticated, show home screen
            if (snapshot.hasData && snapshot.data != null) {
              // Initialize user data if not already done
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (authViewModel.currentUser == null) {
                  authViewModel.initializeAuth();
                }
              });
              return const HomeScreen();
            }

            // If user is not authenticated, show login screen
            return const LoginScreen();
          },
        );
      },
    );
  }
}
