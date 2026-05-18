import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/values/values.dart';
import '../../../utils/values/spaces.dart';

class HomeScrollDownButton extends StatelessWidget {
  const HomeScrollDownButton({
    required this.scrollController,
    super.key,
  });

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            RotatedBox(
              quarterTurns: 1,
              child: Text(
                StringConst.SCROLL_DOWN.toUpperCase(),
                style: Get.textTheme.titleMedium?.copyWith(
                  fontSize: 12,
                  letterSpacing: 1.7,
                ),
              ),
            ),
            const SpaceH16(),
            Image.asset(
              ImagePath.ARROW_DOWN,
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}
