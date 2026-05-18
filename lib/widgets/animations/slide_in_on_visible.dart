import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Wraps [child] so the first time at least 15% of it scrolls into the
/// viewport the child animates in (fade + slide-from-left) and then stays
/// at its final state. Used to make the home page project cascade tiles
/// appear as the visitor scrolls instead of all snapping into place at
/// the moment the cascade enters view.
///
/// Each instance needs a unique [uniqueKey] — `VisibilityDetector`
/// internally requires globally unique keys across the tree.
class SlideInOnVisible extends StatefulWidget {
  const SlideInOnVisible({
    required this.uniqueKey,
    required this.child,
    this.visibilityThreshold = 0.15,
    this.slideOffsetX = -60.0,
    this.duration = const Duration(milliseconds: 700),
    super.key,
  });

  /// Globally unique key for the inner `VisibilityDetector`. Must NOT be
  /// reused across instances or detection events will collide.
  final Key uniqueKey;

  final Widget child;

  /// Fraction of the child that has to be in the viewport before the
  /// entrance animation triggers. 0.15 (15%) gives a "just peeked into
  /// view" feel; bump up for a "fully on-screen" feel.
  final double visibilityThreshold;

  /// Horizontal offset in absolute pixels for the entrance slide.
  /// Negative slides in from the left.
  final double slideOffsetX;

  final Duration duration;

  @override
  State<SlideInOnVisible> createState() => _SlideInOnVisibleState();
}

class _SlideInOnVisibleState extends State<SlideInOnVisible>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.uniqueKey,
      onVisibilityChanged: (VisibilityInfo info) {
        if (_triggered) return;
        if (info.visibleFraction >= widget.visibilityThreshold) {
          _triggered = true;
          if (mounted) _controller.forward();
        }
      },
      child: widget.child
          .animate(controller: _controller, autoPlay: false)
          .fadeIn(
            duration: widget.duration,
            curve: Curves.easeOut,
          )
          .move(
            begin: Offset(widget.slideOffsetX, 0),
            end: Offset.zero,
            duration: widget.duration,
            curve: Curves.fastOutSlowIn,
          ),
    );
  }
}
