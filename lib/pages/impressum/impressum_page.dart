import 'package:burak_basci_website/widgets/text/self_positioning_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../utils/adaptive_layout.dart';
import '../../utils/i18n_strings.dart';
import '../../../utils/values/values.dart';
import '../../utils/values/spaces.dart';
import '../../widgets/helper/custom_spacer.dart';
import '../../widgets/scaffolding/footer/full_footer.dart';
import '../../widgets/scaffolding/header/default_page_header.dart';
import '../../widgets/scaffolding/page_wrapper.dart';
import '../../widgets/text/slide_box_transitioning_text.dart';

class ImpressumPage extends StatefulWidget {
  static const String impressumPageRoute = StringConst.IMPRESSUM_PAGE;
  const ImpressumPage({
    super.key,
  });

  @override
  ImpressumPageState createState() => ImpressumPageState();
}

class ImpressumPageState extends State<ImpressumPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  late AnimationController _controller;
  late List<AnimationController> _sectionControllers;
  late AnimationController _footerController;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);

    _sectionControllers = List.generate(Data.impressumData.length, (index) {
      return AnimationController(vsync: this);
    });

    _footerController = AnimationController(vsync: this);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    for (AnimationController controller in _sectionControllers) {
      controller.dispose();
    }
    _footerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      selectedRoute: ImpressumPage.impressumPageRoute,
      selectedPageName: StringConst.IMPRESSUM,
      navigationBarAnimationController: _controller,
      onLoadingAnimationDone: () {
        _controller.forward();
      },
      // SingleChildScrollView keeps maxScrollExtent stable across the
      // legal text — same reason as the other content pages.
      child: SingleChildScrollView(
        controller: _scrollController,
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
            headingText: Tr.of('footer.imprint'),
            headingTextController: _controller,
          ),
          LayoutBuilder(builder: (context, constraints) {
            final double contentAreaWidth = responsiveSize(
              mobile: Get.width * 0.8,
              desktop: Get.width * 0.75,
              tabletSmall: Get.width * 0.8,
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
                  ...buildImpressumSection(
                    data: Data.impressumData,
                    width: contentAreaWidth,
                  ),
                  const CustomSpacer(heightFactor: 0.1),
                ],
              ),
            );
          }),
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

  List<Widget> buildImpressumSection({
    required List<PrivacyPolicyData> data,
    required double width,
  }) {
    TextStyle? defaultTitleStyle = Get.textTheme.titleMedium?.copyWith(
      color: CustomColors.black,
      fontSize: responsiveSize(
        mobile: Sizes.TEXT_SIZE_18,
        desktop: Sizes.TEXT_SIZE_20,
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
          key: Key('impressum-section-$index'),
          onVisibilityChanged: (visibilityInfo) {
            if (visibilityInfo.visibleFraction > 0.25) {
              _sectionControllers[index].forward();
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              data[index].title != null
                  ? AnimatedSlideBoxTransitionText(
                      controller: _sectionControllers[index],
                      text: data[index].title!,
                      width: width,
                      textStyle: defaultTitleStyle,
                    )
                  : const SizedBox(),
              data[index].title != null ? const SpaceH12() : const SizedBox(),
              SelfPositioningText(
                controller: _sectionControllers[index],
                text: data[index].content,
                width: width,
                delay: const Duration(milliseconds: 800),
                textStyle: defaultTitleStyle?.copyWith(
                  fontSize: responsiveSize(
                    mobile: Sizes.TEXT_SIZE_16,
                    desktop: Sizes.TEXT_SIZE_18,
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
