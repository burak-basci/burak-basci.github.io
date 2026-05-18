import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/adaptive_layout.dart';
import '../../../utils/i18n_strings.dart';
import '../../../utils/values/spaces.dart';
import '../../../utils/values/values.dart';
import '../../../widgets/text/slide_box_transitioning_text.dart';

class AboutHeaderDescription extends StatelessWidget {
  const AboutHeaderDescription({
    required this.controller,
    required this.width,
    super.key,
  });

  final AnimationController controller;
  final double width;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final TextStyle? style = Get.textTheme.bodyLarge?.copyWith(
          fontFamily: StringConst.INTER,
          fontSize: responsiveSize(
            mobile: 23,
            desktop: 42,
            tabletSmall: 23,
            tabletNormal: 28,
          ),
          height: 1.2,
          fontWeight: FontWeight.w200,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedSlideBoxTransitionText(
              controller: controller,
              text: Tr.of('about.catch_line_1'),
              width: width,
              textStyle: style,
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < refinedBreakpoints.tabletSmall) {
                  return const SpaceH8();
                } else {
                  return const SpaceH24();
                }
              },
            ),
            AnimatedSlideBoxTransitionText(
              controller: controller,
              text: Tr.of('about.catch_line_2'),
              width: width,
              textStyle: style,
            ),
          ],
        );
      },
    );
  }
}
