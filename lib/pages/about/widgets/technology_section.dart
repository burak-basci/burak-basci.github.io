import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/values/values.dart';
import '../../../utils/adaptive_layout.dart';
import '../../../utils/i18n_strings.dart';
import '../../../utils/values/spaces.dart';
import '../../../widgets/text/self_positioning_text.dart';
import '../../../widgets/text/slide_box_transitioning_text.dart';

class TechnologySection extends StatelessWidget {
  const TechnologySection({
    required this.controller,
    required this.selfPositioningController,
    required this.width,
    super.key,
  });

  final AnimationController controller;
  final AnimationController selfPositioningController;

  final double width;

  @override
  Widget build(BuildContext context) {
    final TextStyle? titleStyle = Get.textTheme.titleMedium?.copyWith(
      fontSize: Sizes.TEXT_SIZE_18,
      fontWeight: FontWeight.w700,
      color: CustomColors.black,
    );
    return SizedBox(
      width: width,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = constraints.maxWidth;

          if (Get.width < refinedBreakpoints.tabletSmall) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AnimatedSlideBoxTransitionText(
                  controller: controller,
                  width: screenWidth,
                  text: Tr.of('about.tech.programming_languages'),
                  textStyle: titleStyle,
                ),
                const SpaceH16(),
                Wrap(
                  direction: Axis.vertical,
                  spacing: 4.0,
                  children: _buildTechnologySection(
                    context,
                    selfPositioningController: selfPositioningController,
                    data: Data.programmingLanguages,
                    width: screenWidth,
                  ),
                ),
                const SpaceH32(),
                AnimatedSlideBoxTransitionText(
                  controller: controller,
                  width: screenWidth,
                  text: Tr.of('about.tech.applications'),
                  textStyle: titleStyle,
                ),
                const SpaceH16(),
                Wrap(
                  direction: Axis.vertical,
                  spacing: 4.0,
                  children: _buildTechnologySection(
                    context,
                    selfPositioningController: selfPositioningController,
                    data: Data.applications,
                    width: screenWidth,
                  ),
                ),
                const SpaceH32(),
                AnimatedSlideBoxTransitionText(
                  controller: controller,
                  width: screenWidth,
                  text: Tr.of('about.tech.other_software'),
                  textStyle: titleStyle,
                ),
                const SpaceH16(),
                Wrap(
                  direction: Axis.vertical,
                  spacing: 4.0,
                  children: _buildTechnologySection(
                    context,
                    selfPositioningController: selfPositioningController,
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
                      AnimatedSlideBoxTransitionText(
                        controller: controller,
                        width: width * 0.25,
                        text: Tr.of('about.tech.programming_languages'),
                        textStyle: titleStyle,
                      ),
                      const SpaceH16(),
                      Row(
                        children: <Widget>[
                          const SpaceW4(),
                          Expanded(
                            child: Wrap(
                              direction: Axis.vertical,
                              spacing: 8.0,
                              clipBehavior: Clip.antiAlias,
                              children: _buildTechnologySection(
                                context,
                                selfPositioningController: selfPositioningController,
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
                      AnimatedSlideBoxTransitionText(
                        controller: controller,
                        width: (width * 0.25),
                        text: Tr.of('about.tech.applications'),
                        textStyle: titleStyle,
                      ),
                      const SpaceH16(),
                      Row(
                        children: <Widget>[
                          const SpaceW4(),
                          Expanded(
                            child: Wrap(
                              direction: Axis.vertical,
                              spacing: 8.0,
                              clipBehavior: Clip.antiAlias,
                              children: _buildTechnologySection(
                                context,
                                selfPositioningController: selfPositioningController,
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
                      AnimatedSlideBoxTransitionText(
                        controller: controller,
                        width: (width * 0.25),
                        text: Tr.of('about.tech.other_software'),
                        textStyle: titleStyle,
                      ),
                      const SpaceH16(),
                      Row(
                        children: <Widget>[
                          const SpaceW4(),
                          Expanded(
                            child: Wrap(
                              direction: Axis.vertical,
                              spacing: 8.0,
                              clipBehavior: Clip.antiAlias,
                              children: _buildTechnologySection(
                                context,
                                selfPositioningController: selfPositioningController,
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

  List<Widget> _buildTechnologySection(
    BuildContext context, {
    required List<String> data,
    required AnimationController selfPositioningController,
    required double width,
  }) {
    final TextStyle? bodyText1Style = Get.textTheme.bodyLarge?.copyWith(
      fontSize: Sizes.TEXT_SIZE_16,
      color: CustomColors.grey750,
      fontWeight: FontWeight.w300,
      height: 1.6,
    );
    List<Widget> items = <Widget>[];
    for (var item in data) {
      items.add(
        SizedBox(
          width: width,
          child: SelfPositioningText(
            width: width,
            controller: selfPositioningController,
            text: item,
            textStyle: bodyText1Style,
          ),
        ),
      );
    }

    return items;
  }
}
