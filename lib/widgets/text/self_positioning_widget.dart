import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SelfPositioningWidget extends StatelessWidget {
  const SelfPositioningWidget({
    required this.controller,
    required this.child,
    this.width,
    this.height,
    this.simpleChild,
    this.delay,
    super.key,
  });

  final AnimationController controller;
  final Widget child;
  final double? width;
  final double? height;
  final Widget? simpleChild;
  final Duration? delay;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ClipRect(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: <Widget>[
          SizedBox(
            height: height,
            width: width,
            child: child,
          )
              .animate(
                controller: controller,
                autoPlay: false,
              )
              .slideY(
                duration: const Duration(milliseconds: 800),
                // begin: 1.1 translates the text down by 110% of the
                // SizedBox height initially (vs. exactly 100%). The extra
                // 10% absorbs the few pixels of glyph ascender that some
                // fonts render ABOVE the SizedBox's top edge — those
                // pixels were peeking through above the ClipRect on the
                // Experience page titles where TextStyle.height was not
                // explicitly set. Animation still ends at 0.0 (no
                // translation), so the visible final position is
                // unchanged.
                begin: 1.1,
                end: 0.0,
                curve: Curves.fastOutSlowIn,
                delay: delay,
              ),

          simpleChild ?? const SizedBox(),

          /// This makes the Text widget invisible, when the animation has not started yet
          Positioned(
            top: height,
            child: SizedBox(
              height: height,
              width: width,
              child: const ColoredBox(
                color: Colors.white,
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
