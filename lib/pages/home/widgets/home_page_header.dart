import 'package:flutter/material.dart';
import 'package:layout/layout.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../utils/adaptive_layout.dart';
import '../../../../utils/values/values.dart';
import '../../../widgets/animations/animated_slide_transition.dart';
import 'home_about_dev.dart';
import 'home_scroll_down_button.dart';

const kDuration = Duration(milliseconds: 600);

class HomePageHeader extends StatefulWidget {
  const HomePageHeader({
    Key? key,
    required this.scrollToWorksKey,
    required this.controller,
  }) : super(key: key);

  final GlobalKey scrollToWorksKey;
  final AnimationController controller;
  @override
  HomePageHeaderState createState() => HomePageHeaderState();
}

class HomePageHeaderState extends State<HomePageHeader> with TickerProviderStateMixin {
  late AnimationController controller;
  late AnimationController rotationController;
  late AnimationController scrollDownButtonController;
  late Animation<Offset> animation;
  late Animation<Offset> scrollDownBtnAnimation;

  @override
  void initState() {
    scrollDownButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    animation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: const Offset(0, -0.05),
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
    rotationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        rotationController.reset();
        rotationController.forward();
        // rotationController.reverse();
      }
    });
    controller.forward();
    rotationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    scrollDownButtonController.dispose();
    rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = widthOfScreen(context);
    final double screenHeight = heightOfScreen(context);
    // final EdgeInsets textMargin = EdgeInsets.only(
    //   left: responsiveSize(
    //     context,
    //     20,
    //     screenWidth * 0.15,
    //     small: screenWidth * 0.15,
    //   ),
    //   top: responsiveSize(
    //     context,
    //     60,
    //     screenHeight * 0.35,
    //     small: screenHeight * 0.35,
    //   ),
    //   bottom: responsiveSize(context, 20, 40),
    // );
    final EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: screenWidth * 0.1,
      vertical: screenHeight * 0.1,
    );
    // final EdgeInsets imageMargin = EdgeInsets.only(
    //   right: responsiveSize(
    //     context,
    //     20,
    //     screenWidth * 0.05,
    //     small: screenWidth * 0.05,
    //   ),
    //   top: responsiveSize(
    //     context,
    //     30,
    //     screenHeight * 0.25,
    //     small: screenHeight * 0.25,
    //   ),
    //   bottom: responsiveSize(context, 20, 40),
    // );

    return Container(
      width: screenWidth,
      height: screenHeight * 0.92,
      color: AppColors.accentColor2.withOpacity(0.35),
      child: Stack(
        children: <Widget>[
          const Center(
            child: WhiteCircle(),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Padding(
              padding: padding,
              child: SizedBox(
                width: screenWidth,
                child: HomeAboutDev(
                  controller: widget.controller,
                  width: screenWidth,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: -screenHeight * 0.1,
            child: Padding(
              padding: padding.copyWith(bottom: 0.0),
              child: AnimatedSlideTransition(
                controller: controller,
                position: animation,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(1, 0.8, 1),
                  child: LayoutBuilder(builder: (context, constraints) {
                    double size;

                    if (screenWidth > screenHeight) {
                      size = screenHeight * 0.6;
                    } else {
                      size = screenWidth * 0.6;
                    }

                    return Text(
                      'X',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: size,
                        color: Colors.black,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: ResponsiveBuilder(
              builder: (context, sizingInformation) {
                double screenWidth = sizingInformation.screenSize.width;
                if (screenWidth < const RefinedBreakpoints().tabletNormal) {
                  return Container();
                } else {
                  return InkWell(
                    hoverColor: Colors.transparent,
                    onTap: () {
                      Scrollable.ensureVisible(
                        widget.scrollToWorksKey.currentContext!,
                        duration: kDuration,
                      );
                    },
                    child: Margin(
                      margin: const EdgeInsets.only(right: 24, bottom: 40),
                      child: MouseRegion(
                        onEnter: (e) => scrollDownButtonController.forward(),
                        onExit: (e) => scrollDownButtonController.reverse(),
                        child: AnimatedSlideTransition(
                          controller: scrollDownButtonController,
                          beginOffset: const Offset(0, 0),
                          targetOffset: const Offset(0, 0.1),
                          child: const HomeScrollDownButton(),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WhiteCircle extends StatelessWidget {
  const WhiteCircle({
    this.child,
    Key? key,
  }) : super(key: key);
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 460,
      height: 460,
      margin: const EdgeInsets.all(40),
      decoration: const BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: child,
      ),
    );
  }
}
