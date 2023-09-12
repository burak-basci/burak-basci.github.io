import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

import '../../../utils/adaptive_layout.dart';
import '../../../utils/values/values.dart';
import '../animations/animated_slide_transition.dart';
import '../animations/animated_text_slide_box_transition.dart';

class DefaultPageHeader extends StatefulWidget {
  const DefaultPageHeader({
    required this.scrollController,
    required this.headingText,
    required this.headingTextController,
    Key? key,
  }) : super(key: key);

  final ScrollController scrollController;
  final String headingText;
  final AnimationController headingTextController;

  @override
  DefaultPageHeaderState createState() => DefaultPageHeaderState();
}

class DefaultPageHeaderState extends State<DefaultPageHeader> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> animation;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    animation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: const Offset(0, -0.5),
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = heightOfScreen(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? headingStyle = textTheme.headline2?.copyWith(
      color: AppColors.black,
      fontSize: responsiveSize(
        context,
        Sizes.TEXT_SIZE_40,
        Sizes.TEXT_SIZE_60,
      ),
    );
    return SizedBox(
      width: widthOfScreen(context),
      height: heightOfScreen(context),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              ImagePath.WORKS,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: AnimatedTextSlideBoxTransition(
              controller: widget.headingTextController,
              text: widget.headingText,
              textStyle: headingStyle,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Margin(
              margin: const EdgeInsets.only(bottom: Sizes.MARGIN_40),
              child: InkWell(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {
                  widget.scrollController.animateTo(
                    screenHeight * 0.9,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.ease,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AnimatedSlideTransition(
                    controller: controller,
                    position: animation,
                    child: Image.asset(
                      ImagePath.ARROW_DOWN_IOS,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
