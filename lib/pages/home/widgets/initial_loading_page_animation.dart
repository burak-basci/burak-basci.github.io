import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../../utils/values/values.dart';

class LoadingHomePageAnimation extends StatefulWidget {
  const LoadingHomePageAnimation({
    required this.loadingText,
    required this.style,
    required this.onLoadingDone,
    super.key,
  });
  final String loadingText;
  final TextStyle? style;
  final VoidCallback onLoadingDone;

  static const Duration _loadingTextDuration = Duration(milliseconds: 600);
  static const Duration _loadingPageDuration = Duration(milliseconds: 800);
  static const Duration _expandingLineDuration = Duration(milliseconds: 800);
  static const Duration _openPageDuration = Duration(milliseconds: 800);

  // ^= _loadingPageDuration + _expandingLineDuration + 100
  static const Duration _fadeOutTextDelay = Duration(milliseconds: 1900);
  // ^= _loadingTextDuration + _loadingPageDuration + _expandingLineDuration + 400
  static const Duration _openPageDelay = Duration(milliseconds: 2500);

  static const Duration _lineFadeOutDuration = Duration(milliseconds: 300);
  static const Duration _textFadeOutDuration = Duration(milliseconds: 400);

  @override
  State<LoadingHomePageAnimation> createState() => _LoadingHomePageAnimationState();
}

class _LoadingHomePageAnimationState extends State<LoadingHomePageAnimation> {
  bool isAnimationOver = false;

  @override
  Widget build(BuildContext context) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: widget.loadingText, style: widget.style), textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);

    final double textWidth = textPainter.size.width;

    final double halfScreenHeight = Get.height * 0.5 + 1;
    final double leftContainerStart = (Get.width * 0.5) - (textWidth * 0.5);

    return isAnimationOver
        ? const SizedBox()
        : Stack(
            children: <Widget>[
              /// Loading Screen Opening Animation - Up
              Positioned(
                top: 0,
                child: Container(
                  width: Get.width,
                  height: halfScreenHeight,
                  color: CustomColors.black,
                ).animate().scaleY(
                      begin: 1,
                      end: 0,
                      curve: Curves.easeInExpo,
                      alignment: Alignment.topCenter,
                      delay: LoadingHomePageAnimation._openPageDelay,
                      duration: LoadingHomePageAnimation._openPageDuration,
                    ),
              ),

              /// Loading Screen Opening Animation - Down
              Positioned(
                bottom: 0,
                child: Container(
                  width: Get.width,
                  height: halfScreenHeight,
                  color: CustomColors.black,
                ).animate(
                  onComplete: (_) {
                    widget.onLoadingDone();
                    setState(() {
                      isAnimationOver = true;
                    });
                  },
                ).scaleY(
                  begin: 1,
                  end: 0,
                  curve: Curves.easeInExpo,
                  alignment: Alignment.bottomCenter,
                  delay: LoadingHomePageAnimation._openPageDelay,
                  duration: LoadingHomePageAnimation._openPageDuration,
                ),
              ),

              /// Loading Text
              Positioned(
                bottom: Get.height * 0.5 + 20.0,
                left: leftContainerStart,
                child: Text(
                  widget.loadingText,
                  textAlign: TextAlign.center,
                  style: widget.style,
                )
                    .animate()
                    .scale(
                      begin: const Offset(2, 2),
                      end: const Offset(1, 1),
                      curve: Curves.easeIn,
                      duration: LoadingHomePageAnimation._loadingTextDuration,
                    )
                    .fadeIn(
                      curve: Curves.easeIn,
                      duration: LoadingHomePageAnimation._loadingTextDuration,
                    )
                    .then()
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(0.90, 0.90),
                      curve: Curves.easeOut,
                      delay: LoadingHomePageAnimation._fadeOutTextDelay,
                      duration: LoadingHomePageAnimation._textFadeOutDuration,
                    )
                    .fadeOut(
                      curve: Curves.easeOut,
                      delay: LoadingHomePageAnimation._fadeOutTextDelay,
                      duration: LoadingHomePageAnimation._textFadeOutDuration,
                    ),
              ),

              /// Loading bar
              Positioned(
                bottom: Get.height * 0.5,
                child: Container(
                  height: 1.0,
                  width: Get.width,
                  color: Colors.white,
                )
                    .animate()
                    .scaleX(
                      begin: 0,
                      end: 1,
                      alignment: Alignment.centerLeft,
                      curve: Curves.ease,
                      delay: LoadingHomePageAnimation._loadingTextDuration,
                      duration: LoadingHomePageAnimation._loadingPageDuration,
                    )
                    .then()
                    .scaleX(
                      begin: textWidth / Get.width,
                      end: 1,
                      alignment: Alignment.center,
                      curve: Curves.ease,
                      duration: LoadingHomePageAnimation._expandingLineDuration,
                    )
                    .then()
                    .fadeOut(
                      curve: Curves.easeOut,
                      duration: LoadingHomePageAnimation._lineFadeOutDuration,
                    ),
              ),
            ],
          );
  }
}
