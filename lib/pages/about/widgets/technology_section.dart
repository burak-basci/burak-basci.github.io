import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../utils/values/values.dart';
import '../../../utils/values/spaces.dart';
import '../../../widgets/animations/animated_positioned_text.dart';
import '../../../widgets/animations/animated_text_slide_box_transition.dart';

const double spacing = 20;

class TechnologySection extends StatelessWidget {
  const TechnologySection({
    required this.controller,
    required this.width,
    Key? key,
  }) : super(key: key);

  final AnimationController controller;

  final double width;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? titleStyle = textTheme.subtitle1?.copyWith(
      fontSize: Sizes.TEXT_SIZE_16,
      color: AppColors.black,
    );
    return SizedBox(
      width: width,
      child: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          final double screenWidth = sizingInformation.screenSize.width;

          if (screenWidth < const RefinedBreakpoints().tabletNormal) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AnimatedTextSlideBoxTransition(
                  controller: controller,
                  width: screenWidth,
                  text: StringConst.PROGRAMMING_LANGUAGES,
                  textStyle: titleStyle,
                ),
                const SpaceH20(),
                Wrap(
                  direction: Axis.vertical,
                  spacing: 16,
                  children: _buildTechnologies(
                    context,
                    controller: controller,
                    data: Data.programmingLanguages,
                    width: screenWidth,
                  ),
                ),
                const SpaceH40(),
                AnimatedTextSlideBoxTransition(
                  controller: controller,
                  width: screenWidth,
                  text: StringConst.APPLICATIONS,
                  textStyle: titleStyle,
                ),
                const SpaceH20(),
                Wrap(
                  direction: Axis.vertical,
                  spacing: 16,
                  children: _buildTechnologies(
                    context,
                    controller: controller,
                    data: Data.applications,
                    width: screenWidth,
                  ),
                ),
                const SpaceH40(),
                AnimatedTextSlideBoxTransition(
                  controller: controller,
                  width: screenWidth,
                  text: StringConst.OTHER_SOFTWARE,
                  textStyle: titleStyle,
                ),
                const SpaceH20(),
                Wrap(
                  direction: Axis.vertical,
                  spacing: 16,
                  children: _buildTechnologies(
                    context,
                    controller: controller,
                    data: Data.otherSoftware,
                    width: screenWidth,
                  ),
                ),
              ],
            );
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AnimatedTextSlideBoxTransition(
                        controller: controller,
                        width: width * 0.25,
                        text: StringConst.PROGRAMMING_LANGUAGES,
                        textStyle: titleStyle,
                      ),
                      const SpaceH20(),
                      Row(
                        children: <Widget>[
                          const SpaceW4(),
                          Expanded(
                            child: Wrap(
                              direction: Axis.vertical,
                              spacing: spacing,
                              clipBehavior: Clip.antiAlias,
                              children: _buildTechnologies(
                                context,
                                controller: controller,
                                data: Data.programmingLanguages,
                                width: width * 0.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AnimatedTextSlideBoxTransition(
                        controller: controller,
                        width: (width * 0.25),
                        text: StringConst.APPLICATIONS,
                        textStyle: titleStyle,
                      ),
                      const SpaceH20(),
                      Row(
                        children: <Widget>[
                          const SpaceW4(),
                          Expanded(
                            child: Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: _buildTechnologies(
                                context,
                                controller: controller,
                                data: Data.applications,
                                width: width * 0.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AnimatedTextSlideBoxTransition(
                        controller: controller,
                        width: (width * 0.25),
                        text: StringConst.OTHER_SOFTWARE,
                        textStyle: titleStyle,
                      ),
                      const SpaceH20(),
                      Row(
                        children: <Widget>[
                          const SpaceW4(),
                          Expanded(
                            child: Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: _buildTechnologies(
                                context,
                                controller: controller,
                                data: Data.otherSoftware,
                                width: width * 0.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  List<Widget> _buildTechnologies(
    BuildContext context, {
    required List<String> data,
    required AnimationController controller,
    double? width,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? bodyText1Style = textTheme.bodyText1?.copyWith(
      fontSize: Sizes.TEXT_SIZE_15,
      color: AppColors.grey750,
      fontWeight: FontWeight.w400,
    );
    List<Widget> items = <Widget>[];
    for (var item in data) {
      items.add(
        SizedBox(
          width: width,
          child: AnimatedPositionedText(
            controller: CurvedAnimation(
              parent: controller,
              curve: const Interval(
                0.6,
                1.0,
                curve: Curves.ease,
              ),
            ),
            text: item,
            textStyle: bodyText1Style,
          ),
        ),
      );
    }

    return items;
  }
}
