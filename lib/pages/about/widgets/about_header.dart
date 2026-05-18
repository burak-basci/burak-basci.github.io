import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../../utils/adaptive_layout.dart';
import '../../../../utils/values/values.dart';
import '../../../widgets/buttons/scroll_down_button.dart';
import 'about_header_description.dart';

class AboutHeader extends StatelessWidget {
  const AboutHeader({
    required this.scrollController,
    required this.controller,
    required this.heroBreathController,
    super.key,
  });

  final ScrollController scrollController;
  final AnimationController controller;
  /// Long-loop controller (repeat reverse) that drives the slow zoom
  /// "breathing" on the hero photo. Same technique as the project hero
  /// cover in project_detail_page.dart's `_heroBreathController`.
  final AnimationController heroBreathController;

  /// Renders the dev photo with three layered enhancements over the
  /// previous bare ClipRRect:
  ///   1. A solid colored accent block offset behind the photo (drop-
  ///      shadow style, like the colored panel on the home cascade's
  ///      project tiles), so the image visually "pops" off the page.
  ///   2. A Ken-Burns breathing zoom driven by [heroBreathController]
  ///      (1.00 -> 1.04 over 8s, reverses).
  ///   3. An entry animation driven by [controller] — the image fades
  ///      and slides in from the right as the catch lines wipe.
  /// `clipBehavior: Clip.none` on the wrapping Stack lets the accent
  /// block sit outside the ClipRRect's rounded clip area.
  Widget _buildDevImage({
    required double maxWidth,
    required double maxHeight,
    required double minWidth,
  }) {
    final BoxConstraints imageConstraints = BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        // Colored accent block — sits 20px down/right behind the photo.
        // Sized identically via the same constraints so it tracks the
        // photo's responsive size. Animates in slightly behind the
        // photo so the layering reads correctly.
        Positioned(
          top: 20,
          left: 20,
          child: ConstrainedBox(
            constraints: imageConstraints,
            child: AspectRatio(
              aspectRatio: 1.0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: CustomColors.grey300,
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ),
          )
              .animate(controller: controller, autoPlay: false)
              .fadeIn(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              )
              .slideX(
                begin: 0.05,
                end: 0,
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 200),
                curve: Curves.fastOutSlowIn,
              ),
        ),
        // Main photo — Ken-Burns zoom inside a rounded clip, then the
        // whole composite fades + slides in from the right.
        ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: ConstrainedBox(
            constraints: imageConstraints,
            child: AnimatedBuilder(
              animation: heroBreathController,
              builder: (BuildContext context, Widget? child) {
                final double t = Curves.easeInOut
                    .transform(heroBreathController.value);
                final double scale = 1.0 + t * 0.04; // 1.00 -> 1.04
                return Transform.scale(
                  scale: scale,
                  alignment: Alignment.center,
                  child: child,
                );
              },
              child: Image.asset(
                ImagePath.DEV,
                fit: BoxFit.cover,
              ),
            ),
          ),
        )
            .animate(controller: controller, autoPlay: false)
            .fadeIn(
              duration: const Duration(milliseconds: 900),
              delay: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            )
            .slideX(
              begin: 0.10,
              end: 0,
              duration: const Duration(milliseconds: 900),
              delay: const Duration(milliseconds: 400),
              curve: Curves.fastOutSlowIn,
            ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      height: Get.height,
      child: Stack(
        children: <Widget>[
          LayoutBuilder(
            builder: (context, constraints) {
              /// Mobile View
              if (constraints.maxWidth < refinedBreakpoints.tabletSmall) {
                return Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(40.0, 120.0, 40.0, 0.0),
                        child: AboutHeaderDescription(
                          controller: controller,
                          width: constraints.maxWidth - 80.0,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 120.0),
                        child: _buildDevImage(
                          minWidth: constraints.maxWidth * 0.5 - 80,
                          maxWidth: constraints.maxWidth - 80,
                          maxHeight: constraints.maxHeight * 0.6 - 120,
                        ),
                      ),
                    ),
                  ],
                );
              }

              /// Tablet and Desktop View
              else {
                return Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 80.0),
                        child: AboutHeaderDescription(
                          controller: controller,
                          width: constraints.maxWidth * 0.5 - 100,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 80.0),
                        child: _buildDevImage(
                          minWidth: constraints.maxWidth * 0.25 - 100,
                          maxWidth: constraints.maxWidth * 0.5 - 100,
                          maxHeight: constraints.maxHeight * 0.6,
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ScrollDownButton(scrollController: scrollController),
          ),
        ],
      ),
    );
  }
}
