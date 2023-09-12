import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../utils/adaptive_layout.dart';
import '../../../utils/values/values.dart';
import '../../utils/values/spaces.dart';
import '../../widgets/animations/animated_text_slide_box_transition.dart';
import '../../widgets/helper/custom_spacer.dart';
import '../../widgets/scaffolding/animated_footer.dart';
import '../../widgets/scaffolding/default_page_header.dart';
import '../../widgets/scaffolding/page_wrapper.dart';

class PrivacyPolicyPage extends StatefulWidget {
  static const String privacyPolicyPageRoute = StringConst.PRIVACY_POLICY_PAGE;
  const PrivacyPolicyPage({
    Key? key,
  }) : super(key: key);

  @override
  PrivacyPolicyPageState createState() => PrivacyPolicyPageState();
}

class PrivacyPolicyPageState extends State<PrivacyPolicyPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  late AnimationController _controller;
  late List<AnimationController> _privacyPolicyControllers;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _privacyPolicyControllers = List.generate(Data.privacyPolicyData.length, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      );
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var controller in _privacyPolicyControllers) {
      controller.dispose();
    }
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

    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? defaultNumberStyle = textTheme.bodyText1?.copyWith(
      fontSize: Sizes.TEXT_SIZE_10,
      color: AppColors.black,
      fontWeight: FontWeight.w400,
      height: 2.0,
      letterSpacing: 2,
    );
    final TextStyle? defaultSectionStyle = defaultNumberStyle?.copyWith(
      color: AppColors.grey600,
    );
    final TextStyle? defaultTitleStyle = textTheme.subtitle1?.copyWith(
      color: AppColors.black,
      fontSize: responsiveSize(
        context,
        Sizes.TEXT_SIZE_16,
        Sizes.TEXT_SIZE_20,
      ),
    );

    return PageWrapper(
      selectedRoute: PrivacyPolicyPage.privacyPolicyPageRoute,
      selectedPageName: StringConst.PRIVACY_POLICY,
      navigationBarAnimationController: _controller,
      onLoadingAnimationDone: () {
        _controller.forward();
      },
      child: ListView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        children: <Widget>[
          DefaultPageHeader(
            scrollController: _scrollController,
            headingText: StringConst.PRIVACY_POLICY,
            headingTextController: _controller,
          ),
          Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ..._buildPrivacyPolicySection(
                  data: Data.privacyPolicyData,
                  width: contentAreaWidth,
                ),
                const CustomSpacer(heightFactor: 0.1),
              ],
            ),
          ),
          const AnimatedFooter(),
        ],
      ),
    );
  }

  List<Widget> _buildPrivacyPolicySection({
    required List<PrivacyPolicyData> data,
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
      data[index].title != null
          ? items.add(
              const SpaceH32(),
            )
          : const SizedBox();
      items.add(
        VisibilityDetector(
          key: Key('privacy-policy-section-$index'),
          onVisibilityChanged: (visibilityInfo) {
            double visiblePercentage = visibilityInfo.visibleFraction * 100;
            if (visiblePercentage > 40) {
              _privacyPolicyControllers[index].forward();
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              data[index].title != null
                  ? AnimatedTextSlideBoxTransition(
                      controller: _privacyPolicyControllers[index],
                      text: data[index].title!,
                      maxLines: 100,
                      width: width,
                      textStyle: defaultTitleStyle,
                    )
                  : const SizedBox(),
              data[index].title != null ? const SpaceH12() : const SizedBox(),
              AnimatedTextSlideBoxTransition(
                controller: _privacyPolicyControllers[index],
                text: data[index].content,
                maxLines: 100,
                width: width,
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
        ),
      );
    }

    return items;
  }
}
