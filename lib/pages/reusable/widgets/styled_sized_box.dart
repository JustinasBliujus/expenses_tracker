import 'package:flutter/material.dart';

class StyledSizedBox extends StatelessWidget {
  final double height;

  const StyledSizedBox({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}