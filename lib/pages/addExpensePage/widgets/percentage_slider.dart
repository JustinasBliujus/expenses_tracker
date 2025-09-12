import 'package:flutter/material.dart';
class PercentageSlider extends StatefulWidget {
  final int step;
  const PercentageSlider({super.key, this.step = 5});

  @override
  State<PercentageSlider> createState() => _PercentageSliderState();
}

class _PercentageSliderState extends State<PercentageSlider> {
  double value = 100;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: (100 ~/ widget.step),
          label: "${value.round()}%",
          onChanged: (newValue) {
            setState(() {
              value = newValue;
            });
          },
        ),
        Text("Selected: ${value.round()}%"),
      ],
    );
  }
}
