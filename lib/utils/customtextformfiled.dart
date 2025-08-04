import 'package:flutter/material.dart';

import '../app_constants/colors.dart';



class CustomTextFormField extends StatefulWidget {
  final bool readOnly;
  final TextEditingController controller;
  final TextStyle? hintstyle;

  final String hintText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final TextStyle? errorStyle;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final type;
  final String? value;
  final TextStyle? style;
  final maxlines;
  const CustomTextFormField({
    Key? key,
    this.hintstyle,
    this.errorStyle,
    this.readOnly = false,
    this.style,
    required this.controller,
    this.maxlines = 1,
    this.type = TextInputType.text,
    required this.hintText,
    this.obscureText = false,
    this.validator,
    this.enabledBorder,
    this.focusedBorder,
    this.prefixIcon,
    this.suffixIcon,
    this.value,
  }) : super(key: key);

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final themedata = Theme.of(context);
    return TextFormField(
      initialValue: widget.value,
      cursorColor: AppColors.champagnePink,
      readOnly: widget.readOnly,
      style: themedata.textTheme.titleSmall,
      maxLines: widget.maxlines,
      keyboardType: widget.type,
      controller: widget.controller,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(
          left: 20,
          top: 15,
          bottom: 15,
        ),
        filled: true,
        fillColor: AppColors.white,
        errorStyle: TextStyle(
            color: Colors.red, fontStyle: FontStyle.italic, fontSize: 12),
        hintStyle: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontStyle: FontStyle.italic,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400),
        hintText: widget.hintText,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.transparent)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.transparent)),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red),
        ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: _obscureText ? AppColors.champagnePink : AppColors.card1,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : widget.suffixIcon,
      ),
      obscureText: widget.obscureText && _obscureText,
      validator: widget.validator,
    );
  }
}
