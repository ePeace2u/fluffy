import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:fluffy/services/snack_bar.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordRepeatController =
      TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool showLogin = true;
  bool isSignedUp = false;
  bool isHiddenPassword = true;
  bool submitemail = false;
  bool submitpassword = false;
  bool submitpasswordrepeat = false;
  bool enabled = false;


  _setDisabled() {
    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      if (showLogin == true) {
        setState(() {
          enabled = true;
        });
      }else if (_passwordRepeatController.text.isNotEmpty == true){
        setState(() {enabled = true;});
    }
      else{
        setState(() {enabled = false;});
      }
    }
    else{
      setState(() {enabled = false;});
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordRepeatController.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    final navigator = Navigator.of(context);

    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      print(e.code);

      if (e.code == "user-not-found" || e.code == "wrong-password") {
        SnackBarService.showSnackBar(
            context, "неправильный логин или пароль", true);
      } else {
        SnackBarService.showSnackBar(context, "хз че", true);
        return;
      }
    }
    navigator.pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }

  Future<void> signUp() async {
    final navigator = Navigator.of(context);

    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    if (_passwordController.text != _passwordRepeatController.text) {
      SnackBarService.showSnackBar(
        context,
        'Пароли должны совпадать',
        true,
      );
      return;
    }

    try {
      print("auth");
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      print(e.code);

      if (e.code == 'email-already-in-use') {
        SnackBarService.showSnackBar(
          context,
          'Такой Email уже используется, повторите попытку с использованием другого Email',
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

    navigator.pushNamed('/verify_email');
  }

  void togglePasswordView() {
    setState(() {
      isHiddenPassword = !isHiddenPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget logo() {
      return const Padding(
        padding: EdgeInsets.only(top: 100),
        child: Align(
          child: Text('Fluffy.ToDo',
              style: TextStyle(
                  color: Colors.black, fontFamily: 'Satisfy', fontSize: 40)),
        ),
      );
    }

    Widget input(Icon icon, String hint, TextEditingController controller,
        bool obscure) {
      return Container(
          color: Colors.white,
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: (obscure == false)
              ? TextFormField(
                onChanged: (text) {
                  _setDisabled();
                },
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  controller: controller,
                  validator: (email) =>
                      email != null && !EmailValidator.validate(email)
                          ? 'Введите правильный Email'
                          : null,
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                  decoration: InputDecoration(
                      labelText: hint,
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
                            child: icon,
                          ))),
                )
              : TextFormField(
                onChanged: (text) {
                  _setDisabled();
                 },
                  autocorrect: false,
                  controller: controller,
                  obscureText: isHiddenPassword,
                  validator: (value) => value != null && value.length < 6
                      ? 'Минимум 6 символов'
                      : null,
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                  decoration: InputDecoration(
                      suffix: InkWell(
                          onTap: () {
                            setState(() {
                              togglePasswordView();
                            });
                          },
                          child: Icon(
                            isHiddenPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.black,
                          )),
                      labelText: hint,
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
                            child: icon,
                          ))),
                ));
    }

    Widget button(String text, void Function() func) {
      return Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: IgnorePointer(
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
            child: Text(text,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black)),
            onPressed: () {enabled ? func() : null;
            },
          ),
        )
      )
      );
    }

    Widget form(String label, Function() func, bool isSignedUp) {
      return Form(
        key: formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              child: input(
                  const Icon(Icons.email), "EMAIL", _emailController, false),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              child: input(const Icon(Icons.lock), "PASSWORD",
                  _passwordController, true),
            ),
            showLogin
                ? const SizedBox(height: 20)
                : Padding(
                    padding: const EdgeInsets.only(bottom: 20, top: 10),
                    child: input(const Icon(Icons.lock), "REPEAT PASSWORD",
                        _passwordRepeatController, true)),
            const SizedBox(height: 20),
            Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: button(label, func),
                ))
          ],
        ),
      );
    }

    void buttonActionReg() {
      signUp();
    }

    void buttonActionLog() {
      _login();
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          logo(),
          const SizedBox(height: 100),
          (showLogin
              ? Column(
                  children: [
                    form("LOGIN", buttonActionLog, true),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Not registered yet? ",
                              style: TextStyle(fontSize: 20)),
                          GestureDetector(
                              child: Text("SIGN UP",
                                  style: TextStyle(
                                      fontSize: 20,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.cyan,
                                      color: Colors.cyan)),
                              onTap: () {
                                setState(() {
                                  showLogin = false;
                                });
                              })
                        ],
                      ),
                    ),
                    GestureDetector(
                        child: Text("Forgot your password?",
                            style: TextStyle(
                                fontSize: 17,
                                decoration: TextDecoration.underline,
                                color: Colors.black87)),
                        onTap: () {
                          setState(() {
                            final navigator = Navigator.of(context);
                            navigator.pushNamed('/reset');
                          });
                        })
                  ],
                )
              : Column(
                  children: [
                    form("Sign Up", buttonActionReg, false),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already registered? ",
                              style: TextStyle(fontSize: 20)),
                          GestureDetector(
                              child: Text("LOGIN",
                                  style: TextStyle(
                                      fontSize: 20,
                                      decoration: TextDecoration.underline,
                                      color: Colors.cyan)),
                              onTap: () {
                                setState(() {
                                  showLogin = true;
                                });
                              })
                        ],
                      ),
                    ),
                  ],
                )),
        ],
      ),
    );
  }
}
