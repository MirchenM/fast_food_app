import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';

/// Decide automaticamente entre login e ecrã principal, consoante
/// haja ou não sessão Firebase ativa — assim quem já tem conta não
/// vê o login sempre que reabre a app.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != null) {
          return const HomeScreen();
        }
        return LoginScreen(authRepository: FirebaseAuthRepository());
      },
    );
  }
}