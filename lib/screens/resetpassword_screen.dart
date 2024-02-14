import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluffy/services/snack_bar.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController _emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool enabled = false;

  _setDisabled() {
    if (_emailController.text.isNotEmpty) {
        setState(() {
          enabled = true;
        });
    }
    else{
      setState(() {enabled = false;});
    }
  }

  @override
  void dispose() {
    _emailController.dispose();

    super.dispose();
  }

  Future<void> resetPassword() async {
    final navigator = Navigator.of(context);
    final scaffoldMassager = ScaffoldMessenger.of(context);

    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
    } on FirebaseAuthException catch (e) {
      print(e.code);

      if (e.code == 'user-not-found') {
        SnackBarService.showSnackBar(
          context,
          'Такой email незарегистрирован!',
          true,
        );
        return;
      } else {
        SnackBarService.showSnackBar(
          context,
          'Неизвестная ошибка! Попробуйте еще раз или обратитесь в поддержку.',
          true,
        );
        return;
      }
    }

    const snackBar = SnackBar(
      content: Text('Сброс пароля осуществен. Проверьте почту'),
      backgroundColor: Colors.green,
    );

    scaffoldMassager.showSnackBar(snackBar);

    navigator.pushNamedAndRemoveUntil('/stream', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.cyan,
        title: const Text('Fluffy.ToDo',style: TextStyle(
            color: Colors.black, fontFamily: 'Satisfy', fontSize: 28)),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 60,
                ),
                TextFormField(
                  onChanged: (text) {
                    _setDisabled();
                  },
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  controller: _emailController,
                  validator: (email) =>
                  email != null && !EmailValidator.validate(email)
                      ? 'Введите правильный Email'
                      : null,
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                  decoration: InputDecoration(
                      labelText: "EMAIL",
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black54),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan, width: 3.2)),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                          const BorderSide(color: Colors.cyan, width: 3.2),
                          borderRadius: BorderRadius.circular(30)),
                      prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: IconTheme(
                            data: const IconThemeData(color: Colors.black),
                            child: Icon(Icons.mail),
                          ))),
                ),
                const SizedBox(height: 30),
                IgnorePointer(
                    ignoring: !enabled,
                    child: Opacity(
                      opacity: !enabled ? 0.5 : 1.0,
                      child: ElevatedButton(
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
                        child: Text("Reset password",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.black)),
                        onPressed: () {enabled ? resetPassword() : null;
                        },
                      ),
                    )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}