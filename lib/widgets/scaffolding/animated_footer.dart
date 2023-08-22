import "package:flutter/material.dart";
import 'package:responsive_builder/responsive_builder.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../utils/adaptive_layout.dart';
import '../../../utils/values/values.dart';
import '../../pages/contact/contact_page.dart';
import '../../utils/values/spaces.dart';
import '../animations/animated_bubble_button.dart';
import '../animations/animated_positioned_text.dart';
import '../animations/animated_positioned_widget.dart';
import 'simple_footer.dart';

class AnimatedFooter extends StatefulWidget {
  const AnimatedFooter({
    this.height,
    this.width,
    this.backgroundColor = AppColors.black,
    Key? key,
  }) : super(key: key);

  final double? width;
  final double? height;
  final Color backgroundColor;

  @override
  AnimatedFooterState createState() => AnimatedFooterState();
}

class AnimatedFooterState extends State<AnimatedFooter> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double circleImageSize = responsiveSize(context, 150, 200);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? style = textTheme.bodyText1?.copyWith(
      color: AppColors.accentColor,
      fontSize: Sizes.TEXT_SIZE_14,
    );
    final TextStyle? titleStyle = textTheme.headline4?.copyWith(
      color: AppColors.accentColor,
      fontSize: responsiveSize(
        context,
        Sizes.TEXT_SIZE_30,
        Sizes.TEXT_SIZE_64,
        medium: Sizes.TEXT_SIZE_50,
      ),
    );
    final TextStyle? subtitleStyle = style?.copyWith(
      color: AppColors.grey550,
      fontSize: Sizes.TEXT_SIZE_18,
      fontWeight: FontWeight.w400,
    );

    return Container(
      width: widget.width ?? widthOfScreen(context),
      height: widget.height ?? assignHeight(context, 0.54),
      color: widget.backgroundColor,
      child: VisibilityDetector(
        key: const Key('animated-footer'),
        onVisibilityChanged: (visibilityInfo) {
          double visiblePercentage = visibilityInfo.visibleFraction * 100;
          if (visiblePercentage > 25) {
            controller.forward();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            SizedBox(
              height: circleImageSize,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    right: responsiveSize(
                      context,
                      assignWidth(context, 0.2),
                      assignWidth(context, 0.2),
                      medium: assignWidth(context, 0.2),
                    ),
                    child: AnimatedPositionedWidget(
                      controller: CurvedAnimation(
                        parent: controller,
                        curve: Curves.fastOutSlowIn,
                      ),
                      width: circleImageSize,
                      height: circleImageSize,
                      child: Image.asset(
                        ImagePath.CIRCLE,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  Center(
                    child: AnimatedPositionedText(
                      text: StringConst.WORK_TOGETHER,
                      textAlign: TextAlign.center,
                      textStyle: titleStyle,
                      controller: CurvedAnimation(
                        parent: controller,
                        curve: Curves.fastOutSlowIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Spacer(),
            AnimatedPositionedText(
              text: StringConst.AVAILABLE_FOR_FREELANCE,
              textAlign: TextAlign.center,
              textStyle: subtitleStyle,
              factor: 2.0,
              controller: CurvedAnimation(
                parent: controller,
                curve: Curves.fastOutSlowIn,
              ),
            ),
            const SpaceH40(),
            AnimatedBubbleButton(
              title: StringConst.SAY_HELLO.toUpperCase(),
              onTap: () {
                Navigator.pushNamed(context, ContactPage.contactPageRoute);
              },
            ),
            const Spacer(flex: 3),
            ResponsiveBuilder(
              builder: (context, sizingInformation) {
                double screenWidth = sizingInformation.screenSize.width;
                if (screenWidth <= const RefinedBreakpoints().tabletNormal) {
                  return const Column(
                    children: <Widget>[
                      SimpleFooterSmall(),
                      SpaceH8(),
                    ],
                  );
                } else {
                  return const Column(
                    children: <Widget>[
                      SimpleFooterLarge(),
                      SpaceH8(),
                    ],
                  );
                }
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
