import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../../utils/values/values.dart';
import '../../../utils/adaptive_layout.dart';
import 'home_about_dev.dart';
import 'home_scroll_down_button.dart';

class HomePageHeader extends StatelessWidget {
  const HomePageHeader({
    required this.scrollController,
    required this.textController,
    required this.circleController,
    this.height,
    super.key,
  });

  final ScrollController scrollController;
  final AnimationController textController;
  final AnimationController circleController;

  /// Caller-supplied fixed height. Home page computes this once from the
  /// initial viewport and threads it through so the section never re-reads
  /// `Get.height` mid-scroll (which would jitter the cascade's content
  /// height and make the scrollbar thumb jump). Falls back to the legacy
  /// `Get.height * 0.92` for any other call site.
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      height: height ?? Get.height * 0.92,
      child: ColoredBox(
        color: CustomColors.homePageBackground,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double fontSize;

            if (Get.width > Get.height) {
              fontSize = Get.height * 0.6;
            } else {
              fontSize = Get.width * 0.6;
            }

            final EdgeInsets padding = EdgeInsets.symmetric(
              horizontal: Get.width * 0.1,
              vertical: Get.height * 0.1,
            );

            return Stack(
              children: <Widget>[
                /// Grey Circle
                Center(
                  child: Container(
                    width: 479.0,
                    height: 479.0,
                    margin: const EdgeInsets.all(41),
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(
                        controller: circleController,
                        autoPlay: false,
                      )
                      .scale(
                        begin: const Offset(0.0, 0.0),
                        end: const Offset(1.0, 1.0),
                        curve: Curves.fastOutSlowIn,
                        duration: const Duration(milliseconds: 1000),
                      )
                      .blur(
                        begin: const Offset(2.0, 2.0),
                        end: const Offset(0.0, 0.0),
                      ),
                ),

                /// White Circle
                Center(
                  child: Container(
                    width: 480.0,
                    height: 480.0,
                    margin: const EdgeInsets.all(40),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(
                        controller: circleController,
                        autoPlay: false,
                      )
                      .scale(
                        begin: const Offset(0.0, 0.0),
                        end: const Offset(1.0, 1.0),
                        curve: Curves.fastOutSlowIn,
                        duration: const Duration(milliseconds: 1000),
                        delay: const Duration(milliseconds: 300),
                      )
                      .blur(
                        begin: const Offset(2.0, 2.0),
                        end: const Offset(0.0, 0.0),
                      ),
                ),

                /// X
                (constraints.maxWidth < refinedBreakpoints.mobile)
                    ? const SizedBox()
                    : Positioned(
                        right: 0,
                        bottom: -26,
                        child: Padding(
                          padding: padding.copyWith(bottom: 0.0),
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.diagonal3Values(1, 0.8, 1),
                            child: Text(
                              'X',
                              style: TextStyle(
                                fontFamily: StringConst.ROBOTO,
                                fontSize: fontSize,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),

                /// Caesar Image
                (constraints.maxWidth < refinedBreakpoints.mobile)
                    ? const SizedBox()
                    : Positioned(
                        right: Get.width * 0.08 - 20,
                        bottom: 20 + Get.width * 0.03,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final double size;

                            if (Get.width > Get.height) {
                              size = Get.height * 0.44;
                            } else {
                              size = Get.width * 0.44;
                            }
                            return Image.asset(
                              ImagePath.HOME_DUDE,
                              fit: BoxFit.cover,
                              width: size,
                              // Explicit height locks the rendered box
                              // even while the asset is still decoding.
                              // Without it, the intrinsic height kicks in
                              // post-decode and nudges layout — a stray
                              // contributor to the scrollbar-thumb-jump
                              // the user reported.
                              height: size,
                            )
                                .animate(
                                  onPlay: (controller) => controller.repeat(reverse: true),
                                )
                                .slideY(
                                  begin: 0.05,
                                  end: -0.05,
                                  duration: const Duration(milliseconds: 2500),
                                  curve: Curves.easeInOut,
                                );
                          },
                        ),
                      ),

                /// About Dev Text
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Padding(
                    padding: padding,
                    child: SizedBox(
                      width: Get.width,
                      child: HomeAboutDev(
                        controller: textController,
                        width: Get.width,
                      ),
                    ),
                  ),
                ),

                /// Scroll Down Button
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24, bottom: 40),
                    child: HomeScrollDownButton(
                      scrollController: scrollController,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
