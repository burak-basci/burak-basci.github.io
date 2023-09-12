import 'package:flutter/material.dart';

import '../../../utils/functions.dart';
import '../../../utils/values/values.dart';
import 'animated_slide_box.dart';

class AnimatedTextSlideBoxTransition extends StatefulWidget {
  const AnimatedTextSlideBoxTransition({
    required this.controller,
    required this.text,
    required this.textStyle,
    this.width = double.infinity,
    this.maxLines = 1,
    this.widthFactor = 1,
    this.heightFactor = 1,
    this.visibleBoxAnimation,
    this.invisibleBoxAnimation,
    this.position,
    this.textAlign,
    this.boxColor = AppColors.black,
    this.coverColor = AppColors.primaryColor,
    this.visibleAnimationCurve = Curves.fastOutSlowIn,
    this.invisibleAnimationCurve = Curves.fastOutSlowIn,
    this.slideAnimationCurve = Curves.fastOutSlowIn,
    Key? key,
  }) : super(key: key);

  final AnimationController controller;
  final double heightFactor;
  final double widthFactor;
  final Color boxColor;
  final Color coverColor;
  final Animation<double>? visibleBoxAnimation;
  final Animation<double>? invisibleBoxAnimation;
  final Animation<Offset>? position;
  final Curve visibleAnimationCurve;
  final Curve invisibleAnimationCurve;
  final Curve slideAnimationCurve;
  final String text;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final double width;
  final int maxLines;

  @override
  AnimatedTextSlideBoxTransitionState createState() => AnimatedTextSlideBoxTransitionState();
}

class AnimatedTextSlideBoxTransitionState extends State<AnimatedTextSlideBoxTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> visibleAnimation;
  late Animation<double> invisibleAnimation;
  late Animation<RelativeRect> textPositionAnimation;
  late Size size;
  late double textWidth;
  late double textHeight;

  @override
  void initState() {
    setTextWidthAndHeight();
    controller = widget.controller;
    visibleAnimation = widget.visibleBoxAnimation ??
        Tween<double>(begin: 0, end: textWidth).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0,
              0.4,
              curve: widget.visibleAnimationCurve,
            ),
          ),
        );

    invisibleAnimation = widget.invisibleBoxAnimation ??
        Tween<double>(begin: 0, end: textWidth).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.4,
              0.8,
              curve: widget.invisibleAnimationCurve,
            ),
          ),
        );

    textPositionAnimation = RelativeRectTween(
      begin: RelativeRect.fromSize(
        Rect.fromLTWH(0, textHeight, textWidth, textHeight),
        Size(textWidth, textHeight),
      ),
      end: RelativeRect.fromSize(
        Rect.fromLTWH(0, 0, textWidth, textHeight),
        Size(textWidth, textHeight),
      ),
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.6, 1.0, curve: widget.invisibleAnimationCurve),
      ),
    );

    super.initState();
  }

  void setTextWidthAndHeight() {
    size = Functions.textSize(
      text: widget.text,
      style: widget.textStyle,
      maxWidth: widget.width,
      maxLines: widget.maxLines,
    );
    textWidth = size.width * widget.widthFactor;
    textHeight = size.height * widget.heightFactor;
  }

  @override
  Widget build(BuildContext context) {
    setTextWidthAndHeight();

    return SizedBox(
      height: textHeight,
      child: Stack(
        children: <Widget>[
          AnimatedSlideBox(
            controller: widget.controller,
            height: textHeight,
            width: textWidth,
            boxColor: widget.boxColor,
            // visibleBoxAnimation: visibleAnimation,
            // invisibleBoxAnimation: invisibleAnimation,
          ),
          PositionedTransition(
            rect: textPositionAnimation,
            child: Text(
              widget.text,
              style: widget.textStyle,
              textAlign: widget.textAlign,
            ),
          ),
        ],
      ),
    );
  }
}
