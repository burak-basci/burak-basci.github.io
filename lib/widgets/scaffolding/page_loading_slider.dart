import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../utils/values/values.dart';

class PageLoadingSlider extends AnimatedWidget {
  const PageLoadingSlider({
    required this.controller,
    this.isSlideForward = true,
    super.key,
  }) : super(
          listenable: controller,
        );

  final AnimationController controller;
  final bool isSlideForward;

  @override
  Widget build(BuildContext context) {
    if (isSlideForward) {
      return SizedBox(
        height: Get.height,
        width: Get.width,
        child: const ColoredBox(
          color: CustomColors.black,
        ),
      )
          .animate(
            controller: controller,
            autoPlay: false,
          )
          .scaleX(
            begin: 0.0,
            end: 1.0,
            alignment: Alignment.centerLeft,
            curve: Curves.easeInCubic,
            duration: const Duration(milliseconds: 800),
          );
    } else {
      return SizedBox(
        height: Get.height,
        width: Get.width,
        child: const ColoredBox(
          color: CustomColors.black,
        ),
      )
          .animate(
            controller: controller,
            autoPlay: false,
          )
          .scaleX(
            begin: 1.0,
            end: 0.0,
            alignment: Alignment.centerRight,
            curve: Curves.easeOutQuart,
            duration: const Duration(milliseconds: 800),
          );
    }
  }
}
