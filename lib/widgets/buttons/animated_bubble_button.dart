import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../utils/values/values.dart';
import '../../utils/values/spaces.dart';

class AnimatedBubbleButton extends StatefulWidget {
  const AnimatedBubbleButton({
    this.child,
    this.title = '',
    this.titleStyle,
    this.height = 48,
    this.targetWidth = 160,
    this.bubbleColor = CustomColors.black100,
    this.imageColor = CustomColors.accentColor,
    this.duration = const Duration(milliseconds: 300),
    this.onTap,
    super.key,
  });

  final String title;
  final TextStyle? titleStyle;
  final double height;
  final double targetWidth;
  final Color bubbleColor;
  final Color imageColor;
  final Duration duration;
  final Widget? child;
  final GestureTapCallback? onTap;

  @override
  AnimatedBubbleButtonState createState() => AnimatedBubbleButtonState();
}

class AnimatedBubbleButtonState extends State<AnimatedBubbleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isHovering = false;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
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

  @override
  Widget build(BuildContext context) {
    final TextStyle? baseTitleStyle = widget.titleStyle ??
        Get.textTheme.bodyLarge?.copyWith(
          color: CustomColors.accentColor,
          fontSize: Sizes.TEXT_SIZE_15,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        );
    final TextStyle? buttonStyle = baseTitleStyle?.copyWith(
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
    );

    return MouseRegion(
      onEnter: (e) => _mouseEnter(true),
      onExit: (e) => _mouseEnter(false),
      child: SizedBox(
        width: widget.targetWidth,
        height: widget.height,
        child: InkWell(
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: widget.onTap,
          child: Stack(
            children: <Widget>[
              /// Background Bubble
              AnimatedContainer(
                width: _isHovering ? widget.targetWidth : widget.height,
                height: widget.height,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: widget.bubbleColor,
                  borderRadius: const BorderRadius.all(Radius.circular(80.0)),
                ),
                curve: Curves.fastOutSlowIn,
                duration: widget.duration,
              ),
              Positioned.fill(
                child: Center(
                  child: widget.child ??
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: buttonStyle,
                          ),
                          const SpaceW8(),
                          Image.asset(
                            width: 20.0,
                            height: 20.0,
                            color: widget.imageColor,
                            fit: BoxFit.contain,
                            ImagePath.ARROW_RIGHT,
                          ),
                        ],
                      ),
                ),
              ),
            ],
          ),
        )

            /// Slide transition animation
            .animate(
              controller: _animationController,
              autoPlay: false,
            )
            .slideX(
              begin: 0,
              end: 0.04,
              curve: Curves.fastOutSlowIn,
              duration: widget.duration,
            ),
      ),
    );
  }
}
