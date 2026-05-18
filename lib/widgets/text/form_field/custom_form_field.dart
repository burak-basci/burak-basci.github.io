import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/values/values.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    this.controller,
    this.labelText,
    this.title = '',
    this.hasTitle = true,
    this.titleStyle,
    // this.textStyle,
    // this.hintTextStyle,
    // this.labelStyle,
    // this.contentPadding,
    // this.border = Borders.primaryInputBorder,
    // this.focusedBorder = Borders.focusedBorder,
    // this.enabledBorder = Borders.enabledBorder,
    // this.hintText,
    // this.obscured = false,
    this.textInputType,
    this.onChanged,
    // this.validator,
    // this.inputFormatters,
    // this.fillColor = AppColors.lightGreen,
    this.filled = false,
    this.maxLines = 1,
    super.key,
  });

  final TextEditingController? controller;
  final String? labelText;
  final String title;
  final bool hasTitle;
  final TextStyle? titleStyle;
  // final TextStyle? textStyle;
  // final TextStyle? hintTextStyle;
  // final TextStyle? labelStyle;
  // final EdgeInsetsGeometry? contentPadding;
  // final String? hintText;
  // final bool obscured;
  final TextInputType? textInputType;
  final ValueChanged<String>? onChanged;
  // final FormFieldValidator<String>? validator;
  // final List<TextInputFormatter>? inputFormatters;
  // final InputBorder border;
  // final InputBorder enabledBorder;
  // final InputBorder focusedBorder;
  // final Color fillColor;
  final bool filled;
  final int? maxLines;

  static const UnderlineInputBorder primaryInputBorder = UnderlineInputBorder(
    borderSide: BorderSide(
      color: CustomColors.grey,
      width: Sizes.WIDTH_1,
      style: BorderStyle.solid,
    ),
  );

  static const UnderlineInputBorder enabledBorder = UnderlineInputBorder(
    borderSide: BorderSide(
      color: CustomColors.grey, //AppColors.primaryColor,
      width: Sizes.WIDTH_2,
      style: BorderStyle.solid,
    ),
  );

  static const UnderlineInputBorder focusedBorder = UnderlineInputBorder(
    borderSide: BorderSide(
      color: CustomColors.black,
      width: Sizes.WIDTH_2,
      style: BorderStyle.solid,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        hasTitle ? Text(title, style: titleStyle) : const SizedBox(),
        TextFormField(
          style:
              // textStyle ??
              Get.textTheme.bodyLarge?.copyWith(
            color: CustomColors.black,
            fontWeight: FontWeight.w400,
          ),
          controller: controller,
          keyboardType: textInputType,
          onChanged: onChanged,
          maxLines: maxLines,
          // validator: validator,
          // inputFormatters: inputFormatters,
          decoration: InputDecoration(
            fillColor: CustomColors.lightGreen,
            filled: filled,
            // contentPadding: contentPadding,
            labelText: labelText,
            labelStyle:
                // labelStyle ??
                Get.textTheme.bodyLarge?.copyWith(
              color: CustomColors.black100,
            ),
            border: primaryInputBorder,
            enabledBorder: enabledBorder,
            focusedBorder: focusedBorder,
            // hintText: hintText,
            hintStyle:
                // hintTextStyle ??
                Get.textTheme.bodyLarge?.copyWith(
              color: CustomColors.black100,
            ),
          ),
          // obscureText: obscured,
        ),
      ],
    );
  }
}
