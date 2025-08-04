import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String data;
  final double? size;
  final Color? color;
  final FontWeight? fw;
  final TextAlign align;
  final String? family;

  AppText({
    Key? key,
    required this.data,
    this.size,
    this.family,
    this.color,
    this.fw,
    this.align = TextAlign.left,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    TextStyle baseStyle =  TextStyle(

      fontFamily: family??"Poppins"
    );

    TextStyle mergedStyle = baseStyle.copyWith(
      fontSize: size,
      color: color ?? baseStyle.color,
      fontWeight: fw,
    );

    return Text(
      data,
      textAlign: align,
      style: mergedStyle,
    );
  }
}
