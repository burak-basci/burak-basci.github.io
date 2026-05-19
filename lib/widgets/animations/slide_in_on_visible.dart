import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Wraps [child] so the first time the smallest sliver of it scrolls
/// into the viewport the child slides in from fully offstage on the
/// left and then stays at its final state. Used to make the home page
/// project cascade tiles appear as the visitor scrolls instead of all
/// snapping into place at the moment the cascade enters view.
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
///
/// Fast-scroll responsiveness: the visibility threshold is intentionally
/// very low (1%) and the cascade queue is capped + velocity-aware so a
/// tile that's scrolled past in a single wheel flick still visibly
/// enters as the user passes it. See [_CascadeStagger] for the queue
/// flush logic.
class SlideInOnVisible extends StatefulWidget {
  const SlideInOnVisible({
    required this.uniqueKey,
    required this.child,
    this.visibilityThreshold = 0.01,
    this.slideBeginX = -1.5,
    this.duration = const Duration(milliseconds: 900),
    this.staggerGroup,
    this.staggerStep = const Duration(milliseconds: 80),
    this.staggerCap = 5,
    super.key,
  });

  /// Globally unique key for the inner `VisibilityDetector`. Must NOT be
  /// reused across instances or detection events will collide.
  final Key uniqueKey;

  final Widget child;

  /// Fraction of the child that has to be in the viewport before the
  /// entrance animation triggers. 0.01 (1%) gives a "just peeked into
  /// view" feel which matters for fast-scroll users — a higher
  /// threshold lets tiles scroll past before they ever start animating.
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
  /// cascade group. 80 ms feels like a deliberate wave but keeps even
  /// the last tile in a 6-tile group under half a second of head delay.
  final Duration staggerStep;

  /// Maximum slot index that contributes additional delay. Slots beyond
  /// this cap all fire at `staggerStep × staggerCap`, so a very long
  /// list of co-visible tiles doesn't tail out for seconds. With
  /// staggerStep=80ms and staggerCap=5 the tail caps at 400ms.
  final int staggerCap;

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
///
/// Fast-scroll detection: if a claim arrives within
/// [_fastScrollWindow] of the previous claim, the wave is treated as a
/// fast-scroll burst — `_fastScrollHits` is incremented, and once it
/// crosses [_fastScrollThreshold] every subsequent claim in the burst
/// returns slot 0 (fire immediately). This prevents the "tile invisible
/// because its 400ms+ delay hasn't elapsed" problem when the user flicks
/// the wheel through the cascade region.
class _CascadeStagger {
  _CascadeStagger();

  /// Idle window after which the queue resets to slot 0. Slightly longer
  /// than the worst-case per-tile delay so a small wave can complete
  /// before a freshly-triggered tile starts numbering from scratch.
  static const Duration _idleReset = Duration(milliseconds: 1500);

  /// If two consecutive claims arrive within this window, treat the
  /// scroll as fast (multiple tiles passing the threshold in quick
  /// succession). 100 ms comfortably covers tiles arriving in adjacent
  /// frames at 60 fps while still excluding slow deliberate scrolling.
  static const Duration _fastScrollWindow = Duration(milliseconds: 100);

  /// Number of within-window claims after which the queue flips into
  /// "flush immediately" mode for the rest of the burst.
  static const int _fastScrollThreshold = 2;

  static final Map<String, _CascadeStagger> _groups = <String, _CascadeStagger>{};

  int _ticket = 0;
  int _fastScrollHits = 0;
  DateTime _lastClaim = DateTime.fromMillisecondsSinceEpoch(0);

  /// Claim the next slot in [group]'s queue. Resets to 0 if the queue
  /// has been idle for more than [_idleReset] since the previous claim.
  /// If consecutive claims are arriving inside [_fastScrollWindow], the
  /// caller has effectively reported a fast-scroll burst — after
  /// [_fastScrollThreshold] hits the queue returns slot 0 for the rest
  /// of the burst so each tile fires as soon as it crosses the
  /// visibility threshold instead of inheriting cumulative delay.
  static int claim(String group) {
    final _CascadeStagger entry = _groups.putIfAbsent(group, _CascadeStagger.new);
    final DateTime now = DateTime.now();
    final Duration gap = now.difference(entry._lastClaim);
    if (gap > _idleReset) {
      entry._ticket = 0;
      entry._fastScrollHits = 0;
    } else if (gap <= _fastScrollWindow) {
      entry._fastScrollHits += 1;
    } else {
      // Slow scroll continuation inside the same wave — back off the
      // fast-scroll counter so a brief rapid burst followed by slow
      // scrolling doesn't permanently disable staggering.
      entry._fastScrollHits = 0;
    }
    final bool flushNow = entry._fastScrollHits >= _fastScrollThreshold;
    final int slot = flushNow ? 0 : entry._ticket;
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
          // Queue-based stagger with cap + fast-scroll flush. Tiles
          // sharing a `staggerGroup` and crossing the visibility
          // threshold inside the same idle window claim sequential
          // slots, capped at [staggerCap] so a long list doesn't tail
          // out for seconds. If [_CascadeStagger] detects consecutive
          // claims arriving within its fast-scroll window it returns
          // slot 0 for the rest of the burst — necessary so flick-
          // scrolling past the cascade still shows tiles entering view
          // (rather than tiles waiting out a stagger delay after the
          // user has already scrolled past them).
          //
          // The `mounted` guard inside the delayed callback makes the
          // schedule safe if the user navigates away (e.g. into a
          // project detail) before the delay elapses — the controller
          // would otherwise be disposed.
          int slot = 0;
          if (widget.staggerGroup != null) {
            final int raw = _CascadeStagger.claim(widget.staggerGroup!);
            slot = raw > widget.staggerCap ? widget.staggerCap : raw;
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
