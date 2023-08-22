import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../utils/adaptive_layout.dart';
import '../../../utils/functions.dart';
import '../../../utils/values/values.dart';
import '../../../widgets/animated_line_through_text.dart';
import '../../utils/values/spaces.dart';
import '../../widgets/animations/animated_positioned_text.dart';
import '../../widgets/animations/animated_text_slide_box_transition.dart';
import '../../widgets/buttons/socials_icon_button.dart';
import '../../widgets/helper/content_builder.dart';
import '../../widgets/helper/custom_spacer.dart';
import '../../widgets/scaffolding/animated_footer.dart';
import '../../widgets/scaffolding/page_wrapper.dart';
import 'widgets/about_header.dart';
import 'widgets/technology_section.dart';

class AboutPage extends StatefulWidget {
  static const String aboutPageRoute = StringConst.ABOUT_PAGE;
  const AboutPage({
    Key? key,
  }) : super(key: key);

  @override
  AboutPageState createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _storyController;
  late AnimationController _technologyController;
  late AnimationController _technologyListController;
  late AnimationController _contactController;
  late AnimationController _quoteController;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _storyController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _technologyController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _technologyListController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _contactController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _quoteController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _storyController.dispose();
    _technologyController.dispose();
    _technologyListController.dispose();
    _contactController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double contentAreaWidth = responsiveSize(
      context,
      assignWidth(context, 0.8),
      assignWidth(context, 0.75),
      small: assignWidth(context, 0.8),
    );
    final EdgeInsetsGeometry padding = EdgeInsets.only(
      left: responsiveSize(
        context,
        assignWidth(context, 0.10),
        assignWidth(context, 0.15),
      ),
      right: responsiveSize(
        context,
        assignWidth(context, 0.10),
        assignWidth(context, 0.10),
        // sm: assignWidth(context, 0.10),
      ),
      top: responsiveSize(
        context,
        assignHeight(context, 0.15),
        assignHeight(context, 0.15),
        // sm: assignWidth(context, 0.10),
      ),
    );

    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? bodyText1Style = textTheme.bodyText1?.copyWith(
      fontSize: Sizes.TEXT_SIZE_18,
      color: AppColors.grey750,
      fontWeight: FontWeight.w400,
      height: 2.0,
      // letterSpacing: 2,
    );
    final TextStyle? bodyText2Style = textTheme.bodyText1?.copyWith(color: AppColors.grey750);
    final TextStyle? titleStyle = textTheme.subtitle1?.copyWith(
      color: AppColors.black,
      fontSize: responsiveSize(
        context,
        Sizes.TEXT_SIZE_16,
        Sizes.TEXT_SIZE_20,
      ),
    );
    final CurvedAnimation storySectionAnimation = CurvedAnimation(
      parent: _storyController,
      curve: const Interval(0.6, 1.0, curve: Curves.ease),
    );
    final CurvedAnimation technologySectionAnimation = CurvedAnimation(
      parent: _technologyController,
      curve: const Interval(0.6, 1.0, curve: Curves.fastOutSlowIn),
    );
    final double widthOfBody = responsiveSize(
      context,
      assignWidth(context, 0.75),
      assignWidth(context, 0.5),
    );
    return PageWrapper(
      selectedRoute: AboutPage.aboutPageRoute,
      selectedPageName: StringConst.ABOUT,
      navigationBarAnimationController: _controller,
      onLoadingAnimationDone: () {
        _controller.forward();
      },
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        children: <Widget>[
          Padding(
            padding: padding,
            child: Column(
              children: <Widget>[
                AboutHeader(
                  width: contentAreaWidth,
                  controller: _controller,
                ),
                const CustomSpacer(heightFactor: 0.1),
                VisibilityDetector(
                  key: const Key('story-section'),
                  onVisibilityChanged: (visibilityInfo) {
                    if (visibilityInfo.visibleFraction * 100 >
                        responsiveSize(context, 40, 70, medium: 50)) {
                      _storyController.forward();
                    }
                  },
                  child: ContentBuilder(
                    controller: _storyController,
                    number: "/01 ",
                    width: contentAreaWidth,
                    section: StringConst.ABOUT_DEV_STORY.toUpperCase(),
                    title: StringConst.ABOUT_DEV_STORY_TITLE,
                    body: Column(
                      children: <Widget>[
                        AnimatedPositionedText(
                          controller: storySectionAnimation,
                          width: widthOfBody,
                          maxLines: 30,
                          // factor: 1.25,
                          text: StringConst.ABOUT_DEV_STORY_CONTENT_1,
                          textStyle: bodyText1Style,
                        ),
                        AnimatedPositionedText(
                          controller: storySectionAnimation,
                          width: widthOfBody,
                          maxLines: 30,
                          factor: 1.25,
                          text: StringConst.ABOUT_DEV_STORY_CONTENT_2,
                          textStyle: bodyText1Style,
                        ),
                        AnimatedPositionedText(
                          controller: storySectionAnimation,
                          width: widthOfBody,
                          maxLines: 30,
                          factor: 1.25,
                          text: StringConst.ABOUT_DEV_STORY_CONTENT_3,
                          textStyle: bodyText1Style,
                        ),
                      ],
                    ),
                  ),
                ),
                const CustomSpacer(heightFactor: 0.1),
                VisibilityDetector(
                  key: const Key('technology-section'),
                  onVisibilityChanged: (visibilityInfo) {
                    if (visibilityInfo.visibleFraction * 100 > 50) {
                      _technologyController.forward();
                    }
                  },
                  child: ContentBuilder(
                    controller: _technologyController,
                    number: "/02 ",
                    width: contentAreaWidth,
                    section: StringConst.ABOUT_DEV_TECHNOLOGY.toUpperCase(),
                    title: StringConst.ABOUT_DEV_TECHNOLOGY_TITLE,
                    body: Column(
                      children: <Widget>[
                        AnimatedPositionedText(
                          controller: technologySectionAnimation,
                          width: widthOfBody,
                          maxLines: 12,
                          text: StringConst.ABOUT_DEV_TECHNOLOGY_CONTENT,
                          textStyle: bodyText1Style,
                        ),
                      ],
                    ),
                    footer: VisibilityDetector(
                      key: const Key('technology-list'),
                      onVisibilityChanged: (visibilityInfo) {
                        if (visibilityInfo.visibleFraction * 100 > 60) {
                          _technologyListController.forward();
                        }
                      },
                      child: Column(
                        children: <Widget>[
                          const SpaceH40(),
                          TechnologySection(
                            width: contentAreaWidth,
                            controller: _technologyListController,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const CustomSpacer(heightFactor: 0.1),
                VisibilityDetector(
                  key: const Key('contact-section'),
                  onVisibilityChanged: (visibilityInfo) {
                    if (visibilityInfo.visibleFraction * 100 > 50) {
                      _contactController.forward();
                    }
                  },
                  child: ContentBuilder(
                    controller: _contactController,
                    number: "/03 ",
                    width: contentAreaWidth,
                    section: StringConst.ABOUT_DEV_CONTACT.toUpperCase(),
                    title: StringConst.ABOUT_DEV_CONTACT_SOCIAL,
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SpaceH20(),
                        Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: _buildSocials(Data.socialData),
                        ),
                      ],
                    ),
                    footer: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SpaceH40(),
                        AnimatedTextSlideBoxTransition(
                          controller: _contactController,
                          text: StringConst.ABOUT_DEV_CONTACT_EMAIL,
                          textStyle: titleStyle,
                        ),
                        const SpaceH40(),
                        AnimatedLineThroughText(
                          text: StringConst.DEV_EMAIL,
                          hasSlideBoxAnimation: true,
                          controller: _contactController,
                          onTap: () {
                            Functions.launchUrl(StringConst.EMAIL_URL);
                          },
                          textStyle: bodyText2Style,
                        ),
                      ],
                    ),
                  ),
                ),
                const CustomSpacer(heightFactor: 0.1),
                VisibilityDetector(
                  key: const Key('quote-section'),
                  onVisibilityChanged: (visibilityInfo) {
                    double visiblePercentage = visibilityInfo.visibleFraction * 100;
                    if (visiblePercentage > 50) {
                      _quoteController.forward();
                    }
                  },
                  child: Column(
                    children: <Widget>[
                      AnimatedTextSlideBoxTransition(
                        controller: _quoteController,
                        text: StringConst.FAMOUS_QUOTE,
                        maxLines: 5,
                        width: contentAreaWidth,
                        textAlign: TextAlign.center,
                        textStyle: titleStyle?.copyWith(
                          fontSize: responsiveSize(
                            context,
                            Sizes.TEXT_SIZE_24,
                            Sizes.TEXT_SIZE_36,
                            medium: Sizes.TEXT_SIZE_28,
                          ),
                          height: 2.0,
                        ),
                      ),
                      const SpaceH20(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: AnimatedTextSlideBoxTransition(
                          controller: _quoteController,
                          text: "— ${StringConst.FAMOUS_QUOTE_AUTHOR}",
                          textStyle: textTheme.bodyText1?.copyWith(
                            fontSize: responsiveSize(
                              context,
                              Sizes.TEXT_SIZE_16,
                              Sizes.TEXT_SIZE_18,
                              medium: Sizes.TEXT_SIZE_16,
                            ),
                            fontWeight: FontWeight.w400,
                            color: AppColors.grey600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const CustomSpacer(heightFactor: 0.2),
              ],
            ),
          ),

          // SlidingBanner(),
          const AnimatedFooter()
        ],
      ),
    );
  }

  List<Widget> _buildSocials(List<SocialData> data) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? style = textTheme.bodyText1?.copyWith(color: AppColors.grey750);
    final TextStyle? slashStyle = textTheme.bodyText1?.copyWith(
      color: AppColors.grey750,
      fontWeight: FontWeight.w400,
      fontSize: 18,
    );
    final List<Widget> items = <Widget>[];

    for (int index = 0; index < data.length; index++) {
      items.add(
        AnimatedLineThroughText(
          text: data[index].name,
          isUnderlinedByDefault: true,
          controller: _contactController,
          hasSlideBoxAnimation: true,
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
