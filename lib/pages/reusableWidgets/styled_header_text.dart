import 'package:flutter/material.dart';

class StyledHeaderText extends StatelessWidget {
  final String text;

  const StyledHeaderText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 25),
    );
  }
}