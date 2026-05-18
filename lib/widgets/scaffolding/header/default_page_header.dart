import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/adaptive_layout.dart';
import '../../../../utils/values/values.dart';
import '../../buttons/scroll_down_button.dart';
import '../../text/slide_box_transitioning_text.dart';

class DefaultPageHeader extends StatelessWidget {
  const DefaultPageHeader({
    required this.scrollController,
    required this.headingText,
    required this.headingTextController,
    super.key,
  });

  final ScrollController scrollController;
  final String headingText;
  final AnimationController headingTextController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      height: Get.height,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(80.0),
              child: Image.asset(
                ImagePath.DEFAULT_PAGE_HEADER,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: LayoutBuilder(builder: (context, constraints) {
              return AnimatedSlideBoxTransitionText(
                controller: headingTextController,
                width: constraints.maxWidth,
                text: headingText,
                textStyle: Get.textTheme.displayMedium?.copyWith(
                  fontSize: responsiveSize(
                    mobile: Sizes.TEXT_SIZE_40,
                    tabletSmall: Sizes.TEXT_SIZE_50,
                    desktop: Sizes.TEXT_SIZE_60,
                  ),
                ),
              );
            }),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ScrollDownButton(scrollController: scrollController),
          ),
        ],
      ),
    );
  }
}
