import 'package:flutter/material.dart';

import '../../../../utils/adaptive_layout.dart';
import '../../../../utils/functions.dart';
import '../../../../utils/values/values.dart';

const double lineHeight = 1;

class LoadingHomePageAnimation extends StatefulWidget {
  static const String loadingPageRoute = StringConst.LOADING_PAGE;

  const LoadingHomePageAnimation({
    required this.loadingText,
    required this.style,
    required this.onLoadingDone,
    this.lineColor,
    Key? key,
  }) : super(key: key);
  final String loadingText;
  final TextStyle? style;
  final VoidCallback onLoadingDone;
  final Color? lineColor;

  @override
  LoadingHomePageAnimationState createState() => LoadingHomePageAnimationState();
}

class LoadingHomePageAnimationState extends State<LoadingHomePageAnimation>
    with TickerProviderStateMixin {
  late AnimationController _fadeOutController;
  late AnimationController _pageLoadingController;
  late AnimationController _loadingTextOpacityController;
  late Animation<double> pageLoadingAnimation;
  late Animation<double> loadingScreenOpenAnimation;
  late Animation<double> opacityAnimation;
  late Animation<double> fadeAnimation;
  late Color lineColor;
  final Duration _loadingTextDuration = const Duration(milliseconds: 600);
  final Duration _pageLoadingDuration = const Duration(milliseconds: 1200);
  final Duration _expandingLineDuration = const Duration(milliseconds: 1000);
  final Duration _loadingScreenOpenDuration = const Duration(milliseconds: 800);
  bool _expandingLineAnimationStarted = false;
  bool _expandingLineAnimationDone = false;
  bool _isAnimationOver = false;
  late Size size;
  late double textWidth;
  late double textHeight;

  @override
  void initState() {
    super.initState();
    setTextWidthAndHeight();
    lineColor = widget.lineColor ?? Colors.white;
    _loadingTextOpacityController = AnimationController(
      vsync: this,
      duration: _loadingTextDuration,
    );
    _pageLoadingController = AnimationController(
      vsync: this,
      duration: _pageLoadingDuration,
    );
    _fadeOutController = AnimationController(
      vsync: this,
      duration: _expandingLineDuration,
    );
    loadingScreenOpenAnimation = Tween<double>(begin: 0.9, end: 0.5).animate(
      CurvedAnimation(
        parent: _loadingTextOpacityController,
        curve: Curves.fastOutSlowIn,
      ),
    );
    opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingTextOpacityController,
        curve: Curves.easeIn,
      ),
    );
    fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeOutController,
        curve: Curves.easeIn,
      ),
    );
    pageLoadingAnimation = Tween<double>(begin: 0, end: textWidth).animate(
      CurvedAnimation(
        parent: _pageLoadingController,
        curve: Curves.ease,
      ),
    );
    _loadingTextOpacityController.forward();
    _loadingTextOpacityController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _pageLoadingController.forward();
        });
      }
    });
    _pageLoadingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _expandingLineAnimationStarted = true;
          _fadeOutController.forward();
        });
      }
    });

    _fadeOutController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _expandingLineAnimationDone = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeOutController.dispose();
    _loadingTextOpacityController.dispose();
    _pageLoadingController.dispose();
    super.dispose();
  }

  void setTextWidthAndHeight() {
    size = Functions.textSize(
      text: widget.loadingText,
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
              /// Loading Screen Opening Animation Up
              Positioned(
                top: 0,
                child: AnimatedContainer(
                  width: screenWidth,
                  height: _expandingLineAnimationDone ? 0 : halfHeightOfScreen,
                  duration: _loadingScreenOpenDuration,
                  color: AppColors.black,
                  curve: Curves.easeInExpo,
                  onEnd: () {
                    widget.onLoadingDone();
                    setState(() {
                      _isAnimationOver = true;
                    });
                  },
                ),
              ),

              /// Loading Screen Opening Animation Down
              Positioned(
                bottom: 0,
                child: AnimatedContainer(
                  width: screenWidth,
                  height: _expandingLineAnimationDone ? 0 : halfHeightOfScreen,
                  duration: _loadingScreenOpenDuration,
                  color: AppColors.black,
                  curve: Curves.easeInExpo,
                ),
              ),

              /// Loading Text
              Positioned(
                bottom: screenHeight * 0.5 + 20,
                left: leftContainerStart,
                child: SizedBox(
                  width: textWidth,
                  child: Center(
                    child: FadeTransition(
                      opacity: fadeAnimation,
                      child: AnimatedBuilder(
                        animation: _loadingTextOpacityController,
                        child: Text(
                          widget.loadingText,
                          textAlign: TextAlign.center,
                          style: widget.style,
                        ),
                        builder: (context, child) => Transform.scale(
                          scale: 2 * loadingScreenOpenAnimation.value,
                          alignment: Alignment.center,
                          child: AnimatedOpacity(
                            opacity: opacityAnimation.value,
                            duration: _loadingTextDuration,
                            curve: Curves.ease,
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /// Loading bar
              Positioned(
                bottom: screenHeight * 0.5,
                child: Row(
                  children: <Widget>[
                    /// Left Line
                    SizedBox(
                      width: widthOfLeftLine,
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1.0),
                            child: Container(
                              width: widthOfLeftLine,
                              height: lineHeight,
                              color: lineColor,
                            ),
                          ),
                          Positioned(
                            left: 0,
                            child: AnimatedContainer(
                              width: _expandingLineAnimationStarted ? 0 : leftContainerStart,
                              height: lineHeight + 2,
                              color: AppColors.black,
                              duration: _expandingLineDuration,
                              curve: Curves.easeInOutQuint,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// Middle Loading Bar
                    AnimatedBuilder(
                      animation: _pageLoadingController,
                      builder: (context, child) => Container(
                        height: lineHeight,
                        width: pageLoadingAnimation.value,
                        color: lineColor,
                      ),
                    ),

                    /// Right Line
                    SizedBox(
                      width: widthOfRightLine,
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1.0),
                            child: Container(
                              width: widthOfRightLine,
                              height: lineHeight,
                              color: lineColor,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: AnimatedContainer(
                              width: _expandingLineAnimationStarted ? 0 : widthOfRightLine,
                              height: lineHeight + 2,
                              color: AppColors.black,
                              duration: _expandingLineDuration,
                              curve: Curves.easeInOutQuint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}
