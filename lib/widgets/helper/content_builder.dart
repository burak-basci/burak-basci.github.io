import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../utils/adaptive_layout.dart';
import '../../../utils/values/values.dart';
import '../../utils/values/spaces.dart';
import '../animations/animated_text_slide_box_transition.dart';

class ContentBuilder extends StatelessWidget {
  const ContentBuilder({
    required this.width,
    required this.number,
    required this.section,
    required this.body,
    required this.controller,
    this.title = '',
    this.numberStyle,
    this.sectionStyle,
    this.titleStyle,
    this.heading,
    this.footer,
    Key? key,
  }) : super(key: key);

  final double width;
  final AnimationController controller;
  final String number;
  final String section;
  final String? title;
  final TextStyle? numberStyle;
  final TextStyle? sectionStyle;
  final TextStyle? titleStyle;
  final Widget? heading;
  final Widget body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? defaultNumberStyle = textTheme.bodyText1?.copyWith(
      fontSize: Sizes.TEXT_SIZE_10,
      color: AppColors.black,
      fontWeight: FontWeight.w400,
      height: 2.0,
      letterSpacing: 2,
    );
    final TextStyle? defaultSectionStyle = defaultNumberStyle?.copyWith(
      color: AppColors.grey600,
    );
    final TextStyle? defaultTitleStyle = textTheme.subtitle1?.copyWith(
      color: AppColors.black,
      fontSize: responsiveSize(
        context,
        Sizes.TEXT_SIZE_16,
        Sizes.TEXT_SIZE_20,
      ),
    );
    return SizedBox(
      width: width,
      child: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          double screenWidth = sizingInformation.screenSize.width;

          if (screenWidth <= const RefinedBreakpoints().tabletNormal) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AnimatedTextSlideBoxTransition(
                      controller: controller,
                      text: number,
                      textStyle: numberStyle ?? defaultNumberStyle,
                    ),
                    const SpaceW8(),
                    AnimatedTextSlideBoxTransition(
                      controller: controller,
                      text: section,
                      textStyle: sectionStyle ?? defaultSectionStyle,
                    ),
                  ],
                ),
                const SpaceH16(),
                heading ??
                    AnimatedTextSlideBoxTransition(
                      controller: controller,
                      text: title!,
                      textStyle: titleStyle ?? defaultTitleStyle,
                    ),
                const SpaceH30(),
                body,
                footer ?? const SizedBox(),
              ],
            );
          } else {
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AnimatedTextSlideBoxTransition(
                        controller: controller,
                        text: number,
                        textStyle: numberStyle ?? defaultNumberStyle,
                      ),
                      const SpaceW16(),
                      Expanded(
                        child: AnimatedTextSlideBoxTransition(
                          controller: controller,
                          text: section,
                          textStyle: sectionStyle ?? defaultSectionStyle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SpaceW40(),
                SizedBox(
                  width: width * 0.75,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      heading ??
                          AnimatedTextSlideBoxTransition(
                            controller: controller,
                            text: title!,
                            textStyle: titleStyle ?? defaultTitleStyle,
                          ),
                      const SpaceH20(),
                      body,
                      footer ?? const SizedBox(),
                    ],
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }
}
