import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/page_transition.dart';
import '../../../../utils/values/values.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    this.title = "BB",
    this.titleColor = CustomColors.black,
    this.fontSize = 60.0,
    super.key,
  });

  final String title;
  final Color titleColor;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      onTap: () {
        PageTransition.goTo(context, StringConst.HOME_PAGE);
      },
      child: Text(
        title,
        style: Get.textTheme.displayMedium?.copyWith(
          color: titleColor,
          fontSize: fontSize,
          fontFamily: StringConst.VISUELT_PRO,
        ),
      ),
    );
  }
}
