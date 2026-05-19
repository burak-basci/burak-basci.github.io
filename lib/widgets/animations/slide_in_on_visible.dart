import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Wraps [child] so the first time at least 15% of it scrolls into the
/// viewport the child slides in from just past the left edge of the
/// viewport and then stays at its final state. Used to make the home
/// page project cascade tiles appear as the visitor scrolls instead of
/// all snapping into place at the moment the cascade enters view.
///
/// Each instance needs a unique [uniqueKey] — `VisibilityDetector`
/// internally requires globally unique keys across the tree.
///
/// The entrance fires exactly once per instance: a `_hasAnimated` guard
/// in the State swallows every subsequent visibility event after the
/// first qualifying one, so scrolling tiles back into view does NOT
/// replay the slide. There is no fade — only a translate — because the
/// tiles should feel like they are physically sliding in from behind
/// the left edge, not materialising mid-screen.
class SlideInOnVisible extends StatefulWidget {
  const SlideInOnVisible({
    required this.uniqueKey,
    required this.child,
    this.visibilityThreshold = 0.15,
    this.slideOffsetX,
    this.duration = const Duration(milliseconds: 900),
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
  /// Negative slides in from the left. When null we derive it from the
  /// current viewport width so each tile starts just past the left edge
  /// of the visible area regardless of screen size.
  final double? slideOffsetX;

  final Duration duration;

  @override
  State<SlideInOnVisible> createState() => _SlideInOnVisibleState();
}

class _SlideInOnVisibleState extends State<SlideInOnVisible>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// Latched true the first time the child crosses the visibility
  /// threshold. Every subsequent `onVisibilityChanged` callback bails
  /// out immediately so re-entering the viewport does NOT re-play the
  /// slide. This matches the rest of the site's text animations, which
  /// fire forward() once and stay at value=1.
  bool _hasAnimated = false;

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
    // Start the tile half a viewport-width offstage to the left so it
    // genuinely reads as "sliding in from behind the visible area"
    // rather than appearing in the middle of the screen.
    final double offsetX = widget.slideOffsetX ??
        -MediaQuery.of(context).size.width * 0.5;

    return VisibilityDetector(
      key: widget.uniqueKey,
      onVisibilityChanged: (VisibilityInfo info) {
        if (_hasAnimated) return;
        if (info.visibleFraction >= widget.visibilityThreshold) {
          _hasAnimated = true;
          if (mounted) _controller.forward();
        }
      },
      child: widget.child
          .animate(controller: _controller, autoPlay: false)
          .move(
            begin: Offset(offsetX, 0),
            end: Offset.zero,
            duration: widget.duration,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}
