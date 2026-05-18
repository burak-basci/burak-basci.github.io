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
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: width,
      );

    double textWidth = textPainter.size.width;
    double textHeight = textPainter.size.height * heightFactor;

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
  }
}
