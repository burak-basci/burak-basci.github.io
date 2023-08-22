import 'package:flutter/material.dart';

import '../../../../utils/adaptive_layout.dart';
import '../../../../utils/functions.dart';
import '../../../../utils/values/values.dart';
import '../../../widgets/animated_line_through_text.dart';
import '../../../widgets/animations/animated_bubble_button.dart';
import '../../../widgets/animations/animated_positioned_text.dart';
import '../../../widgets/animations/animated_positioned_widget.dart';
import '../../../widgets/animations/animated_text_slide_box_transition.dart';
import '../../../widgets/buttons/socials_icon_button.dart';
import '../../work/work_page.dart';

class HomeAboutDev extends StatefulWidget {
  const HomeAboutDev({
    required this.controller,
    required this.width,
    Key? key,
  }) : super(key: key);

  final AnimationController controller;
  final double width;

  @override
  HomeAboutDevState createState() => HomeAboutDevState();
}

class HomeAboutDevState extends State<HomeAboutDev> {
  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    const EdgeInsetsGeometry margin = EdgeInsets.only(left: 16);
    final CurvedAnimation curvedAnimation = CurvedAnimation(
      parent: widget.controller,
      curve: const Interval(0.6, 1.0, curve: Curves.fastOutSlowIn),
    );
    final double headerFontSize = responsiveSize(context, 28, 48, medium: 36, small: 32);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: margin,
          child: AnimatedTextSlideBoxTransition(
            controller: widget.controller,
            text: StringConst.HI,
            width: widget.width,
            maxLines: 3,
            textStyle: textTheme.headline2?.copyWith(
              color: AppColors.black,
              fontSize: headerFontSize,
            ),
          ),
        ),
        const SizedBox(height: 12.0),
        Container(
          margin: margin,
          child: AnimatedTextSlideBoxTransition(
            controller: widget.controller,
            text: StringConst.DEV_INTRO,
            width: widget.width,
            maxLines: 3,
            textStyle: textTheme.headline2?.copyWith(
              color: AppColors.black,
              fontSize: headerFontSize,
            ),
          ),
        ),
        const SizedBox(height: 12.0),
        Container(
          margin: margin,
          child: AnimatedTextSlideBoxTransition(
            controller: widget.controller,
            text: StringConst.DEV_TITLE,
            width: responsiveSize(
              context,
              widget.width * 0.75,
              widget.width,
              medium: widget.width,
              small: widget.width,
            ),
            maxLines: 3,
            textStyle: textTheme.headline2?.copyWith(
              fontSize: headerFontSize,
            ),
          ),
        ),
        const SizedBox(height: 30.0),
        Container(
          margin: margin,
          child: AnimatedPositionedText(
            controller: curvedAnimation,
            width: widget.width,
            maxLines: 3,
            factor: 2,
            text: StringConst.DEV_DESC,
            textStyle: textTheme.bodyText1?.copyWith(
              fontSize: responsiveSize(
                context,
                Sizes.TEXT_SIZE_16,
                Sizes.TEXT_SIZE_18,
              ),
              height: 2,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 30.0),
        AnimatedPositionedWidget(
          controller: curvedAnimation,
          width: 200,
          height: 60,
          child: AnimatedBubbleButton(
            color: AppColors.grey100,
            imageColor: AppColors.black,
            startOffset: const Offset(0, 0),
            targetOffset: const Offset(0.04, 0),
            targetWidth: 200,
            startBorderRadius: const BorderRadius.all(
              Radius.circular(100.0),
            ),
            title: StringConst.SEE_MY_WORK.toUpperCase(),
            titleStyle: textTheme.bodyText1?.copyWith(
              color: AppColors.black,
              fontSize: responsiveSize(
                context,
                Sizes.TEXT_SIZE_14,
                Sizes.TEXT_SIZE_16,
                small: Sizes.TEXT_SIZE_15,
              ),
              fontWeight: FontWeight.w500,
            ),
            onTap: () {
              Navigator.pushNamed(context, WorksPage.worksPageRoute);
            },
          ),
        ),
        const SizedBox(height: 40.0),
        Container(
          margin: margin,
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            children: _buildSocials(
              context: context,
              data: Data.socialData,
            ),
          ),
        )
      ],
    );
  }

  List<Widget> _buildSocials({
    required BuildContext context,
    required List<SocialData> data,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? style = textTheme.bodyText1?.copyWith(color: AppColors.grey750);
    final TextStyle? slashStyle = textTheme.bodyText1?.copyWith(
      color: AppColors.grey750,
      fontWeight: FontWeight.w400,
      fontSize: 18,
    );
    List<Widget> items = <Widget>[];

    for (int index = 0; index < data.length; index++) {
      items.add(
        AnimatedLineThroughText(
          text: data[index].name,
          isUnderlinedByDefault: true,
          controller: widget.controller,
          hasSlideBoxAnimation: true,
          hasOffsetAnimation: true,
          isUnderlinedOnHover: false,
          onTap: () {
            Functions.launchUrl(data[index].url);
          },
          textStyle: style,
        ),
      );

      if (index < data.length - 1) {
        items.add(
          Text('/', style: slashStyle),
        );
      }
    }

    return items;
  }
}
