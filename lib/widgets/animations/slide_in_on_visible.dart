import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Wraps [child] so the first time at least 15% of it scrolls into the
/// viewport the child slides in from fully offstage on the left and
/// then stays at its final state. Used to make the home page project
/// cascade tiles appear as the visitor scrolls instead of all snapping
/// into place at the moment the cascade enters view.
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
///
/// The slide uses `flutter_animate`'s fractional [slideX] (offset in
/// units of the widget's own width) rather than an absolute pixel
/// offset, so the tile is guaranteed to start entirely offstage to
/// the left regardless of viewport width or final tile placement —
/// no part of the tile peeks into view before the animation begins.
class SlideInOnVisible extends StatefulWidget {
  const SlideInOnVisible({
    required this.uniqueKey,
    required this.child,
    this.visibilityThreshold = 0.15,
    this.slideBeginX = -1.5,
    this.duration = const Duration(milliseconds: 900),
    this.staggerGroup,
    this.staggerStep = const Duration(milliseconds: 140),
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

  /// Starting horizontal offset for the slide, expressed in multiples
  /// of the child's own width. Negative values start offstage to the
  /// left. The default `-1.5` puts the child 1.5× its width past the
  /// left edge of its own layout slot, guaranteeing it is fully off
  /// the visible canvas at animation start even for tiles whose final
  /// position is well to the right of the viewport's left edge.
  final double slideBeginX;

  final Duration duration;

  /// Optional cascade identifier. Tiles that share the same non-null
  /// [staggerGroup] coordinate via a shared ticket counter so that a
  /// batch of tiles which all cross the visibility threshold in the
  /// same frame fan out into a wave (tile N+1 starts `staggerStep`
  /// after tile N) instead of firing in lockstep. The counter resets
  /// after a short idle period, so a re-scroll into a fresh region
  /// (or a lone tile entering view well after the previous wave)
  /// starts again from zero delay.
  ///
  /// `null` disables staggering entirely (forward() fires immediately
  /// on first qualifying visibility).
  final String? staggerGroup;

  /// Per-step delay used to space neighbouring tile entrances inside a
  /// cascade group. 140 ms feels like a deliberate wave without
  /// dragging out the last tile noticeably.
  final Duration staggerStep;

  @override
  State<SlideInOnVisible> createState() => _SlideInOnVisibleState();
}

/// Per-group state for queue-based cascade staggering. One entry per
/// distinct [SlideInOnVisible.staggerGroup] value; entries are kept on
/// a private static map keyed by group name. A `ticket` field holds the
/// next slot index to hand out, and `lastClaim` records the wall-clock
/// time of the most recent claim so the queue can self-reset after an
/// idle gap (i.e. when a lone tile enters view well after the last
/// wave finished).
class _CascadeStagger {
  _CascadeStagger();

  /// Idle window after which the queue resets to slot 0. Slightly longer
  /// than the worst-case per-tile delay so a small wave can complete
  /// before a freshly-triggered tile starts numbering from scratch.
  static const Duration _idleReset = Duration(milliseconds: 1500);

  static final Map<String, _CascadeStagger> _groups = <String, _CascadeStagger>{};

  int _ticket = 0;
  DateTime _lastClaim = DateTime.fromMillisecondsSinceEpoch(0);

  /// Claim the next slot in [group]'s queue. Resets to 0 if the queue
  /// has been idle for more than [_idleReset] since the previous claim.
  static int claim(String group) {
    final _CascadeStagger entry = _groups.putIfAbsent(group, _CascadeStagger.new);
    final DateTime now = DateTime.now();
    if (now.difference(entry._lastClaim) > _idleReset) {
      entry._ticket = 0;
    }
    final int slot = entry._ticket;
    entry._ticket += 1;
    entry._lastClaim = now;
    return slot;
  }
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
    // Use a fractional slide (units = child's own width) so the tile
    // is guaranteed to start fully offstage to the left regardless of
    // viewport size or final tile placement. `slideX(begin: -1.5)`
    // puts the child 1.5× its own width past its layout slot — even
    // tiles whose final left edge is several hundred pixels from the
    // viewport's left edge are completely out of view at t=0.
    return VisibilityDetector(
      key: widget.uniqueKey,
      onVisibilityChanged: (VisibilityInfo info) {
        if (_hasAnimated) return;
        if (info.visibleFraction >= widget.visibilityThreshold) {
          _hasAnimated = true;
          // Queue-based stagger: tiles which share a `staggerGroup` and
          // cross the visibility threshold inside the same idle window
          // claim sequential slots, so the first tile in a wave fires
          // immediately and each subsequent neighbour waits
          // `staggerStep` longer. A lone tile entering view well after
          // the previous wave reclaims slot 0 (the queue resets after a
          // short idle gap inside [_CascadeStagger]) so it does NOT
          // inherit a long pending delay from earlier tiles.
          //
          // The `mounted` guard inside the delayed callback makes the
          // schedule safe if the user navigates away (e.g. into a
          // project detail) before the delay elapses — the controller
          // would otherwise be disposed.
          int slot = 0;
          if (widget.staggerGroup != null) {
            slot = _CascadeStagger.claim(widget.staggerGroup!);
          }
          if (slot == 0) {
            if (mounted) _controller.forward();
          } else {
            Future<void>.delayed(widget.staggerStep * slot, () {
              if (mounted) _controller.forward();
            });
          }
        }
      },
      child: widget.child
          .animate(controller: _controller, autoPlay: false)
          .slideX(
            begin: widget.slideBeginX,
            end: 0,
            duration: widget.duration,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}
