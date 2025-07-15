import 'package:flutter/material.dart';
import 'package:reciperover/Components/consts.dart';

class TextFieldContainer extends StatelessWidget {
  final Widget child;
  const TextFieldContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: LightPurple,
        borderRadius: BorderRadius.circular(29),
      ),
      child: child,
    );
  }
}
