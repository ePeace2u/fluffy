import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/snack_bar.dart';
import 'home_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  bool emailWasSent = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    if (mounted) {
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    }

    print(isEmailVerified);

    if (isEmailVerified) timer?.cancel();
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() => canResendEmail = false);
      }
      await Future.delayed(const Duration(seconds: 5));
      if (mounted) {
        setState(() => canResendEmail = true);
      }
    } catch (e) {
      print(e);
      if (mounted) {
        SnackBarService.showSnackBar(
          context,
          '$e',
          //'Неизвестная ошибка! Попробуйте еще раз или обратитесь в поддержку.',
          true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? HomeScreen()
      : Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 150, left: 50),
                    child: const Text(
                      'Email Verification',
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 25),
                    child: const Text(
                      'Mail was sent on your email adress.',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.cyan),
                      overlayColor: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.white;
                            }
                            return null; // Defer to the widget's default.
                          }),
                    ),
                    onPressed: () {
                      canResendEmail ? sendVerificationEmail() : null;
                     },
                    icon: const Icon(Icons.email, color: Colors.black54,),
                    label: const Text('Resend', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 17),),
                  ),
                  TextButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      if (timer != null) {
                        timer?.cancel();
                      }
                      await FirebaseAuth.instance.currentUser!.delete();
                      navigator.pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
                    },

                    child: const Text(
                      'Отменить',
                      style: TextStyle(
                        color: Colors.cyan,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
}
