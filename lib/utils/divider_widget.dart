import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double thickness;
  final double indent;
  final double endIndent;

  const CustomDivider({
    Key? key,
    this.height = 1,
    this.color = Colors.black,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      color: color,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
    );
  }
}
