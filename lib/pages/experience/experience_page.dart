import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../utils/adaptive_layout.dart';
import '../../../utils/values/values.dart';
import '../../utils/values/spaces.dart';
import '../../widgets/animations/animated_positioned_text.dart';
import '../../widgets/animations/animated_text_slide_box_transition.dart';
import '../../widgets/helper/content_builder.dart';
import '../../widgets/helper/custom_spacer.dart';
import '../../widgets/scaffolding/animated_footer.dart';
import '../../widgets/scaffolding/default_page_header.dart';
import '../../widgets/scaffolding/page_wrapper.dart';

class ExperiencePage extends StatefulWidget {
  static const String experiencePageRoute = StringConst.EXPERIENCE_PAGE;
  const ExperiencePage({
    Key? key,
  }) : super(key: key);

  @override
  ExperiencePageState createState() => ExperiencePageState();
}

class ExperiencePageState extends State<ExperiencePage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  late AnimationController _controller;
  late AnimationController _experience1Controller;
  late AnimationController _experience2Controller;
  late AnimationController _experience3Controller;
  late AnimationController _experience4Controller;
  late List<AnimationController> _experienceControllers;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _experience1Controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _experience2Controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _experience3Controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _experience4Controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _experienceControllers = <AnimationController>[
      _experience1Controller,
      _experience2Controller,
      _experience3Controller,
      _experience4Controller,
    ];
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _experience1Controller.dispose();
    _experience2Controller.dispose();
    _experience3Controller.dispose();
    _experience4Controller.dispose();
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
      ),
      top: responsiveSize(
        context,
        assignHeight(context, 0.15),
        assignHeight(context, 0.15),
      ),
    );

    return PageWrapper(
      selectedRoute: ExperiencePage.experiencePageRoute,
      selectedPageName: StringConst.EXPERIENCE,
      navigationBarAnimationController: _controller,
      onLoadingAnimationDone: () {
        _controller.forward();
      },
      child: ListView(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        children: <Widget>[
          DefaultPageHeader(
            scrollController: _scrollController,
            headingText: StringConst.EXPERIENCE,
            headingTextController: _controller,
          ),
          Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildExperienceSection(
                data: Data.experienceData,
                width: contentAreaWidth,
              ),
            ),
          ),
          const AnimatedFooter(),
        ],
      ),
    );
  }

  List<Widget> _buildExperienceSection({
    required List<ExperienceData> data,
    required double width,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    TextStyle? defaultTitleStyle = textTheme.subtitle1?.copyWith(
      color: AppColors.black,
      fontSize: responsiveSize(
        context,
        Sizes.TEXT_SIZE_18,
        Sizes.TEXT_SIZE_20,
      ),
    );

    List<Widget> items = <Widget>[];

    for (int index = 0; index < data.length; index++) {
      items.add(
        VisibilityDetector(
          key: Key('experience-section-$index'),
          onVisibilityChanged: (visibilityInfo) {
            double visiblePercentage = visibilityInfo.visibleFraction * 100;
            if (visiblePercentage > 40) {
              _experienceControllers[index].forward();
            }
          },
          child: ContentBuilder(
            controller: _experienceControllers[index],
            number: "/0${index + 1}",
            width: width,
            section: data[index].duration.toUpperCase(),
            heading: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AnimatedTextSlideBoxTransition(
                  controller: _experienceControllers[index],
                  text: data[index].company,
                  textStyle: defaultTitleStyle,
                ),
                const SpaceH16(),
                AnimatedTextSlideBoxTransition(
                  controller: _experienceControllers[index],
                  text: data[index].position,
                  textStyle: defaultTitleStyle?.copyWith(
                    fontSize: responsiveSize(
                      context,
                      Sizes.TEXT_SIZE_16,
                      Sizes.TEXT_SIZE_18,
                    ),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildRoles(
                roles: data[index].roles,
                controller: _experienceControllers[index],
                width: width * 0.75,
              ),
            ),
          ),
        ),
      );
      items.add(
        const CustomSpacer(heightFactor: 0.1),
      );
    }

    return items;
  }

  List<Widget> _buildRoles({
    required List<String> roles,
    required AnimationController controller,
    required double width,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? bodyText1Style = textTheme.bodyText1?.copyWith(
      fontSize: responsiveSize(
        context,
        Sizes.TEXT_SIZE_16,
        17,
      ),
      color: AppColors.grey750,
      fontWeight: FontWeight.w300,
      height: 1.5,
      // letterSpacing: 2,
    );

    List<Widget> items = <Widget>[];
    for (int index = 0; index < roles.length; index++) {
      items.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.play_arrow_outlined,
              color: AppColors.black,
              size: 12,
            ),
            const SpaceW8(),
            Flexible(
              child: AnimatedPositionedText(
                text: roles[index],
                textStyle: bodyText1Style,
                maxLines: 7,
                width: width,
                controller: CurvedAnimation(
                  parent: controller,
                  curve: const Interval(0.6, 1.0, curve: Curves.fastOutSlowIn),
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
