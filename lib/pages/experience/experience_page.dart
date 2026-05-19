import 'package:burak_basci_website/widgets/text/self_positioning_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../utils/adaptive_layout.dart';
import '../../../utils/i18n_strings.dart';
import '../../../utils/values/values.dart';
import '../../utils/values/spaces.dart';
import '../../widgets/helper/content_builder.dart';
import '../../widgets/helper/custom_spacer.dart';
import '../../widgets/scaffolding/footer/full_footer.dart';
import '../../widgets/scaffolding/header/default_page_header.dart';
import '../../widgets/scaffolding/page_wrapper.dart';
import '../../widgets/text/slide_box_transitioning_text.dart';

class ExperiencePage extends StatefulWidget {
  const ExperiencePage({
    super.key,
  });
  static const String experiencePageRoute = StringConst.EXPERIENCE_PAGE;

  @override
  ExperiencePageState createState() => ExperiencePageState();
}

class ExperiencePageState extends State<ExperiencePage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  late AnimationController _headerController;
  late AnimationController _footerController;

  late AnimationController _workTitleController;
  late AnimationController _educationTitleController;

  late List<AnimationController> _workControllers;
  late List<AnimationController> _selfPositioningWorkControllers;
  late List<AnimationController> _educationControllers;
  late List<AnimationController> _selfPositioningEducationControllers;

  @override
  void initState() {
    _headerController = AnimationController(vsync: this);
    _footerController = AnimationController(vsync: this);

    _workTitleController = AnimationController(vsync: this);
    _educationTitleController = AnimationController(vsync: this);

    _workControllers = List.generate(
      Data.workData.length,
      (index) {
        return AnimationController(vsync: this);
      },
    );
    _selfPositioningWorkControllers = List.generate(
      Data.workData.length,
      (index) {
        return AnimationController(vsync: this);
      },
    );
    _educationControllers = List.generate(
      Data.academicData.length,
      (index) {
        return AnimationController(vsync: this);
      },
    );
    _selfPositioningEducationControllers = List.generate(
      Data.academicData.length,
      (index) {
        return AnimationController(vsync: this);
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _footerController.dispose();
    for (AnimationController controller in _workControllers) {
      controller.dispose();
    }
    for (AnimationController controller in _selfPositioningWorkControllers) {
      controller.dispose();
    }
    for (AnimationController controller in _educationControllers) {
      controller.dispose();
    }
    for (AnimationController controller in _selfPositioningEducationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      selectedRoute: ExperiencePage.experiencePageRoute,
      selectedPageName: StringConst.EXPERIENCE,
      navigationBarAnimationController: _headerController,
      onLoadingAnimationDone: () {
        // Cover/uncover transition is the entry animation; snap content
        // controllers straight to their final state.
        _headerController.value = 1;
      },
      // SingleChildScrollView + Column lays the whole page out in one
      // pass on first build, so position.maxScrollExtent stays constant
      // and the Scrollbar thumb doesn't resize/pop as more sections
      // scroll into view. ListView lazily lays out children based on
      // cacheExtent and reports a moving maxScrollExtent — same bug
      // home_page.dart had before its switch.
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        // Full-bleed content. The scrollbar's right-edge dead zone is
        // handled per-tile (see project_item.dart).
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
          DefaultPageHeader(
            scrollController: _scrollController,
            headingText: Tr.of('experience.heading'),
            headingTextController: _headerController,
          ),

          /// Professional Career
          LayoutBuilder(
            builder: (context, constraints) {
              final double contentAreaWidth = responsiveSize(
                mobile: Get.width * 0.8,
                desktop: Get.width * 0.70,
              );
              final EdgeInsetsGeometry padding = EdgeInsets.only(
                left: responsiveSize(
                  mobile: Get.width * 0.10,
                  desktop: Get.width * 0.15,
                ),
                right: Get.width * 0.10,
                top: Get.height * 0.15,
              );

              return Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    VisibilityDetector(
                      key: const Key('animated-work-title'),
                      onVisibilityChanged: (visibilityInfo) {
                        if (visibilityInfo.visibleFraction > 0.25) {
                          _workTitleController.forward();
                        }
                      },
                      child: AnimatedSlideBoxTransitionText(
                        controller: _workTitleController,
                        text: Tr.of('experience.professional'),
                        textStyle: Get.textTheme.headlineMedium?.copyWith(
                          color: CustomColors.black,
                          fontSize: responsiveSize(
                            mobile: Sizes.TEXT_SIZE_24,
                            desktop: Sizes.TEXT_SIZE_28,
                          ),
                        ),
                        width: contentAreaWidth,
                      ),
                    ),
                    const CustomSpacer(heightFactor: 0.06),
                    ..._buildCareerSection(
                      controllers: _workControllers,
                      selfPositioningTextControllers: _selfPositioningWorkControllers,
                      data: Data.workData,
                      keyPrefixes: const <String>[
                        'experience.5',
                        'experience.4',
                        'experience.3',
                        'experience.2',
                        'experience.game',
                        'experience.1',
                      ],
                      visibilityKey: 'professional-career-section',
                      width: contentAreaWidth,
                    ),
                    // const CustomSpacer(heightFactor: 0.1),
                  ],
                ),
              );
            },
          ),

          /// Academic Career
          LayoutBuilder(
            builder: (context, constraints) {
              final double contentAreaWidth = responsiveSize(
                mobile: Get.width * 0.8,
                desktop: Get.width * 0.70,
              );
              final EdgeInsetsGeometry padding = EdgeInsets.only(
                left: responsiveSize(
                  mobile: Get.width * 0.10,
                  desktop: Get.width * 0.15,
                ),
                right: Get.width * 0.10,
                top: Get.height * 0.15,
              );

              return Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    VisibilityDetector(
                      key: const Key('animated-academic-title'),
                      onVisibilityChanged: (visibilityInfo) {
                        if (visibilityInfo.visibleFraction > 0.25) {
                          _educationTitleController.forward();
                        }
                      },
                      child: AnimatedSlideBoxTransitionText(
                        controller: _educationTitleController,
                        text: Tr.of('experience.academic'),
                        textStyle: Get.textTheme.headlineMedium?.copyWith(
                          color: CustomColors.black,
                          fontSize: responsiveSize(
                            mobile: Sizes.TEXT_SIZE_24,
                            desktop: Sizes.TEXT_SIZE_28,
                          ),
                        ),
                        width: contentAreaWidth,
                      ),
                    ),
                    const CustomSpacer(heightFactor: 0.06),
                    ..._buildCareerSection(
                      controllers: _educationControllers,
                      selfPositioningTextControllers: _selfPositioningEducationControllers,
                      data: Data.academicData,
                      keyPrefixes: const <String>[
                        'academic.2',
                        'academic.1',
                      ],
                      visibilityKey: 'academic-career-section',
                      width: contentAreaWidth,
                    ),
                  ],
                ),
              );
            },
          ),

          /// Footer
          const CustomSpacer(heightFactor: 0.2),
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
      ),
    );
  }

  List<Widget> _buildCareerSection({
    required List<AnimationController> controllers,
    required List<AnimationController> selfPositioningTextControllers,
    required List<ExperienceData> data,
    required List<String> keyPrefixes,
    required String visibilityKey,
    required double width,
  }) {
    TextStyle? defaultTitleStyle = Get.textTheme.titleMedium?.copyWith(
      color: CustomColors.black,
      fontSize: responsiveSize(
        mobile: 19.0,
        desktop: 23.0,
      ),
    );

    List<Widget> items = <Widget>[];

    for (int index = 0; index < data.length; index++) {
      final String prefix = keyPrefixes[index];
      final int bulletCount = data[index].bulletPoint.length;
      final List<String> translatedBullets = <String>[
        for (int b = 1; b <= bulletCount; b++) Tr.of('$prefix.bullet_$b'),
      ];
      items.add(
        VisibilityDetector(
          key: Key('$visibilityKey-$index'),
          onVisibilityChanged: (visibilityInfo) {
            if (visibilityInfo.visibleFraction > 0.25) {
              controllers[index].forward();

              if (data[index].bulletPoint.isNotEmpty) {
                selfPositioningTextControllers[index].forward();
              }
            }
          },
          child: ContentBuilder(
            controller: controllers[index],
            sectionNumber: "/0${index + 1}",
            sectionLabel: Tr.of('$prefix.time').toUpperCase(),
            customHeadingWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AnimatedSlideBoxTransitionText(
                  controller: controllers[index],
                  text: Tr.of('$prefix.title'),
                  textStyle: defaultTitleStyle,
                  width: width,
                ),
                const SpaceH16(),
                AnimatedSlideBoxTransitionText(
                  controller: controllers[index],
                  text: Tr.of('$prefix.subtitle'),
                  width: width,
                  textStyle: defaultTitleStyle?.copyWith(
                    fontSize: responsiveSize(
                      mobile: 15.0,
                      desktop: 17.0,
                    ),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
            sectionBody: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildRoles(
                roles: translatedBullets,
                selfPositioningController: selfPositioningTextControllers[index],
                width: width * 0.75,
              ),
            ),
          ),
        ),
      );
      items.add(
        const SpaceH24(),
      );
    }

    return items;
  }

  List<Widget> _buildRoles({
    required List<String> roles,
    required AnimationController selfPositioningController,
    required double width,
  }) {
    List<Widget> items = <Widget>[];
    for (int index = 0; index < roles.length; index++) {
      items.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.play_arrow_outlined,
              color: CustomColors.black,
              size: 14,
            )
                .animate(
                  controller: selfPositioningController,
                  autoPlay: false,
                )
                .fadeIn(
                  duration: const Duration(milliseconds: 300),
                  delay: Duration(milliseconds: 600 + index * 100),
                  curve: Curves.easeOut,
                )
                .slideX(
                  begin: -0.5,
                  end: 0,
                  duration: const Duration(milliseconds: 400),
                  delay: Duration(milliseconds: 600 + index * 100),
                  curve: Curves.fastOutSlowIn,
                ),
            const SpaceW8(),
            Flexible(
              child: SelfPositioningText(
                controller: selfPositioningController,
                width: width,
                delay: Duration(milliseconds: 800 + index * 100),
                text: roles[index],
                textStyle: Get.textTheme.bodyLarge?.copyWith(
                  fontSize: 17.0,
                  color: CustomColors.grey750,
                  fontWeight: FontWeight.w300,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      );

      items.add(const SpaceH12());
    }

    return items;
  }
}
