import 'package:flutter/material.dart';
import 'home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, directly go to home screen to avoid auth complications
    return const HomeScreen();
  }
}
