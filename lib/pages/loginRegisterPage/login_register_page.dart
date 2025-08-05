import 'package:expenses_tracker/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expenses_tracker/pages/reusable/reusable_export.dart';

class LoginRegister extends StatefulWidget {
  const LoginRegister({super.key});

  @override
  State<LoginRegister> createState() => _LoginRegisterState();
}

class _LoginRegisterState extends State<LoginRegister> {
  String? errorMessage = '';
  bool isLogin = true;
  bool isLoading = false;

  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerPassword = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  Future<void> signInWithEmailAndPassword() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      await Auth().signInWithEmailAndPassword(
        email: controllerEmail.text.trim(),
        password: controllerPassword.text.trim(),
      );
      if (!mounted) return;
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      await Auth().createUserWithEmailAndPassword(
        email: controllerEmail.text.trim(),
        password: controllerPassword.text.trim(),
      );
      if (!mounted) return;
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget errorMessageWidget() {
    return Text(
      errorMessage == '' ? '' : 'Error: $errorMessage',
      style: const TextStyle(color: AppColors.error),
    );
  }

  Widget hintText() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Text(
        isLogin
            ? 'Use a valid email and a password with at least 6 characters.'
            : 'Make sure your password is strong and at least 6 characters long.',
        style: const TextStyle(color: AppColors.unknown),
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
        child: isLoading ? Center(child: StyledCircularProgressIndicator())
            :Column(
          children: [
            const StyledSizedBox(height: 80,),
            Form(
            key: isLogin ? loginFormKey : registerFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text("Login or Register",style: TextStyles.header,),
                  ),
                  const StyledSizedBox(height: 26),
                  StyledTextFormField(controller: controllerEmail, labelText: 'Email',),
                  const SizedBox(height: 16),
                  StyledTextFormField(controller: controllerPassword,
                      labelText: 'Password', isPassword: true),
                  const StyledSizedBox(height: 16),
                  errorMessageWidget(),
                  const StyledSizedBox(height: 16),
                  StyledActionButton(
                    buttonText:isLogin ? 'Login' : 'Register',
                    buttonColor: AppColors.affirmative,
                    onPressed: () {
                      if ((isLogin ? loginFormKey : registerFormKey).currentState?.validate() ?? false) {
                        isLogin ? signInWithEmailAndPassword() : createUserWithEmailAndPassword();
                      }
                    },),
                  const StyledSizedBox(height: 16),
                  StyledActionButton(buttonText:isLogin ? 'Register instead' : 'Login instead',
                    buttonColor: AppColors.affirmative,
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                      });
                    },),
                  hintText(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
