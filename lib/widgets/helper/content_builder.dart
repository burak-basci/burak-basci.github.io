import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/adaptive_layout.dart';
import '../../../utils/values/values.dart';
import '../../utils/values/spaces.dart';
import '../text/slide_box_transitioning_text.dart';

class ContentBuilder extends StatelessWidget {
  const ContentBuilder({
    required this.controller,
    required this.sectionNumber,
    required this.sectionLabel,
    required this.sectionBody,
    this.sectionHeading,
    this.headingStyle,
    this.customHeadingWidget,
    this.numberStyle,
    this.sectionLabelStyle,
    this.footerWidget,
    super.key,
  }) : assert(sectionHeading != null || customHeadingWidget != null);

  final AnimationController controller;
  final String sectionNumber;
  final String sectionLabel;
  final Widget sectionBody;
  final String? sectionHeading;
  final TextStyle? headingStyle;
  final Widget? customHeadingWidget;
  final TextStyle? numberStyle;
  final TextStyle? sectionLabelStyle;
  final Widget? footerWidget;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final TextStyle? defaultNumberStyle = Get.textTheme.bodyLarge?.copyWith(
          fontFamily: StringConst.INTER,
          fontSize: Sizes.TEXT_SIZE_12,
          color: CustomColors.black,
          fontWeight: FontWeight.w500,
          height: 2.0,
          letterSpacing: 2,
        );
        final TextStyle? defaultSectionStyle = defaultNumberStyle?.copyWith(
          color: CustomColors.grey600,
        );
        final TextStyle? defaultTitleStyle = Get.textTheme.titleMedium?.copyWith(
          color: CustomColors.black,
          fontSize: responsiveSize(
            mobile: Sizes.TEXT_SIZE_16,
            desktop: Sizes.TEXT_SIZE_20,
          ),
        );

        if (constraints.maxWidth < refinedBreakpoints.tablet) {
          return SizedBox(
            width: constraints.maxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AnimatedSlideBoxTransitionText(
                      controller: controller,
                      text: sectionNumber,
                      textStyle: numberStyle ?? defaultNumberStyle,
                    ),
                    const SpaceW8(),
                    AnimatedSlideBoxTransitionText(
                      controller: controller,
                      text: sectionLabel,
                      textStyle: sectionLabelStyle ?? defaultSectionStyle,
                    ),
                  ],
                ),
                const SpaceH16(),
                customHeadingWidget != null
                    ? customHeadingWidget!
                    : AnimatedSlideBoxTransitionText(
                        controller: controller,
                        text: sectionHeading!,
                        textStyle: headingStyle ?? defaultTitleStyle,
                      ),
                const SpaceH24(),
                sectionBody,
                footerWidget ?? const SizedBox(),
              ],
            ),
          );
        } else {
          return SizedBox(
            width: constraints.maxWidth,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AnimatedSlideBoxTransitionText(
                        controller: controller,
                        text: sectionNumber,
                        textStyle: numberStyle ?? defaultNumberStyle,
                      ),
                      const SpaceW16(),
                      Expanded(
                        child: AnimatedSlideBoxTransitionText(
                          controller: controller,
                          text: sectionLabel,
                          textStyle: sectionLabelStyle ?? defaultSectionStyle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SpaceW40(),
                SizedBox(
                  width: constraints.maxWidth * 0.75,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      customHeadingWidget ??
                          AnimatedSlideBoxTransitionText(
                            controller: controller,
                            text: sectionHeading!,
                            textStyle: headingStyle ?? defaultTitleStyle,
                          ),
                      const SpaceH20(),
                      sectionBody,
                      footerWidget ?? const SizedBox(),
                    ],
                  ),
                )
              ],
            ),
          );
        }
      },
    );
  }
}
