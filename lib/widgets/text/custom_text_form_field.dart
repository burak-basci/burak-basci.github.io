import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils/values/values.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    this.controller,
    this.labelText,
    this.title = '',
    this.titleStyle,
    this.hasTitle = true,
    this.textStyle,
    this.hintTextStyle,
    this.labelStyle,
    this.contentPadding,
    this.border = Borders.primaryInputBorder,
    this.focusedBorder = Borders.focusedBorder,
    this.enabledBorder = Borders.enabledBorder,
    this.hintText,
    this.obscured = false,
    this.textInputType,
    this.onChanged,
    this.validator,
    this.inputFormatters,
    this.fillColor = AppColors.lightGreen,
    this.filled = false,
    this.maxLines = 1,
    Key? key,
  }) : super(key: key);

  final TextEditingController? controller;
  final String? labelText;
  final TextStyle? textStyle;
  final TextStyle? hintTextStyle;
  final TextStyle? labelStyle;
  final TextStyle? titleStyle;
  final String title;
  final String? hintText;
  final bool obscured;
  final TextInputType? textInputType;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final InputBorder border;
  final InputBorder enabledBorder;
  final InputBorder focusedBorder;
  final EdgeInsetsGeometry? contentPadding;
  final Color fillColor;
  final bool filled;
  final bool hasTitle;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        hasTitle ? Text(title, style: titleStyle) : const SizedBox(),
        TextFormField(
          style: textStyle ??
              textTheme.bodyText1?.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.w400,
              ),
          controller: controller,
          keyboardType: textInputType,
          onChanged: onChanged,
          maxLines: maxLines,
          validator: validator,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            fillColor: fillColor,
            filled: filled,
            contentPadding: contentPadding,
            labelText: labelText,
            labelStyle: labelStyle ??
                textTheme.bodyText1?.copyWith(
                  color: AppColors.black100,
                ),
            border: border,
            enabledBorder: enabledBorder,
            focusedBorder: focusedBorder,
            hintText: hintText,
            hintStyle: hintTextStyle ??
                textTheme.bodyText1?.copyWith(
                  color: AppColors.black100,
                ),
          ),
          obscureText: obscured,
        ),
      ],
    );
  }
}
