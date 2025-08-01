import 'package:expenses_tracker/main.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_action_button.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_header_text.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_sized_box.dart';
import 'package:expenses_tracker/pages/reusableWidgets/styled_text_form_field.dart';
import 'package:expenses_tracker/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginRegister extends StatefulWidget {
  const LoginRegister({super.key});

  @override
  State<LoginRegister> createState() => _LoginRegisterState();
}

class _LoginRegisterState extends State<LoginRegister> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text.trim(),
        password: _controllerPassword.text.trim(),

      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const MyApp()));
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : 'Error: $errorMessage',
      style: const TextStyle(color: Colors.red),
    );
  }

  Widget _hintText() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Text(
        isLogin
            ? 'Use a valid email and a password with at least 6 characters.'
            : 'Make sure your password is strong and at least 6 characters long.',
        style: const TextStyle(color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 80,),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StyledHeaderText(text: "Login or Register"),
                  const StyledSizedBox(height: 26),
                  StyledTextFormField(controller: _controllerEmail, labelText: 'Email',),
                  const SizedBox(height: 36),
                  StyledTextFormField(controller: _controllerPassword,
                      labelText: 'Password', isPassword: true),
                  const StyledSizedBox(height: 16),
                  _errorMessage(),
                  const StyledSizedBox(height: 16),
                  StyledActionButton(
                    buttonText:isLogin ? 'Login' : 'Register',
                    buttonColor: Colors.green,
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        isLogin ? signInWithEmailAndPassword() : createUserWithEmailAndPassword();
                      }
                    },),
                  const StyledSizedBox(height: 16),
                  StyledActionButton(buttonText:isLogin ? 'Register instead' : 'Login instead',
                    buttonColor: Colors.green,
                    onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },),
                  _hintText(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
