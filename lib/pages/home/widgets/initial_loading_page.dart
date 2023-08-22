import 'package:flutter/material.dart';

import '../../../../utils/adaptive_layout.dart';
import '../../../../utils/functions.dart';
import '../../../../utils/values/values.dart';
import '../../../utils/values/spaces.dart';

const double lineHeight = 2;
final Color defaultLineColor = AppColors.accentColor2.withOpacity(0.35);

class LoadingHomePageAnimation extends StatefulWidget {
  static const String loadingPageRoute = StringConst.LOADING_PAGE;

  const LoadingHomePageAnimation({
    required this.text,
    required this.style,
    required this.onLoadingDone,
    this.lineColor,
    Key? key,
  }) : super(key: key);
  final String text;
  final TextStyle? style;
  final VoidCallback onLoadingDone;
  final Color? lineColor;

  @override
  LoadingHomePageAnimationState createState() => LoadingHomePageAnimationState();
}

class LoadingHomePageAnimationState extends State<LoadingHomePageAnimation>
    with TickerProviderStateMixin {
  late AnimationController _fadeOutController;
  late AnimationController _containerController;
  late AnimationController _scaleOpacityController;
  late Animation<double> containerAnimation;
  late Animation<double> scaleAnimation;
  late Animation<double> opacityAnimation;
  late Animation<double> fadeAnimation;
  late Color lineColor;
  final Duration _scaleDuration = const Duration(milliseconds: 750);
  final Duration _leftRightContainerDuration = const Duration(milliseconds: 750);
  final Duration _containerDuration = const Duration(milliseconds: 10);
  bool _leftRightAnimationStarted = false;
  bool _leftRightAnimationDone = false;
  bool _isAnimationOver = false;
  late Size size;
  late double textWidth;
  late double textHeight;

  @override
  void initState() {
    super.initState();
    setTextWidthAndHeight();
    lineColor = widget.lineColor ?? defaultLineColor;
    _scaleOpacityController = AnimationController(
      vsync: this,
      duration: _scaleDuration,
    );
    _containerController = AnimationController(
      vsync: this,
      duration: _containerDuration,
    );
    _fadeOutController = AnimationController(
      vsync: this,
      duration: _leftRightContainerDuration,
    );
    scaleAnimation = Tween<double>(begin: 0.9, end: 0.5).animate(
      CurvedAnimation(
        parent: _scaleOpacityController,
        curve: Curves.fastOutSlowIn,
      ),
    );
    opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleOpacityController,
        curve: Curves.easeIn,
      ),
    );
    fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeOutController,
        curve: Curves.easeIn,
      ),
    );
    containerAnimation = Tween<double>(begin: 0, end: textWidth).animate(
      CurvedAnimation(
        parent: _containerController,
        curve: Curves.ease,
      ),
    );
    _scaleOpacityController.forward();
    _scaleOpacityController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _containerController.forward();
        });
      }
    });
    _containerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _leftRightAnimationStarted = true;
          _fadeOutController.forward();
        });
      }
    });

    _fadeOutController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _leftRightAnimationDone = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeOutController.dispose();
    _scaleOpacityController.dispose();
    _containerController.dispose();
    super.dispose();
  }

  void setTextWidthAndHeight() {
    size = Functions.textSize(
      text: widget.text,
      style: widget.style,
    );
    textWidth = size.width;
    textHeight = size.height;
  }

  @override
  Widget build(BuildContext context) {
    setTextWidthAndHeight();
    final double screenWidth = widthOfScreen(context);
    final double screenHeight = heightOfScreen(context);
    final double halfHeightOfScreen = screenHeight * 0.5 + 1;
    final double widthOfLeftLine = assignWidth(context, 0.5) - (textWidth * 0.5);
    final double widthOfRightLine = screenWidth - (widthOfLeftLine + textWidth);
    final double leftContainerStart = (screenWidth * 0.5) - (textWidth * 0.5);

    return _isAnimationOver
        ? const SizedBox()
        : Stack(
            children: <Widget>[
              AnimatedContainer(
                width: screenWidth,
                height: _leftRightAnimationDone ? 0 : halfHeightOfScreen,
                duration: _scaleDuration,
                color: AppColors.black,
                onEnd: () {
                  widget.onLoadingDone();
                  setState(() {
                    _isAnimationOver = true;
                  });
                },
              ),
              Positioned(
                bottom: 0,
                child: AnimatedContainer(
                  width: screenWidth,
                  height: _leftRightAnimationDone ? 0 : halfHeightOfScreen,
                  duration: _scaleDuration,
                  color: AppColors.black,
                ),
              ),
              SizedBox(
                width: widthOfScreen(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: textWidth,
                          child: FadeTransition(
                            opacity: fadeAnimation,
                            child: AnimatedBuilder(
                              animation: _scaleOpacityController,
                              child: Text(
                                widget.text,
                                textAlign: TextAlign.center,
                                style: widget.style,
                              ),
                              builder: (context, child) => Transform.scale(
                                scale: 2 * scaleAnimation.value,
                                alignment: Alignment.center,
                                child: AnimatedOpacity(
                                  opacity: opacityAnimation.value,
                                  duration: _scaleDuration,
                                  child: child,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SpaceH20(),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: widthOfLeftLine,
                          child: Stack(
                            children: <Widget>[
                              Container(
                                width: widthOfLeftLine,
                                height: lineHeight,
                                color: lineColor,
                              ),
                              Positioned(
                                child: AnimatedContainer(
                                  width: _leftRightAnimationStarted ? 0 : leftContainerStart,
                                  height: lineHeight,
                                  color: AppColors.black,
                                  duration: _leftRightContainerDuration,
                                  // curve: Curves.ease,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _containerController,
                          builder: (context, child) => Container(
                            height: lineHeight,
                            width: containerAnimation.value,
                            color: lineColor,
                          ),
                        ),
                        SizedBox(
                          width: widthOfRightLine,
                          child: Stack(
                            children: <Widget>[
                              Container(
                                width: widthOfRightLine,
                                height: lineHeight,
                                color: lineColor,
                              ),
                              Positioned(
                                right: 0,
                                child: AnimatedContainer(
                                  width: _leftRightAnimationStarted ? 0 : widthOfRightLine,
                                  height: lineHeight,
                                  color: AppColors.black,
                                  duration: _leftRightContainerDuration,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          );
  }
}
