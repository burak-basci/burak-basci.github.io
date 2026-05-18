import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../utils/adaptive_layout.dart';
import '../../../utils/functions.dart';
import '../../../utils/i18n_strings.dart';
import '../../../utils/values/values.dart';
import '../../utils/values/spaces.dart';
import '../../widgets/buttons/animated_underline_text_button.dart';
import '../../widgets/buttons/socials_icon_button.dart';
import '../../widgets/helper/content_builder.dart';
import '../../widgets/helper/custom_spacer.dart';
import '../../widgets/scaffolding/footer/full_footer.dart';
import '../../widgets/scaffolding/page_wrapper.dart';
import '../../widgets/text/self_positioning_text.dart';
import '../../widgets/text/slide_box_transitioning_text.dart';
import 'widgets/about_header.dart';
import 'widgets/technology_section.dart';

class AboutPage extends StatefulWidget {
  static const String aboutPageRoute = StringConst.ABOUT_PAGE;
  const AboutPage({
    super.key,
  });

  @override
  AboutPageState createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  late AnimationController _headerController;
  // Continuous Ken-Burns breathing on the hero photo — slow zoom 1.00 ->
  // 1.04 that reverses on completion so the image drifts gently behind
  // the catch lines, matching the cinematic feel of the project hero
  // covers (see _heroBreathController in project_detail_page.dart).
  late AnimationController _heroBreathController;
  late AnimationController _storyController;
  late AnimationController _storySelfPositioningController;
  late AnimationController _technologyController;
  late AnimationController _technologySelfPositioningController;
  late AnimationController _technologyListController;
  late AnimationController _technologyListSelfPositioningController;
  late AnimationController _contactController;
  late AnimationController _quoteController;
  late AnimationController _footerController;

  @override
  void initState() {
    // Header controller drives the AboutHeader animations (catch_line_1
    // and catch_line_2 slide-box reveal). It needs a duration so
    // [_headerController.forward] below can tick. flutter_animate's
    // effect durations are 800 ms slide-in + 800 ms delay = 1600 ms
    // total per line, so 1500 ms here lets both lines play through.
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _heroBreathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat(reverse: true);
    _storyController = AnimationController(vsync: this);
    _storySelfPositioningController = AnimationController(vsync: this);
    _technologyController = AnimationController(vsync: this);
    _technologySelfPositioningController = AnimationController(vsync: this);
    _technologyListController = AnimationController(vsync: this);
    _technologyListSelfPositioningController = AnimationController(vsync: this);
    _contactController = AnimationController(vsync: this);
    _quoteController = AnimationController(vsync: this);
    _footerController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _heroBreathController.dispose();
    _storyController.dispose();
    _storySelfPositioningController.dispose();
    _technologyController.dispose();
    _technologySelfPositioningController.dispose();
    _technologyListController.dispose();
    _technologyListSelfPositioningController.dispose();
    _contactController.dispose();
    _quoteController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      navigationBarAnimationController: _headerController,
      selectedRoute: AboutPage.aboutPageRoute,
      selectedPageName: StringConst.ABOUT,
      onLoadingAnimationDone: () {
        // Once the page uncover transition starts, play the header
        // catch-line animations. Using forward() (not value = 1) so the
        // slide-box reveal on `about.catch_line_1` and `about.catch_line_2`
        // actually animates in — setting value = 1 snapped the controller
        // straight to the final state and the slide-box wipe never played.
        _headerController.forward();
      },
      child: ListView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        children: <Widget>[
          AboutHeader(
            scrollController: _scrollController,
            controller: _headerController,
            heroBreathController: _heroBreathController,
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final double contentAreaWidth = responsiveSize(
                desktop: Get.width * 0.75,
                tabletSmall: Get.width * 0.8,
                mobile: Get.width * 0.8,
              );
              final EdgeInsetsGeometry padding = EdgeInsets.only(
                left: responsiveSize(
                  mobile: Get.width * 0.10,
                  desktop: Get.width * 0.15,
                ),
                right: Get.width * 0.10,
                top: Get.height * 0.15,
              );

              final TextStyle? bodyText1Style = Get.textTheme.bodyLarge?.copyWith(
                fontFamily: StringConst.INTER,
                fontSize: Sizes.TEXT_SIZE_18,
                color: CustomColors.grey750,
                fontWeight: FontWeight.w300,
                height: 2.0,
              );
              final TextStyle? titleStyle = Get.textTheme.titleMedium?.copyWith(
                color: CustomColors.black,
                fontSize: responsiveSize(
                  mobile: Sizes.TEXT_SIZE_20,
                  desktop: Sizes.TEXT_SIZE_24,
                ),
              );
              final double widthOfBody = responsiveSize(
                mobile: Get.width * 0.8,
                desktop: Get.width * 0.70,
              );

              return Padding(
                padding: padding,
                child: Column(
                  children: <Widget>[
                    VisibilityDetector(
                      key: const Key('story-section'),
                      onVisibilityChanged: (visibilityInfo) {
                        if (visibilityInfo.visibleFraction > 0.25) {
                          _storyController.forward();
                          _storySelfPositioningController.forward();
                        }
                      },
                      child: ContentBuilder(
                        controller: _storyController,
                        sectionNumber: "/01 ",
                        sectionLabel: Tr.of('about.story.label').toUpperCase(),
                        sectionHeading: Tr.of('about.story.title'),
                        sectionBody: SelfPositioningText(
                          controller: _storySelfPositioningController,
                          width: widthOfBody,
                          text: Tr.of('about.story.content'),
                          textStyle: bodyText1Style,
                        ),
                      ),
                    ),
                    const CustomSpacer(heightFactor: 0.1),
                    VisibilityDetector(
                      key: const Key('technology-section'),
                      onVisibilityChanged: (visibilityInfo) {
                        if (visibilityInfo.visibleFraction > 0.25) {
                          _technologyController.forward();
                          _technologySelfPositioningController.forward();
                        }
                      },
                      child: ContentBuilder(
                        controller: _technologyController,
                        sectionNumber: "/02 ",
                        sectionLabel: Tr.of('about.technology.label').toUpperCase(),
                        sectionHeading: Tr.of('about.technology.title'),
                        sectionBody: SelfPositioningText(
                          controller: _technologySelfPositioningController,
                          width: widthOfBody,
                          text: Tr.of('about.technology.content'),
                          textStyle: bodyText1Style,
                        ),
                        footerWidget: VisibilityDetector(
                          key: const Key('technology-list'),
                          onVisibilityChanged: (visibilityInfo) {
                            if (visibilityInfo.visibleFraction > 0.25) {
                              _technologyListController.forward();
                              _technologyListSelfPositioningController.forward();
                            }
                          },
                          child: Column(
                            children: <Widget>[
                              const SpaceH24(),
                              TechnologySection(
                                width: contentAreaWidth,
                                controller: _technologyListController,
                                selfPositioningController: _technologyListSelfPositioningController,
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
                        if (visibilityInfo.visibleFraction > 0.25) {
                          _contactController.forward();
                        }
                      },
                      child: ContentBuilder(
                        controller: _contactController,
                        sectionNumber: "/03 ",
                        sectionLabel: Tr.of('about.contact.label').toUpperCase(),
                        sectionHeading: Tr.of('about.contact.social'),
                        sectionBody: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Wrap(
                              spacing: 16,
                              children: _buildSocials(Data.socialData),
                            ),
                          ],
                        ),
                        footerWidget: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const CustomSpacer(heightFactor: 0.1),
                            AnimatedSlideBoxTransitionText(
                              controller: _contactController,
                              text: Tr.of('about.contact.email'),
                              width: contentAreaWidth,
                              textStyle: titleStyle,
                            ),
                            const SpaceH24(),
                            AnimatedUnderlineTextButton(
                              slideBoxController: _contactController,
                              text: StringConst.DEV_EMAIL,
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
                                Functions.launchUrl(StringConst.EMAIL_URL);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const CustomSpacer(heightFactor: 0.1),
                    VisibilityDetector(
                      key: const Key('quote-section'),
                      onVisibilityChanged: (visibilityInfo) {
                        if (visibilityInfo.visibleFraction > 0.25) {
                          _quoteController.forward();
                        }
                      },
                      child: Column(
                        children: <Widget>[
                          AnimatedSlideBoxTransitionText(
                            controller: _quoteController,
                            text: Tr.of('about.quote.text'),
                            width: contentAreaWidth,
                            textAlign: TextAlign.center,
                            textStyle: titleStyle?.copyWith(
                              fontSize: responsiveSize(
                                mobile: Sizes.TEXT_SIZE_24,
                                tabletNormal: Sizes.TEXT_SIZE_28,
                                desktop: Sizes.TEXT_SIZE_36,
                              ),
                              height: 2.0,
                            ),
                          ),
                          const SpaceH16(),
                          Align(
                            alignment: Alignment.centerRight,
                            child: AnimatedSlideBoxTransitionText(
                              controller: _quoteController,
                              text: "— ${Tr.of('about.quote.author')}",
                              width: contentAreaWidth,
                              textStyle: Get.textTheme.bodyLarge?.copyWith(
                                fontSize: responsiveSize(
                                  mobile: Sizes.TEXT_SIZE_16,
                                  desktop: Sizes.TEXT_SIZE_18,
                                ),
                                fontWeight: FontWeight.w400,
                                color: CustomColors.grey600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const CustomSpacer(heightFactor: 0.2),
                  ],
                ),
              );
            },
          ),
          VisibilityDetector(
            key: const Key('animated-footer'),
            onVisibilityChanged: (visibilityInfo) {
              if (visibilityInfo.visibleFraction > 0.25) {
                _footerController.forward();
              }
            },
            child: FullFooter(
              controller: _footerController,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSocials(List<SocialData> data) {
    final List<Widget> items = <Widget>[];

    for (int index = 0; index < data.length; index++) {
      items.add(
        AnimatedUnderlineTextButton(
          slideBoxController: _contactController,
          text: data[index].name,
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
          Text('/',
              style: Get.textTheme.bodyLarge?.copyWith(
                color: CustomColors.grey750,
                fontWeight: FontWeight.w400,
                fontSize: 18,
              ))
              .animate(
                controller: _contactController,
                autoPlay: false,
              )
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
