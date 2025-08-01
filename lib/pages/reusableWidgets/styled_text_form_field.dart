import 'package:flutter/material.dart';

class StyledTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool isPassword;
  final TextInputType keyboardType;

  const StyledTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  /// Named constructor for password fields
  const StyledTextFormField.password({
    super.key,
    required this.controller,
    this.labelText = 'Password',
  })  : isPassword = true,
        keyboardType = TextInputType.text;

  String? _validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your $labelText';
    }
    if (labelText.toLowerCase() == 'email' &&
        !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    if (isPassword && value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelStyle: const TextStyle(color: Colors.black),
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      validator: _validator,
    );
  }
}
