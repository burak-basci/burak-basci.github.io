import 'package:burak_basci_website/pages/about/about_page.dart';
import 'package:burak_basci_website/utils/page_transition.dart';
import 'package:burak_basci_website/utils/values/spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../../utils/adaptive_layout.dart';
import '../../../../utils/functions.dart';
import '../../../../utils/i18n_strings.dart';
import '../../../../utils/values/values.dart';
import '../../../widgets/buttons/animated_bubble_button.dart';
import '../../../widgets/buttons/animated_underline_text_button.dart';
import '../../../widgets/buttons/socials_icon_button.dart';
import '../../../widgets/text/self_positioning_text.dart';
import '../../../widgets/text/self_positioning_widget.dart';
import '../../../widgets/text/slide_box_transitioning_text.dart';

class HomeAboutDev extends StatefulWidget {
  const HomeAboutDev({
    required this.controller,
    required this.width,
    super.key,
  });

  final AnimationController controller;
  final double width;

  @override
  HomeAboutDevState createState() => HomeAboutDevState();
}

class HomeAboutDevState extends State<HomeAboutDev> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const EdgeInsetsGeometry margin = EdgeInsets.only(left: 16);
      final double headerFontSize = responsiveSize(
        mobile: 28,
        tabletSmall: 32,
        tabletNormal: 36,
        desktop: 48,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: margin,
            child: AnimatedSlideBoxTransitionText(
              controller: widget.controller,
              text: Tr.of('home.hi'),
              width: widget.width,
              textStyle: Get.textTheme.displayMedium?.copyWith(
                color: CustomColors.black,
                fontSize: headerFontSize,
              ),
            ),
          ),
          const SpaceH12(),
          Container(
            margin: margin,
            child: AnimatedSlideBoxTransitionText(
              controller: widget.controller,
              text: Tr.of('home.dev_intro'),
              width: widget.width,
              textStyle: Get.textTheme.displayMedium?.copyWith(
                color: CustomColors.black,
                fontSize: headerFontSize,
              ),
            ),
          ),
          const SpaceH12(),
          Container(
            margin: margin,
            child: AnimatedSlideBoxTransitionText(
              controller: widget.controller,
              text: Tr.of('home.dev_title'),
              width: responsiveSize(
                mobile: widget.width * 0.75,
                desktop: widget.width,
                tabletNormal: widget.width,
                tabletSmall: widget.width,
              ),
              textStyle: Get.textTheme.displayMedium?.copyWith(
                fontSize: headerFontSize,
              ),
            ),
          ),
          const SpaceH32(),
          Container(
            margin: margin,
            child: SelfPositioningText(
              controller: widget.controller,
              width: widget.width,
              heightFactor: 2,
              text: Tr.of('home.dev_desc'),
              textStyle: Get.textTheme.bodyLarge?.copyWith(
                fontSize: responsiveSize(
                  mobile: Sizes.TEXT_SIZE_16,
                  desktop: Sizes.TEXT_SIZE_18,
                ),
                height: 2,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SpaceH32(),
          SelfPositioningWidget(
            controller: widget.controller,
            width: 240,
            height: 60,
            child: Align(
              alignment: Alignment.center,
              child: AnimatedBubbleButton(
              bubbleColor: CustomColors.grey100,
              imageColor: CustomColors.black,
              targetWidth: 200,
              title: Tr.of('home.see_my_work').toUpperCase(),
              titleStyle: Get.textTheme.bodyLarge?.copyWith(
                color: CustomColors.black,
                fontSize: responsiveSize(
                  mobile: Sizes.TEXT_SIZE_14,
                  tabletSmall: Sizes.TEXT_SIZE_16,
                  desktop: Sizes.TEXT_SIZE_16,
                ),
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
              onTap: () {
                PageTransition.goTo(context, AboutPage.aboutPageRoute);
              },
              ),
            ),
          ),
          const SpaceH40(),
          Container(
            margin: margin,
            child: Wrap(
              spacing: 4.0,
              runSpacing: 0.0,
              children: _buildSocials(
                context: context,
                data: Data.socialData,
              ),
            ),
          )
        ],
      );
    });
  }

  List<Widget> _buildSocials({
    required BuildContext context,
    required List<SocialData> data,
  }) {
    List<Widget> items = <Widget>[];

    for (int index = 0; index < data.length; index++) {
      items.add(
        AnimatedUnderlineTextButton(
          text: data[index].name,
          slideBoxController: widget.controller,
          hasSlideBoxAnimation: true,
          underlineBottomOffset: 1.0,
          textStyle: Get.textTheme.bodyLarge?.copyWith(
            fontFamily: StringConst.INTER,
            fontSize: Sizes.TEXT_SIZE_16,
            fontWeight: FontWeight.w300,
            color: CustomColors.grey750,
            decoration: TextDecoration.underline,
          ),
          onTap: () {
            Functions.launchUrl(data[index].url);
          },
        ),
      );

      if (index < data.length - 1) {
        items.add(
          Text(
            '/ ',
            style: Get.textTheme.bodyLarge?.copyWith(
              color: CustomColors.grey750,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          )
              .animate(controller: widget.controller, autoPlay: false)
              .fadeIn(
                duration: const Duration(milliseconds: 400),
                delay: Duration(milliseconds: 1000 + index * 200),
                curve: Curves.easeOut,
              )
              .slideY(
                begin: 0.5,
                end: 0,
                duration: const Duration(milliseconds: 500),
                delay: Duration(milliseconds: 1000 + index * 200),
                curve: Curves.fastOutSlowIn,
              ),
        );
      }
    }

    return items;
  }
}
