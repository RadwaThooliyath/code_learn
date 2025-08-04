import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final String? fontFamily;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final double? letterSpacing;
  final double? lineHeight;
  final TextDecoration? decoration;
  final TextStyle? style;

  const AppText({
    Key? key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.fontFamily,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.letterSpacing,
    this.lineHeight,
    this.decoration,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ??
        TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          fontFamily: fontFamily,
          letterSpacing: letterSpacing,
          height: lineHeight,
          decoration: decoration,
        );

    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
