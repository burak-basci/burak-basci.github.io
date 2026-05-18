import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../utils/values/values.dart';

class ScrollDownButton extends StatelessWidget {
  const ScrollDownButton({
    required this.scrollController,
    super.key,
  });

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: InkWell(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          scrollController.animateTo(
            Get.height * 0.84,
            duration: const Duration(milliseconds: 600),
            curve: Curves.ease,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Image.asset(
            ImagePath.ARROW_DOWN_IOS,
          ),
        ),
      )
          .animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          )
          .slideY(
            begin: 0.2,
            end: 0.6,
            duration: const Duration(milliseconds: 1800),
            curve: Curves.easeInOut,
          ),
    );
  }
}
