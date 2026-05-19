import 'dart:math' as math;

import 'package:burak_basci_website/widgets/text/self_positioning_widget.dart';
import 'package:flutter/material.dart';

class SelfPositioningText extends StatelessWidget {
  const SelfPositioningText({
    required this.controller,
    required this.text,
    required this.textStyle,
    this.child,
    this.width = double.infinity,
    this.delay,
    this.textAlign,
    this.heightFactor = 1,
    super.key,
  });

  final AnimationController controller;
  final String text;
  final TextStyle? textStyle;
  final Widget? child;
  final double width;
  final Duration? delay;
  final double heightFactor;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    // The TextPainter measurement must use the SAME width the Text widget
    // will actually be laid out at — otherwise the SizedBox height
    // reserved by SelfPositioningWidget is wrong and the visible text
    // appears off-centre (a phantom blank line below it). Previously we
    // measured with the caller-supplied `width`, which is set from page
    // breakpoints (e.g. Get.width * 0.525) but did NOT account for
    // intervening Row siblings (Icon + spacer in the experience-page
    // bullet rows) or ContentBuilder's `constraints.maxWidth * 0.75`
    // body column. That mismatch made TextPainter wrap the text at a
    // narrower width than the actual render width, producing N+1
    // measured lines for an N-line render. LayoutBuilder lets us use
    // whichever width is tighter — the explicit cap or the real
    // constraint — so the measurement always matches the render.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double layoutWidth;
        if (constraints.maxWidth.isFinite) {
          layoutWidth = math.min(width, constraints.maxWidth);
        } else {
          layoutWidth = width;
        }

        final TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: textStyle,
          ),
          textDirection: TextDirection.ltr,
        )..layout(
            minWidth: 0,
            maxWidth: layoutWidth,
          );

        final double textWidth = textPainter.size.width;
        final double textHeight = textPainter.size.height * heightFactor;

        return SelfPositioningWidget(
          controller: controller,
          width: textWidth,
          height: textHeight,
          delay: delay,
          simpleChild: child,
          child: Text(
            text,
            style: textStyle,
            textAlign: textAlign,
            softWrap: true,
          ),
        );
      },
    );
  }
}
