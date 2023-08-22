import 'package:flutter/material.dart';

import '../../../utils/values/values.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    this.title = "BB",
    this.titleColor = AppColors.black,
    this.titleStyle,
    this.fontSize = 60,
    Key? key,
  }) : super(key: key);

  final String title;
  final TextStyle? titleStyle;
  final Color titleColor;
  final double? fontSize;
  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return InkWell(
      hoverColor: Colors.transparent,
      onTap: () {
        Navigator.pushNamed(context, StringConst.HOME_PAGE);
      },
      child: Text(
        title,
        style: titleStyle ??
            textTheme.headline2?.copyWith(
              color: titleColor,
              fontSize: fontSize,
            ),
      ),
    );
  }
}
