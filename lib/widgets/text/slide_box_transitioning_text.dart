import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../utils/values/values.dart';
import 'self_positioning_text.dart';

class AnimatedSlideBoxTransitionText extends StatefulWidget {
  const AnimatedSlideBoxTransitionText({
    required this.controller,
    required this.text,
    required this.textStyle,
    this.textAlign,
    this.width = double.infinity,
    this.heightFactor = 1,
    super.key,
  });

  final AnimationController controller;
  final String text;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final double width;
  final double heightFactor;

  @override
  State<AnimatedSlideBoxTransitionText> createState() => _AnimatedSlideBoxTransitionTextState();
}

class _AnimatedSlideBoxTransitionTextState extends State<AnimatedSlideBoxTransitionText> {
  @override
  Widget build(BuildContext context) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: widget.textStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: widget.width,
      );

    double textWidth = textPainter.size.width;
    double textHeight = textPainter.size.height * widget.heightFactor;

    return SelfPositioningText(
      controller: widget.controller,
      text: widget.text,
      textStyle: widget.textStyle,
      width: widget.width,
      heightFactor: widget.heightFactor,
      textAlign: widget.textAlign,
      delay: const Duration(milliseconds: 800),
      child: Container(
        width: textWidth,
        height: textHeight,
        color: CustomColors.black,
      )
          .animate(
            controller: widget.controller,
            autoPlay: false,
          )
          .scaleX(
            begin: 0.0,
            end: 1.0,
            curve: Curves.fastOutSlowIn,
            alignment: Alignment.centerLeft,
            duration: const Duration(milliseconds: 800),
          )
          .then()
          .scaleX(
            begin: 1.0,
            end: 0.0,
            alignment: Alignment.centerRight,
            duration: const Duration(milliseconds: 800),
          ),
    );
  }
}
