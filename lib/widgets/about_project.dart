import 'package:flutter/material.dart';

import '../../utils/adaptive_layout.dart';
import '../../utils/functions.dart';
import '../../utils/values/values.dart';
import '../pages/project_detail/widgets/project_item.dart';
import '../utils/values/spaces.dart';
import 'animations/animated_bubble_button.dart';
import 'animations/animated_positioned_text.dart';
import 'animations/animated_positioned_widget.dart';
import 'animations/animated_text_slide_box_transition.dart';

List<String> titles = <String>[
  StringConst.PLATFORM,
  StringConst.CATEGORY,
  StringConst.AUTHOR,
  StringConst.DESIGNER,
  StringConst.TECHNOLOGY_USED,
];

class AboutProject extends StatefulWidget {
  const AboutProject({
    Key? key,
    required this.controller,
    required this.projectDataController,
    required this.projectData,
    required this.width,
  }) : super(key: key);

  final AnimationController controller;
  final AnimationController projectDataController;
  final ProjectItemData projectData;
  final double width;

  @override
  AboutProjectState createState() => AboutProjectState();
}

class AboutProjectState extends State<AboutProject> {
  @override
  void initState() {
    super.initState();

    widget.controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.projectDataController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const double googlePlayButtonWidth = 150;
    final double targetWidth = responsiveSize(context, 118, 150, medium: 150);
    final double initialWidth = responsiveSize(context, 36, 50, medium: 50);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? bodyTextStyle = textTheme.bodyText1?.copyWith(
      fontSize: Sizes.TEXT_SIZE_18,
      color: AppColors.grey750,
      fontWeight: FontWeight.w400,
      height: 2.0,
    );
    final double projectDataWidth = responsiveSize(
      context,
      widget.width,
      widget.width * 0.55,
      medium: widget.width * 0.75,
    );
    final double projectDataSpacing = responsiveSize(context, widget.width * 0.1, 48, medium: 36);
    final double widthOfProjectItem = (projectDataWidth - (projectDataSpacing)) / 2;
    const BorderRadiusGeometry borderRadius = BorderRadius.all(
      Radius.circular(100.0),
    );
    TextStyle? buttonStyle = textTheme.bodyText1?.copyWith(
      color: AppColors.black,
      fontSize: responsiveSize(
        context,
        Sizes.TEXT_SIZE_14,
        Sizes.TEXT_SIZE_16,
        small: Sizes.TEXT_SIZE_15,
      ),
      fontWeight: FontWeight.w500,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AnimatedTextSlideBoxTransition(
          controller: widget.controller,
          text: StringConst.ABOUT_PROJECT,
          coverColor: AppColors.white,
          textStyle: textTheme.headline4?.copyWith(
            fontSize: Sizes.TEXT_SIZE_48,
          ),
        ),
        const SpaceH40(),
        AnimatedPositionedText(
          controller: CurvedAnimation(
            parent: widget.controller,
            curve: Animations.textSlideInCurve,
          ),
          width: widget.width * 0.7,
          maxLines: 10,
          text: widget.projectData.portfolioDescription,
          textStyle: bodyTextStyle,
        ),
        // SpaceH12(),
        SizedBox(
          width: projectDataWidth,
          child: Wrap(
            spacing: projectDataSpacing,
            runSpacing: responsiveSize(context, 30, 40),
            children: <Widget>[
              ProjectData(
                controller: widget.projectDataController,
                width: widthOfProjectItem,
                title: StringConst.PLATFORM,
                subtitle: widget.projectData.platform,
              ),
              ProjectData(
                controller: widget.projectDataController,
                width: widthOfProjectItem,
                title: StringConst.CATEGORY,
                subtitle: widget.projectData.category,
              ),
              ProjectData(
                controller: widget.projectDataController,
                width: widthOfProjectItem,
                title: StringConst.AUTHOR,
                subtitle: StringConst.DEV_NAME,
              ),
            ],
          ),
        ),
        widget.projectData.designer != null ? const SpaceH30() : const SizedBox(),
        widget.projectData.designer != null
            ? ProjectData(
                controller: widget.projectDataController,
                title: StringConst.DESIGNER,
                subtitle: widget.projectData.designer!,
              )
            : const SizedBox(),
        widget.projectData.technologyUsed != null ? const SpaceH30() : const SizedBox(),
        widget.projectData.technologyUsed != null
            ? ProjectData(
                controller: widget.projectDataController,
                title: StringConst.TECHNOLOGY_USED,
                subtitle: widget.projectData.technologyUsed!,
              )
            : const SizedBox(),
        const SpaceH30(),
        Row(
          children: <Widget>[
            widget.projectData.isLive
                ? AnimatedPositionedWidget(
                    controller: CurvedAnimation(
                      parent: widget.projectDataController,
                      curve: Animations.textSlideInCurve,
                    ),
                    width: targetWidth,
                    height: initialWidth,
                    child: AnimatedBubbleButton(
                      title: StringConst.LAUNCH_APP,
                      color: AppColors.grey100,
                      imageColor: AppColors.black,
                      startBorderRadius: borderRadius,
                      startWidth: initialWidth,
                      height: initialWidth,
                      targetWidth: targetWidth,
                      titleStyle: buttonStyle,
                      onTap: () {
                        Functions.launchUrl(widget.projectData.webUrl);
                      },
                      startOffset: const Offset(0, 0),
                      targetOffset: const Offset(0.1, 0),
                    ),
                  )
                : const SizedBox(),
            widget.projectData.isLive ? const Spacer() : const SizedBox(),
            widget.projectData.isPublic
                ? AnimatedPositionedWidget(
                    controller: CurvedAnimation(
                      parent: widget.projectDataController,
                      curve: Animations.textSlideInCurve,
                    ),
                    width: targetWidth,
                    height: initialWidth,
                    child: AnimatedBubbleButton(
                      title: StringConst.SOURCE_CODE,
                      color: AppColors.grey100,
                      imageColor: AppColors.black,
                      startBorderRadius: borderRadius,
                      startWidth: initialWidth,
                      height: initialWidth,
                      targetWidth: targetWidth,
                      titleStyle: buttonStyle,
                      startOffset: const Offset(0, 0),
                      targetOffset: const Offset(0.1, 0),
                      onTap: () {
                        Functions.launchUrl(widget.projectData.gitHubUrl);
                      },
                    ),
                  )
                : const SizedBox(),
            widget.projectData.isPublic ? const Spacer() : const SizedBox(),
          ],
        ),
        widget.projectData.isPublic || widget.projectData.isLive ? const SpaceH30() : const SizedBox(),
        widget.projectData.isOnPlayStore
            ? InkWell(
                onTap: () {
                  Functions.launchUrl(widget.projectData.playStoreUrl);
                },
                child: AnimatedPositionedWidget(
                  controller: CurvedAnimation(
                    parent: widget.projectDataController,
                    curve: Animations.textSlideInCurve,
                  ),
                  width: googlePlayButtonWidth,
                  height: 50,
                  child: Image.asset(
                    ImagePath.GOOGLE_PLAY,
                    width: googlePlayButtonWidth,
                    // fit: BoxFit.fitHeight,
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}

class ProjectData extends StatelessWidget {
  const ProjectData({
    required this.title,
    required this.subtitle,
    required this.controller,
    this.width = double.infinity,
    this.titleStyle,
    this.subtitleStyle,
    Key? key,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final double width;
  final AnimationController controller;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final TextStyle? defaultTitleStyle = textTheme.subtitle1?.copyWith(
      color: AppColors.black,
      fontSize: 17,
    );
    final TextStyle? defaultSubtitleStyle = textTheme.bodyText1?.copyWith(
      fontSize: 15,
    );

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedTextSlideBoxTransition(
            width: width,
            maxLines: 2,
            coverColor: AppColors.white,
            controller: controller,
            text: title,
            textStyle: titleStyle ?? defaultTitleStyle,
          ),
          const SpaceH12(),
          AnimatedPositionedText(
            width: width,
            maxLines: 2,
            controller: CurvedAnimation(
              parent: controller,
              curve: Animations.textSlideInCurve,
            ),
            text: subtitle,
            textStyle: subtitleStyle ?? defaultSubtitleStyle,
          ),
        ],
      ),
    );
  }
}
