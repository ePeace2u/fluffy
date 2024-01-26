import 'package:firebase_core/firebase_core.dart';
import 'package:fluffy/fluffy_app.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';


Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("main");
  runApp(FluffyApp());
}
