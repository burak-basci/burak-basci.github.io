import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Exposes the tail end of a [SlideInOnVisible] entrance to the subtree
/// underneath it, so a heavy element — the project cover on a cascade
/// tile — can hold itself back until the row it belongs to has landed.
///
/// The animation handed down runs 0 → 1 *after* the travel is over (see
/// [SlideInOnVisible._travelEnd]), which is why a widget that reads it can
/// simply hand it to a [FadeTransition]: it stays at 0 for the whole
/// movement and only then fades up.
///
/// Outside an entrance (project detail pages, or a tile whose entrance has
/// already finished and been torn down) [maybeOf] returns null and callers
/// fall back to [kAlwaysCompleteAnimation] — the cover is simply visible.
class EntranceReveal extends InheritedWidget {
  const EntranceReveal({
    required this.reveal,
    required super.child,
    super.key,
  });

  final Animation<double> reveal;

  static Animation<double>? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EntranceReveal>()?.reveal;

  @override
  bool updateShouldNotify(EntranceReveal oldWidget) =>
      oldWidget.reveal != reveal;
}

/// Wraps [child] so the first time the smallest sliver of it scrolls into
/// the viewport it fades up while sliding a short distance to the right,
/// then stays at its final state. Used to make the home page project
/// cascade tiles arrive as the visitor scrolls instead of all snapping
/// into place at the moment the cascade enters view.
///
/// Each instance needs a unique [uniqueKey] — `VisibilityDetector`
/// internally requires globally unique keys across the tree.
///
/// The entrance fires exactly once per instance: a `_hasAnimated` guard in
/// the State swallows every subsequent visibility event after the first
/// qualifying one, so scrolling tiles back into view does NOT replay it.
///
/// **The movement is deliberately small.** An earlier version slid the
/// tile in from a fractional offset (`slideX(begin: -1.5)`, i.e. 1.5× the
/// child's own width) — and a cascade tile is as wide as the viewport, so
/// every entrance flung a full-width band, its title and its cover artwork
/// across ~2400 px of screen in 900 ms. It read as chaos rather than
/// arrival. The travel is now an absolute [beginOffset] in logical pixels,
/// eased in *and* out, with the opacity carrying the entrance instead of
/// the distance.
///
/// The entrance runs in two phases off a single controller so they cannot
/// drift apart:
///
///   0 → [_travelEnd]   the row travels [beginOffset] → 0 and fades 0 → 1
///   [_travelEnd] → 1   the cover fades up, via [EntranceReveal]
///
/// Nothing photographic is on screen while the row is moving; the artwork
/// develops once the row has come to rest.
///
/// Fast-scroll responsiveness: the visibility threshold is intentionally
/// very low (1%) and the cascade queue is capped + velocity-aware so a tile
/// that's scrolled past in a single wheel flick still visibly enters as the
/// user passes it. See [_CascadeStagger] for the queue flush logic.
class SlideInOnVisible extends StatefulWidget {
  const SlideInOnVisible({
    required this.uniqueKey,
    required this.child,
    this.visibilityThreshold = 0.01,
    this.beginOffset = 96.0,
    this.duration = const Duration(milliseconds: 960),
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
  /// view" feel which matters for fast-scroll users — a higher threshold
  /// lets tiles scroll past before they ever start animating.
  final double visibilityThreshold;

  /// How far left of its final position the child starts, in logical
  /// pixels. Small on purpose: the fade is what announces the element, the
  /// travel only gives it a direction. 96 px is roughly a third of the
  /// cascade's left indent at desktop width — enough to read as movement,
  /// short enough that nothing is ever seen flying.
  final double beginOffset;

  /// Full length of the entrance, travel *and* cover reveal (see
  /// [_travelEnd] for the split).
  final Duration duration;

  /// Optional cascade identifier. Tiles that share the same non-null
  /// [staggerGroup] coordinate via a shared ticket counter so that a batch
  /// of tiles which all cross the visibility threshold in the same frame
  /// fan out into a wave (tile N+1 starts `staggerStep` after tile N)
  /// instead of firing in lockstep. The counter resets after a short idle
  /// period, so a re-scroll into a fresh region (or a lone tile entering
  /// view well after the previous wave) starts again from zero delay.
  ///
  /// `null` disables staggering entirely (forward() fires immediately on
  /// first qualifying visibility).
  final String? staggerGroup;

  /// Per-step delay used to space neighbouring tile entrances inside a
  /// cascade group. 80 ms feels like a deliberate wave but keeps even the
  /// last tile in a 6-tile group under half a second of head delay.
  final Duration staggerStep;

  /// Maximum slot index that contributes additional delay. Slots beyond
  /// this cap all fire at `staggerStep × staggerCap`, so a very long list
  /// of co-visible tiles doesn't tail out for seconds. With staggerStep=80
  /// ms and staggerCap=5 the tail caps at 400 ms.
  final int staggerCap;

  /// Point in the timeline where the row has finished travelling and the
  /// cover reveal takes over. At the default 960 ms duration that is a
  /// 576 ms arrival followed by a 384 ms reveal.
  static const double _travelEnd = 0.6;

  /// Point where the row is fully opaque. Deliberately earlier than
  /// [_travelEnd]: the element should look settled slightly before it
  /// stops, otherwise the last few pixels of travel read as a stutter.
  static const double _fadeEnd = 0.42;

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

  /// Row travel, in logical pixels, from [SlideInOnVisible.beginOffset]
  /// to 0. Eased in and out — the element accelerates away from its
  /// starting point and decelerates into its slot, so neither end of the
  /// movement snaps.
  late final Animation<double> _travel;

  /// Row opacity. Front-loaded (see [SlideInOnVisible._fadeEnd]) so the
  /// element is fully present for the last stretch of its travel.
  late final Animation<double> _fade;

  /// Cover reveal, handed to the subtree through [EntranceReveal]. Pinned
  /// at 0 until the travel is over.
  late final Animation<double> _coverReveal;

  /// Latched true the first time the child crosses the visibility
  /// threshold. Every subsequent `onVisibilityChanged` callback bails
  /// out immediately so re-entering the viewport does NOT re-play the
  /// entrance. This matches the rest of the site's text animations, which
  /// fire forward() once and stay at value=1.
  bool _hasAnimated = false;

  /// True once the entrance animation has finished and the child can be
  /// rendered bare — see [build] for why that matters per frame.
  bool _settled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _travel = Tween<double>(begin: -widget.beginOffset, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          SlideInOnVisible._travelEnd,
          curve: Curves.easeInOutCubic,
        ),
      ),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.0,
        SlideInOnVisible._fadeEnd,
        curve: Curves.easeOut,
      ),
    );
    _coverReveal = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        SlideInOnVisible._travelEnd,
        1.0,
        curve: Curves.easeOut,
      ),
    );
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed && !_settled && mounted) {
        setState(() => _settled = true);
      }
    });
  }

  @override
  void dispose() {
    // CurvedAnimation holds a listener on its parent; Flutter asserts on
    // undisposed instances.
    (_fade as CurvedAnimation).dispose();
    (_coverReveal as CurvedAnimation).dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Once the entrance has played out, the wrappers are dead weight that
    // every subsequent frame still pays for: VisibilityDetector keeps
    // computing visibility and scheduling callbacks on each paint, and the
    // transform / opacity layers stay alive around a child that no longer
    // moves. The cascade has one of each per tile and repaints wholesale
    // on every scroll frame, so this is pure per-frame overhead for an
    // animation that finished seconds ago. Dropping them returns the plain
    // child, identical in appearance — travel has landed at 0, opacity at
    // 1, and the cover reveal completed *before* this fires, so nothing
    // pops when [EntranceReveal] disappears with them.
    if (_settled) return widget.child;

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
      // The subtree is built once and handed to the builder untouched, so
      // an entrance frame only re-evaluates the transform and the opacity.
      // The inner RepaintBoundary keeps the moving tile off the parent's
      // paint list: the rasteriser re-composites a cached layer at the new
      // offset instead of repainting the artwork for every frame of every
      // entrance.
      child: AnimatedBuilder(
        animation: _controller,
        child: RepaintBoundary(
          child: EntranceReveal(
            reveal: _coverReveal,
            child: widget.child,
          ),
        ),
        builder: (BuildContext context, Widget? child) {
          return Opacity(
            opacity: _fade.value,
            child: Transform.translate(
              offset: Offset(_travel.value, 0),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
