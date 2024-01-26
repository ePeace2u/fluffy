import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluffy/screens/auth_screen.dart';
import 'package:fluffy/screens/home_screen.dart';
import 'package:flutter/material.dart';
import '../screens/verify_screen.dart';

class FirebaseStream extends StatelessWidget {
  const FirebaseStream({super.key});

  @override
  Widget build(BuildContext context) {
    print("fire");
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
              body: Center(child: Text('Что-то пошло не так!')));
        } else if (snapshot.hasData) {
          if (!snapshot.data!.emailVerified) {
            return const VerifyEmailScreen();
          }
          return HomeScreen();
        } else {
          print("fauf");
          return AuthScreen();
        }
      },
    );
  }
}
