import 'package:code_learn/app_constants/colors.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;

  const Button({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppColors.card1,
    this.textColor = AppColors.background,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(color: textColor,fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}