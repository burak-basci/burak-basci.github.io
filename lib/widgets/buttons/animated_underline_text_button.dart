import 'package:burak_basci_website/utils/values/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../text/slide_box_transitioning_text.dart';

class AnimatedUnderlineTextButton extends StatefulWidget {
  const AnimatedUnderlineTextButton({
    required this.text,
    required this.textStyle,
    this.slideBoxController,
    this.width = double.infinity,
    this.slideOffset = 0.04,
    this.underlineColor = CustomColors.black,
    this.hoverTextColor,
    this.hasSlideBoxAnimation = false,
    this.underlineBottomOffset = 0.0,
    this.onTap,
    super.key,
  }) : assert(hasSlideBoxAnimation == true && slideBoxController != null ||
            hasSlideBoxAnimation == false && slideBoxController == null);

  final String text;
  final TextStyle? textStyle;
  final AnimationController? slideBoxController;
  final double width;
  final double slideOffset;
  final Color underlineColor;
  final Color? hoverTextColor;
  final bool hasSlideBoxAnimation;
  final double underlineBottomOffset;
  final GestureTapCallback? onTap;

  @override
  AnimatedUnderlineTextButtonState createState() => AnimatedUnderlineTextButtonState();
}

class AnimatedUnderlineTextButtonState extends State<AnimatedUnderlineTextButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late double textWidth;
  late double textHeight;
  bool _isHovering = false;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);

    calculateTextWidthAndHeight();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _mouseEnter(bool hovering) {
    if (hovering) {
      setState(() {
        _animationController.forward();

        _isHovering = hovering;
      });
    } else {
      setState(() {
        _animationController.reverse();

        _isHovering = hovering;
      });
    }
  }

  void calculateTextWidthAndHeight() {
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

    textWidth = textPainter.size.width;
    textHeight = textPainter.size.height;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => _mouseEnter(true),
      onExit: (e) => _mouseEnter(false),
      child: InkWell(
        onTap: widget.onTap,
        hoverColor: Colors.transparent,
        child: SizedBox(
          width: textWidth + 8,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              /// Slide box transition animation
              widget.hasSlideBoxAnimation
                  ? AnimatedSlideBoxTransitionText(
                      controller: widget.slideBoxController ?? _animationController,
                      text: widget.text,
                      width: widget.width,
                      textStyle: widget.textStyle,
                    )
                  : const SizedBox(),

              /// Underline animation
              Positioned(
                bottom: widget.underlineBottomOffset,
                child: _isHovering
                    ? Container(
                        height: 2.0,
                        color: widget.underlineColor,
                        width: textWidth * 0.94, //forwardAnimation.value, slight trim to align with visible glyph width
                      )
                        .animate(
                          controller: _animationController,
                          autoPlay: false,
                        )
                        .scaleX(
                          begin: 0,
                          end: 1,
                          alignment: Alignment.centerLeft,
                          curve: Curves.fastOutSlowIn,
                          duration: const Duration(milliseconds: 300),
                        )
                    : Container(
                        height: 2.0,
                        color: widget.underlineColor,
                        width: textWidth * 0.94, //forwardAnimation.value, slight trim to align with visible glyph width
                      )
                        .animate(
                          controller: _animationController,
                          autoPlay: false,
                        )
                        .scaleX(
                          begin: 0,
                          end: 1,
                          alignment: Alignment.centerRight,
                          curve: Curves.fastOutSlowIn,
                          duration: const Duration(milliseconds: 300),
                        ),
              ),
              // if it has the slide animation, the text will be invisible from AnimatedTextSlideBoxTransition
              !widget.hasSlideBoxAnimation
                  ? _isHovering
                      ? Text(
                          widget.text,
                          style: widget.textStyle?.copyWith(
                            color: widget.hoverTextColor,
                          ),
                        )
                      : Text(
                          widget.text,
                          style: widget.textStyle,
                        )
                  : const SizedBox(),
            ],
          ),

          /// Slide transition animation
        )
            .animate(
              controller: _animationController,
              autoPlay: false,
            )
            .slideX(
              begin: 0,
              end: widget.slideOffset,
              curve: Curves.fastOutSlowIn,
              duration: const Duration(milliseconds: 300),
            ),
      ),
    );
  }
}

class AnimatedUnderlineText extends StatefulWidget {
  const AnimatedUnderlineText({
    required this.text,
    required this.textStyle,
    required this.animationController,
    this.width = double.infinity,
    this.slideOffset = 0.04,
    this.underlineColor = CustomColors.black,
    this.hoverTextColor,
    super.key,
  });

  final String text;
  final TextStyle? textStyle;
  final AnimationController animationController;
  final double width;
  final double slideOffset;
  final Color underlineColor;
  final Color? hoverTextColor;

  @override
  AnimatedUnderlineTextState createState() => AnimatedUnderlineTextState();
}

class AnimatedUnderlineTextState extends State<AnimatedUnderlineText> {
  late double textWidth;
  late double textHeight;
  bool _isHovering = false;

  @override
  void initState() {
    widget.animationController.addListener(() {
      if (widget.animationController.status == AnimationStatus.forward) {
        setState(() {
          _isHovering = true;
        });
      } else if (widget.animationController.status == AnimationStatus.reverse) {
        setState(() {
          _isHovering = false;
        });
      }
    });

    calculateTextWidthAndHeight();
    super.initState();
  }

  void calculateTextWidthAndHeight() {
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

    textWidth = textPainter.size.width;
    textHeight = textPainter.size.height;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: textWidth + 8,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          /// Underline animation
          Positioned(
            bottom: 0.0,
            child: _isHovering
                ? Container(
                    height: 2.0,
                    color: widget.underlineColor,
                    width: textWidth, //forwardAnimation.value,
                  )
                    .animate(
                      controller: widget.animationController,
                      autoPlay: false,
                    )
                    .scaleX(
                      begin: 0,
                      end: 1,
                      alignment: Alignment.centerLeft,
                      curve: Curves.fastOutSlowIn,
                      duration: const Duration(milliseconds: 300),
                    )
                : Container(
                    height: 2.0,
                    color: widget.underlineColor,
                    width: textWidth, //forwardAnimation.value,
                  )
                    .animate(
                      controller: widget.animationController,
                      autoPlay: false,
                    )
                    .scaleX(
                      begin: 0,
                      end: 1,
                      alignment: Alignment.centerRight,
                      curve: Curves.fastOutSlowIn,
                      duration: const Duration(milliseconds: 300),
                    ),
          ),
          _isHovering
              ? Text(
                  widget.text,
                  style: widget.textStyle?.copyWith(
                    color: widget.hoverTextColor,
                  ),
                )
              : Text(
                  widget.text,
                  style: widget.textStyle,
                ),
        ],
      ),

      /// Slide transition animation
    )
        .animate(
          controller: widget.animationController,
          autoPlay: false,
        )
        .slideX(
          begin: 0,
          end: widget.slideOffset,
          curve: Curves.fastOutSlowIn,
          duration: const Duration(milliseconds: 300),
        );
  }
}
