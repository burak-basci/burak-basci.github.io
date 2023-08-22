import 'package:flutter/material.dart';

class AnimatedPositionedWidget extends StatefulWidget {
  const AnimatedPositionedWidget({
    required this.controller,
    required this.width,
    required this.height,
    required this.child,
    this.relativeRect,
    this.slideAnimationcurve = Curves.fastOutSlowIn,
    Key? key,
  }) : super(key: key);

  final CurvedAnimation controller;
  final double width;
  final double height;
  final Widget child;
  final Animation<RelativeRect>? relativeRect;
  final Curve slideAnimationcurve;

  @override
  AnimatedPositionedWidgetState createState() => AnimatedPositionedWidgetState();
}

class AnimatedPositionedWidgetState extends State<AnimatedPositionedWidget> {
  late Animation<RelativeRect> textPositionAnimation;

  @override
  void initState() {
    textPositionAnimation = widget.relativeRect ??
        RelativeRectTween(
          begin: RelativeRect.fromSize(
            Rect.fromLTWH(0, widget.height, widget.width, widget.height),
            Size(widget.width, widget.height),
          ),
          end: RelativeRect.fromSize(
            Rect.fromLTWH(0, 0, widget.width, widget.height),
            Size(widget.width, widget.height),
          ),
        ).animate(widget.controller);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Stack(
        children: <Widget>[
          PositionedTransition(
            rect: textPositionAnimation,
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
