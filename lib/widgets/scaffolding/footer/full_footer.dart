import 'package:burak_basci_website/widgets/scaffolding/footer/bottom_part_footer.dart';
import "package:flutter/material.dart";
import 'package:get/get.dart';

import '../../../../utils/adaptive_layout.dart';
import '../../../../utils/i18n_strings.dart';
import '../../../../utils/page_transition.dart';
import '../../../../utils/values/values.dart';
import '../../../pages/contact/contact_page.dart';
import '../../buttons/animated_bubble_button.dart';
import '../../text/self_positioning_text.dart';
import '../../text/self_positioning_widget.dart';

class FullFooter extends StatelessWidget {
  const FullFooter({
    required this.controller,
    this.height,
    this.bottomPartHeight,
    super.key,
  });

  final AnimationController controller;

  /// Caller-supplied fixed footer height. Home page computes this once from
  /// the initial viewport and passes it through so the footer never re-reads
  /// `Get.height` mid-scroll. Falls back to the legacy
  /// `max(450, Get.height * 0.54)` for any other call site.
  final double? height;

  /// Caller-supplied fixed height for the nested [BottomPartFooter] dark
  /// band. Threaded through from the home page's cached viewport so the
  /// bottom band stops jittering by 1 px at the cascade→footer transition.
  /// Falls back to the legacy `max(175, Get.height * 0.2)` when null.
  final double? bottomPartHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double circleImageSize = responsiveSize(mobile: 160, desktop: 200);
        final double resolvedHeight = height ??
            ((Get.height * 0.54) <= 450 ? 450 : (Get.height * 0.54));

        return Container(
          width: Get.width,
          height: resolvedHeight,
          color: CustomColors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Spacer(),
              SizedBox(
                height: circleImageSize,
                child: Stack(
                  children: <Widget>[
                    /// Circle Image
                    Positioned(
                      right: Get.width * 0.2,
                      child: SelfPositioningWidget(
                        controller: controller,
                        width: circleImageSize,
                        height: circleImageSize,
                        child: Image.asset(
                          ImagePath.DEFAULT_PAGE_FOOTER,
                          color: CustomColors.white,
                        ),
                      ),
                    ),

                    /// Let's Work Together Text
                    Center(
                      child: SelfPositioningText(
                        controller: controller,
                        text: Tr.of('footer.lets_work'),
                        textAlign: TextAlign.center,
                        width: Get.width,
                        textStyle: Get.textTheme.headlineMedium?.copyWith(
                          fontFamily: StringConst.VISUELT_PRO,
                          color: CustomColors.accentColor,
                          fontSize: responsiveSize(
                            mobile: Sizes.TEXT_SIZE_30,
                            tabletNormal: Sizes.TEXT_SIZE_50,
                            desktop: Sizes.TEXT_SIZE_64,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// Available for Freelance Text
              SelfPositioningText(
                text: Tr.of('footer.available'),
                textAlign: TextAlign.center,
                width: Get.width,
                textStyle: Get.textTheme.bodyLarge?.copyWith(
                  color: CustomColors.grey550,
                  fontSize: Sizes.TEXT_SIZE_18,
                  fontWeight: FontWeight.w400,
                ),
                controller: controller,
              ),
              const Spacer(),

              /// Say Hello Button
              AnimatedBubbleButton(
                title: Tr.of('btn.say_hello').toUpperCase(),
                onTap: () {
                  PageTransition.goTo(context, ContactPage.contactPageRoute);
                },
              ),
              const Spacer(flex: 2),

              BottomPartFooter(height: bottomPartHeight),

              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}
