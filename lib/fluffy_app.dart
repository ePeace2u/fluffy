
import 'package:fluffy/screens/auth_screen.dart';
import 'package:fluffy/screens/home_screen.dart';
import 'package:fluffy/screens/resetpassword_screen.dart';
import 'package:fluffy/screens/signUp_screen.dart';
import 'package:fluffy/screens/verify_screen.dart';
import 'package:fluffy/services/firebase_stream.dart';
import 'package:flutter/material.dart';

class FluffyApp extends StatelessWidget {
  const FluffyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("fluff");
    return MaterialApp(
      home: FirebaseStream(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/reset': (context) => const ResetPasswordScreen(),
        '/stream': (context) => const FirebaseStream(),
        '/home': (context) => HomeScreen(),
        '/login': (context) => AuthScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/verify_email': (context) => const VerifyEmailScreen(),
      },
    );
  }
  }
