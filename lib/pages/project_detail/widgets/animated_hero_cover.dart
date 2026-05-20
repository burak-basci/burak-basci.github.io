import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../utils/lang.dart';
import '../../../widgets/project_item/project_item.dart';

/// A live-painted port of `tools/gen_covers.py`. Renders the entire 6-layer
/// hero cover composition (gradient → diagonal lines → radial glow →
/// 120-ish particles → category illustration → vignette) directly into
/// the Flutter widget tree via a single [CustomPainter], so every visual
/// element becomes an addressable, individually-animated entity instead
/// of being baked into a static `.webp` raster.
///
/// Architecture:
///   • Four [AnimationController]s driving distinct rhythms
///     (gradient stop drift, glow pulse, particle drift, illustration
///      element motion).
///   • A pre-seeded `Random(project.slug.hashCode)` builds the 120-ish
///     particle table once in `initState`. Same seed → same constellation
///     every reload, matching the Python script's deterministic per-slug
///     behaviour.
///   • All four controllers are merged into a single [Listenable] so
///     `_HeroCoverPainter` repaints once per vsync (~60 fps target). A
///     [RepaintBoundary] isolates the cover from surrounding rebuilds.
class AnimatedHeroCover extends StatefulWidget {
  const AnimatedHeroCover({
    super.key,
    required this.project,
    required this.lang,
    this.animated = true,
  });

  final ProjectItemData project;
  final AppLang lang;

  /// When false the painter renders one static frame and the
  /// controllers never tick — used for small thumbnails and
  /// next-project previews where 30 fps animation everywhere would
  /// be perf-overkill and visually noisy.
  final bool animated;

  @override
  State<AnimatedHeroCover> createState() => _AnimatedHeroCoverState();
}

class _AnimatedHeroCoverState extends State<AnimatedHeroCover>
    with TickerProviderStateMixin {
  late final AnimationController _gradient;
  late final AnimationController _glow;
  late final AnimationController _particles;
  late final AnimationController _illustration;
  late final AnimationController _vignette;
  // Dedicated linear-loop controller for the falling-line layer. The
  // fall is a continuous downward translate — reversing it would make
  // the lines drift back up, which destroys the falling-rain feel.
  // The wrap is invisible because each line teleports back to top
  // off-screen (modulo math in the painter), so there is no visible
  // 1.0 → 0.0 snap.
  late final AnimationController _fallingLines;

  // --- "More alive" controllers ---------------------------------------
  // Slow global wind drift (120 s for one full back-and-forth) — applied
  // as a sideways offset to every particle/blur/falling line so the
  // entire field appears to ride a slow air current.
  late final AnimationController _wind;
  // 30 s aurora sweep (one direction, then invisibly resets — eased so
  // the start/end are slow, masking the wrap-around).
  late final AnimationController _aurora;
  // 60 Hz time source for radar-ping lifecycles and twinkle alpha. We
  // multiply controller.value by its duration in ms to get an unbounded
  // elapsed-ms clock (modulo the wrap of repeat()).
  late final AnimationController _ping;
  // Decays the cursor parallax offset back to (0,0) when the mouse
  // exits the widget. We drive the actual offset via lerp(_lastOffset,
  // Offset.zero, _cursorDecay.value).
  late final AnimationController _cursorDecay;

  late final List<_Particle> _particleTable;
  late final List<_FallingLine> _fallingLineTable;
  late final List<_BlurredParticle> _blurredParticleTable;
  // Subset of indices into _particleTable that should twinkle. Roughly
  // 15-20 particles selected at seed-time (15% probability).
  late final List<_Twinkler> _twinklers;
  late final Listenable _ticker;

  // --- Cursor parallax state ------------------------------------------
  // Normalized cursor offset (-1..1 on each axis). Updated from
  // MouseRegion.onHover, throttled to ~16 ms (one frame).
  Offset _cursorNormalized = Offset.zero;
  // Snapshot taken at the moment the mouse exits — _cursorDecay
  // animates the displayed offset from this back to (0,0).
  Offset _decayFrom = Offset.zero;
  bool _cursorActive = false;
  // Last viewport size seen during paint, used to compute the normalized
  // offset from the local hover position.
  Size _lastSize = Size.zero;
  int _lastHoverUpdateMs = 0;

  // --- Radar pings ----------------------------------------------------
  final List<_RadarPing> _pings = <_RadarPing>[];
  Timer? _pingScheduler;
  // Deterministic per-slug RNG for ping origin selection so pings cluster
  // believably (still away from the title area), but feel unpredictable
  // because the spawn time itself is randomized.
  late final math.Random _pingRng;

  @override
  void initState() {
    super.initState();
    // Every reversible controller uses repeat(reverse: true) so it
    // bounces 0 → 1 → 0 smoothly with no 1.0 → 0.0 snap. Periods
    // stretched ×1.5–2× the previous values so the overall hero feels
    // slower and more ambient.
    _gradient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    );
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    // Particles + illustration use reverse:true so the sine-driven
    // sub-elements never all hit t=0 together (the previous
    // repeat() without reverse was the source of the "hard reset"
    // every cycle).
    _particles = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 50),
    );
    _illustration = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    _vignette = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 38),
    );
    // Falling lines: continuous downward loop (45 s for one full
    // sweep of the longest line). Cannot reverse — the lines would
    // climb back up. The wrap is invisible because each line's
    // modulo math teleports it back above the cover off-screen.
    _fallingLines = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45),
    );
    // Slow global wind drift — 120 s for a full back-and-forth, so
    // the X-displacement crosses zero only once per minute.
    _wind = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    );
    // Aurora sweep: 30 s one-direction loop. The eased band sits
    // off-screen during the last 10% of the cycle, hiding the wrap.
    _aurora = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    // 1 Hz tick wrapped into an unbounded ms clock via floor(value *
    // 1000) plus an integer wrap counter. The Listenable forces
    // repaint at ~60 Hz so ping animations stay smooth.
    _ping = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _cursorDecay = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (widget.animated) {
      _gradient.repeat(reverse: true);
      _glow.repeat(reverse: true);
      _particles.repeat(reverse: true);
      _illustration.repeat(reverse: true);
      _vignette.repeat(reverse: true);
      _fallingLines.repeat();
      _wind.repeat(reverse: true);
      _aurora.repeat();
      _ping.repeat();
    }

    final math.Random rng = math.Random(widget.project.slug.hashCode);
    _particleTable = List<_Particle>.generate(
      120,
      (int i) {
        return _Particle(
          baseX: 0.025 + rng.nextDouble() * 0.95,
          baseY: 0.045 + rng.nextDouble() * 0.91,
          ampX: 0.004 + rng.nextDouble() * 0.014,
          ampY: 0.004 + rng.nextDouble() * 0.014,
          periodX: 0.35 + rng.nextDouble() * 1.4,
          periodY: 0.35 + rng.nextDouble() * 1.4,
          phaseX: rng.nextDouble() * 2 * math.pi,
          phaseY: rng.nextDouble() * 2 * math.pi,
          radius: <double>[1.0, 1.0, 1.0, 1.6, 2.0, 2.6][rng.nextInt(6)],
          alpha: 0.16 + rng.nextDouble() * 0.32,
        );
      },
      growable: false,
    );

    // Falling vertical hairlines — each line gets its own seeded
    // x-position, length, alpha, and fall-speed so they look unrelated
    // and never align on any visible beat.
    final math.Random rngFall = math.Random(widget.project.slug.hashCode * 31);
    _fallingLineTable = List<_FallingLine>.generate(
      26,
      (int i) {
        return _FallingLine(
          x: 0.02 + rngFall.nextDouble() * 0.96,
          // baseTopY is a fractional offset 0..1 used as an initial
          // phase so lines don't all start at the same Y on page-load.
          baseTopY: rngFall.nextDouble(),
          // 10–40 px length at 1600x900 reference (sy-scaled in paint).
          // Previously 30–120 px — that read as visible vertical
          // streaks and felt heavier than the calmer brief; the
          // shorter range turns each line into a quiet hairline mote.
          length: 10.0 + rngFall.nextDouble() * 30.0,
          // Fall-speed: how many "cover heights" the line traverses
          // per full controller cycle (45 s). 0.4–3.0 gives traversal
          // times between ~15 s and ~110 s for the slowest, but the
          // line table mostly clusters at 1.0–2.5 so most lines cross
          // the cover in 18 – 45 s.
          fallSpeed: 1.0 + rngFall.nextDouble() * 2.0,
          alpha: 0.15 + rngFall.nextDouble() * 0.15, // 0.15 – 0.30
          strokeWidth: 1.0 + rngFall.nextDouble() * 1.0, // 1 – 2 px
        );
      },
      growable: false,
    );

    // Out-of-focus blurred particles. Larger (8–20 px), low alpha
    // (0.05–0.15), blurred via MaskFilter so they read as background
    // depth. Slow Lissajous periods (12–25 s remapped against the
    // 50 s particles controller) so they drift gently.
    final math.Random rngBlur = math.Random(widget.project.slug.hashCode * 17);
    _blurredParticleTable = List<_BlurredParticle>.generate(
      20,
      (int i) {
        return _BlurredParticle(
          baseX: 0.05 + rngBlur.nextDouble() * 0.90,
          baseY: 0.08 + rngBlur.nextDouble() * 0.84,
          // Larger drift amplitudes than the focused particles so the
          // blurred dots feel like they're parallax-floating behind.
          ampX: 0.010 + rngBlur.nextDouble() * 0.025,
          ampY: 0.010 + rngBlur.nextDouble() * 0.025,
          periodX: 0.20 + rngBlur.nextDouble() * 0.50,
          periodY: 0.20 + rngBlur.nextDouble() * 0.50,
          phaseX: rngBlur.nextDouble() * 2 * math.pi,
          phaseY: rngBlur.nextDouble() * 2 * math.pi,
          radius: 8.0 + rngBlur.nextDouble() * 12.0, // 8 – 20 px
          alpha: 0.05 + rngBlur.nextDouble() * 0.10, // 0.05 – 0.15
          blurSigma: 4.0 + rngBlur.nextDouble() * 4.0, // 4 – 8 px blur
        );
      },
      growable: false,
    );

    // Twinklers: a 15% sample of the focused particles, each given its
    // own period (1.5–3.5 s) and phase. Stored as a side-table so the
    // base _Particle struct stays untouched (and immutable).
    final math.Random rngTwk =
        math.Random(widget.project.slug.hashCode * 53 ^ 0x5A5A);
    final List<_Twinkler> twk = <_Twinkler>[];
    for (int i = 0; i < _particleTable.length; i++) {
      if (rngTwk.nextDouble() < 0.15) {
        twk.add(_Twinkler(
          index: i,
          period: 1.5 + rngTwk.nextDouble() * 2.0, // 1.5 – 3.5 s
          phase: rngTwk.nextDouble() * 2 * math.pi,
        ));
      }
    }
    _twinklers = List<_Twinkler>.unmodifiable(twk);

    _pingRng = math.Random(widget.project.slug.hashCode * 97 ^ 0xC0DE);

    _ticker = Listenable.merge(<Listenable>[
      _gradient,
      _glow,
      _particles,
      _illustration,
      _vignette,
      _fallingLines,
      _wind,
      _aurora,
      _ping,
      _cursorDecay,
    ]);

    if (widget.animated) {
      _scheduleNextPing();
    }
  }

  /// Schedules the next radar ping to spawn 8–15 s from now (uniform
  /// random). On fire the ping is pushed into `_pings` and the next
  /// scheduler is queued — keeps 1–3 concurrent rings alive at most
  /// (each ring expires after 800 ms).
  void _scheduleNextPing() {
    final double secs = 8.0 + _pingRng.nextDouble() * 7.0; // 8 – 15 s
    _pingScheduler = Timer(
      Duration(milliseconds: (secs * 1000).round()),
      () {
        if (!mounted) return;
        _spawnPing();
        _scheduleNextPing();
      },
    );
  }

  void _spawnPing() {
    // Origin is chosen in normalized [0,1] coords. The title text sits
    // roughly in the lower-left (project_detail_page composes the
    // headline over the cover) so we bias pings to the upper-right
    // half (x in 0.35–0.95, y in 0.10–0.70).
    final double ox = 0.35 + _pingRng.nextDouble() * 0.60;
    final double oy = 0.10 + _pingRng.nextDouble() * 0.60;
    final double maxR = 80.0 + _pingRng.nextDouble() * 40.0; // 80 – 120 px
    _pings.add(_RadarPing(
      startMs: _nowMs(),
      originX: ox,
      originY: oy,
      maxRadius: maxR,
    ));
    // Cap concurrent pings at 3 — drop the oldest if we somehow exceed.
    while (_pings.length > 3) {
      _pings.removeAt(0);
    }
  }

  // Unbounded ms clock derived from _ping's repeating 1 s controller.
  // We can't just read DateTime.now() inside paint (well, we can — but
  // keeping the painter driven purely by Listenable values keeps it
  // testable and free of side effects). For ping lifecycles we need a
  // monotonic ms reading regardless, so we use the DateTime here only
  // at spawn-time (outside paint).
  int _nowMs() => DateTime.now().millisecondsSinceEpoch;

  void _onHover(PointerHoverEvent event) {
    final int nowMs = _nowMs();
    if (nowMs - _lastHoverUpdateMs < 16) return; // throttle to ~60 Hz
    _lastHoverUpdateMs = nowMs;
    if (_lastSize.width <= 0 || _lastSize.height <= 0) return;
    final double dx =
        (event.localPosition.dx - _lastSize.width / 2) / (_lastSize.width / 2);
    final double dy =
        (event.localPosition.dy - _lastSize.height / 2) / (_lastSize.height / 2);
    setState(() {
      _cursorActive = true;
      _cursorNormalized = Offset(
        dx.clamp(-1.0, 1.0),
        dy.clamp(-1.0, 1.0),
      );
    });
  }

  void _onExit(PointerExitEvent event) {
    _cursorActive = false;
    _decayFrom = _cursorNormalized;
    _cursorDecay
      ..reset()
      ..forward();
  }

  void _onEnter(PointerEnterEvent event) {
    _cursorActive = true;
    _cursorDecay.stop();
  }

  @override
  void dispose() {
    _pingScheduler?.cancel();
    _gradient.dispose();
    _glow.dispose();
    _particles.dispose();
    _illustration.dispose();
    _vignette.dispose();
    _fallingLines.dispose();
    _wind.dispose();
    _aurora.dispose();
    _ping.dispose();
    _cursorDecay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color base = widget.project.primaryColor;
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Cache the size so MouseRegion.onHover can normalize the
          // local position without round-tripping through the painter.
          _lastSize = Size(constraints.maxWidth, constraints.maxHeight);
          // The decayed cursor offset: lerp from the snapshot taken at
          // exit-time toward Offset.zero over 600 ms. While active the
          // offset is the live _cursorNormalized.
          final Offset effectiveCursor = _cursorActive
              ? _cursorNormalized
              : Offset.lerp(
                    _decayFrom,
                    Offset.zero,
                    Curves.easeOut.transform(_cursorDecay.value),
                  ) ??
                  Offset.zero;
          return MouseRegion(
            onEnter: widget.animated ? _onEnter : null,
            onExit: widget.animated ? _onExit : null,
            onHover: widget.animated ? _onHover : null,
            child: CustomPaint(
              painter: _HeroCoverPainter(
                base: base,
                category: widget.project.categoryFor(widget.lang),
                particles: _particleTable,
                fallingLines: _fallingLineTable,
                blurredParticles: _blurredParticleTable,
                twinklers: _twinklers,
                pings: _pings,
                cursor: effectiveCursor,
                gradient: _gradient,
                glow: _glow,
                particlesC: _particles,
                illustration: _illustration,
                vignette: _vignette,
                fallingLinesC: _fallingLines,
                windC: _wind,
                auroraC: _aurora,
                pingC: _ping,
                repaint: _ticker,
              ),
              size: Size.infinite,
            ),
          );
        },
      ),
    );
  }
}

/// Single pre-seeded particle entry. Positions are normalised to the
/// canvas [0,1] range so the same table renders at any resolution.
class _Particle {
  const _Particle({
    required this.baseX,
    required this.baseY,
    required this.ampX,
    required this.ampY,
    required this.periodX,
    required this.periodY,
    required this.phaseX,
    required this.phaseY,
    required this.radius,
    required this.alpha,
  });
  final double baseX;
  final double baseY;
  final double ampX;
  final double ampY;
  final double periodX;
  final double periodY;
  final double phaseX;
  final double phaseY;
  final double radius;
  final double alpha;
}

/// A long thin vertical hairline that drops from above the cover and
/// scrolls downward, wrapping back to the top once it exits the
/// bottom. Each line has its own x, length, fall speed, alpha so the
/// 25-ish lines look completely uncorrelated.
class _FallingLine {
  const _FallingLine({
    required this.x,
    required this.baseTopY,
    required this.length,
    required this.fallSpeed,
    required this.alpha,
    required this.strokeWidth,
  });
  final double x;          // 0..1 — fractional x position
  final double baseTopY;   // 0..1 — initial phase along the fall cycle
  final double length;     // reference-space length (sy-scaled in paint)
  final double fallSpeed;  // cover-heights per controller cycle
  final double alpha;
  final double strokeWidth;
}

/// A larger, low-alpha, MaskFilter-blurred circle that drifts on a
/// slow Lissajous like the focused particles but at lower frequency
/// and bigger radius. Gives the cover a parallax sense of depth.
class _BlurredParticle {
  const _BlurredParticle({
    required this.baseX,
    required this.baseY,
    required this.ampX,
    required this.ampY,
    required this.periodX,
    required this.periodY,
    required this.phaseX,
    required this.phaseY,
    required this.radius,
    required this.alpha,
    required this.blurSigma,
  });
  final double baseX;
  final double baseY;
  final double ampX;
  final double ampY;
  final double periodX;
  final double periodY;
  final double phaseX;
  final double phaseY;
  final double radius;
  final double alpha;
  final double blurSigma;
}

/// A particle that twinkles. `index` references the focused-particle
/// table; the painter multiplies that particle's baseAlpha by a
/// sinusoid driven by `period` (seconds) and `phase`.
class _Twinkler {
  const _Twinkler({
    required this.index,
    required this.period,
    required this.phase,
  });
  final int index;
  final double period;
  final double phase;
}

/// An expanding-ring radar ping. Origins are stored in normalized
/// [0,1] coordinates so the same ping renders consistently across
/// resolutions. Lifecycle is 800 ms — past that, the painter culls it.
class _RadarPing {
  _RadarPing({
    required this.startMs,
    required this.originX,
    required this.originY,
    required this.maxRadius,
  });
  final int startMs;
  final double originX;
  final double originY;
  final double maxRadius;
}

Color _darken(Color c, double f) {
  return Color.fromARGB(
    c.alpha,
    (c.red * f).clamp(0, 255).toInt(),
    (c.green * f).clamp(0, 255).toInt(),
    (c.blue * f).clamp(0, 255).toInt(),
  );
}

Color _lighten(Color c, double f) {
  return Color.fromARGB(
    c.alpha,
    (c.red + (255 - c.red) * f).clamp(0, 255).toInt(),
    (c.green + (255 - c.green) * f).clamp(0, 255).toInt(),
    (c.blue + (255 - c.blue) * f).clamp(0, 255).toInt(),
  );
}

/// Renders the whole cover composition in one shot. The painter is
/// driven by [repaint] (a merged Listenable bundling all the
/// controllers) so a single repaint cycle covers every layer.
class _HeroCoverPainter extends CustomPainter {
  _HeroCoverPainter({
    required this.base,
    required this.category,
    required this.particles,
    required this.fallingLines,
    required this.blurredParticles,
    required this.twinklers,
    required this.pings,
    required this.cursor,
    required this.gradient,
    required this.glow,
    required this.particlesC,
    required this.illustration,
    required this.vignette,
    required this.fallingLinesC,
    required this.windC,
    required this.auroraC,
    required this.pingC,
    required Listenable repaint,
  })  : top = _lighten(base, 0.14),
        bottom = _darken(base, 0.50),
        pale = _lighten(base, 0.55),
        accent = _lighten(base, 0.30),
        glowColor = _lighten(base, 0.35),
        super(repaint: repaint);

  final Color base;
  final String category;
  final List<_Particle> particles;
  final List<_FallingLine> fallingLines;
  final List<_BlurredParticle> blurredParticles;
  final List<_Twinkler> twinklers;
  // Live, mutable ping list owned by the state. We read+cull from
  // inside paint (expired entries removed in-place). It's not great
  // CustomPainter hygiene but it sidesteps re-allocating lists at
  // 60 Hz; the painter never escapes the widget so the coupling is
  // safe.
  final List<_RadarPing> pings;
  // Effective normalized cursor offset (-1..1), already smoothed for
  // exit-decay by the state.
  final Offset cursor;
  final AnimationController gradient;
  final AnimationController glow;
  final AnimationController particlesC;
  final AnimationController illustration;
  final AnimationController vignette;
  final AnimationController fallingLinesC;
  final AnimationController windC;
  final AnimationController auroraC;
  final AnimationController pingC;

  final Color top;
  final Color bottom;
  final Color pale;
  final Color accent;
  final Color glowColor;

  // Reusable paint objects so we don't allocate per frame.
  final Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final Paint _fillPaint = Paint()..style = PaintingStyle.fill;

  // The Python reference frame is 1600x900. Scale every illustration
  // coordinate against that so geometry maps 1:1 to the canvas regardless
  // of viewport size.
  static const double _refW = 1600.0;
  static const double _refH = 900.0;

  // Global multiplier applied to illustration radii / shape sizes so
  // the big abstract corner shapes (orbiting circles, machined
  // component, monumental block, etc.) read as the dominant cover
  // element at modern viewport widths. Python baked these at 1600x900,
  // but the Flutter cover renders at 1440x900 or smaller and the
  // illustrations were anchored at (~1200, ~360) which crowds them
  // into the right edge. 1.7× both pushes them outward and makes
  // them unambiguously the focal shape.
  static const double _illMul = 1.7;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    // Scale factor from the 1600x900 reference to actual size.
    final double sx = size.width / _refW;
    final double sy = size.height / _refH;

    // Animation values.
    final double tGrad = gradient.value;
    final double tGlow = glow.value;
    final double tPart = particlesC.value;
    final double tIll = illustration.value;
    final double tVig = vignette.value;
    final double tFall = fallingLinesC.value;
    final double tWind = windC.value;
    final double tAur = auroraC.value;

    // ----- Subtle effect offsets ---------------------------------------
    // Wind: ±40 px sideways, ±12 px vertical, 120 s reversing cycle. y
    // is phase-offset π/3 so x and y never zero-cross simultaneously.
    final double windX = math.sin(tWind * 2 * math.pi) * 40.0 * sx;
    final double windY = math.sin(tWind * 2 * math.pi + math.pi / 3) * 12.0 * sy;
    // Cursor parallax: particles shift WITH the cursor (max ±12 px),
    // illustration shifts AGAINST (max ±6 px) → fake parallax depth.
    final double parX = cursor.dx * 12.0;
    final double parY = cursor.dy * 12.0;

    // ----- Layer 1: diagonal gradient (animated stops + endpoint drift)
    final double gradShift = 0.06 * math.sin(tGrad * 2 * math.pi);
    final ui.Gradient grad = ui.Gradient.linear(
      Offset(rect.left + gradShift * size.width, rect.top),
      Offset(rect.right, rect.bottom - gradShift * size.height),
      <Color>[top, bottom],
      <double>[0.0 + gradShift.abs() * 0.5, 1.0 - gradShift.abs() * 0.4],
    );
    canvas.drawRect(rect, Paint()..shader = grad);

    // ----- Layer 2: faint diagonal lines (static texture).
    _strokePaint
      ..color = pale.withValues(alpha: 0.055)
      ..strokeWidth = 2.0;
    final double spacing = 220.0 * sx;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        _strokePaint,
      );
    }

    // ----- Layer 3: radial glow upper-right, pulsing + drifting.
    final double glowAlpha = 0.55 + 0.40 * tGlow; // 0.55 → 0.95
    final double gdx = (tGlow - 0.5) * 40.0;
    final double gdy = (tGlow - 0.5) * 32.0;
    final Offset glowCenter = Offset(
      size.width * 0.78 + gdx,
      size.height * 0.28 + gdy,
    );
    final double glowRadius = 0.55 *
        math.min(size.width, size.height) *
        (1.0 + 0.04 * math.sin(tGlow * 2 * math.pi));
    final ui.Gradient glowGrad = ui.Gradient.radial(
      glowCenter,
      glowRadius,
      <Color>[
        glowColor.withValues(alpha: glowAlpha * 0.78),
        glowColor.withValues(alpha: glowAlpha * 0.30),
        glowColor.withValues(alpha: 0.0),
      ],
      <double>[0.0, 0.55, 1.0],
    );
    canvas.drawCircle(glowCenter, glowRadius, Paint()..shader = glowGrad);

    // ----- Layer 3b: aurora sweep -------------------------------------
    // A soft diagonal band of light traverses the cover every ~30 s.
    // Rendered BELOW particles, ABOVE the radial glow & diagonal lines,
    // so the field of dots layers on top of the moving light.
    _paintAurora(canvas, size, tAur);

    // ----- Layer 4a: blurred out-of-focus background particles.
    // Drawn first so the focused dots + falling lines sit IN FRONT.
    // Each blurred particle uses a fresh Paint() because MaskFilter
    // can vary per-particle (sigma differs) and re-using the same
    // Paint would force every dot to share the same blur.
    final double tPart2pi = tPart * 2 * math.pi;
    for (int i = 0; i < blurredParticles.length; i++) {
      final _BlurredParticle bp = blurredParticles[i];
      final double dx = bp.ampX * math.sin(tPart2pi * bp.periodX + bp.phaseX);
      final double dy = bp.ampY * math.cos(tPart2pi * bp.periodY + bp.phaseY);
      final double x = (bp.baseX + dx) * size.width + windX + parX;
      final double y = (bp.baseY + dy) * size.height + windY + parY;
      final Paint blurPaint = Paint()
        ..color = pale.withValues(alpha: bp.alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, bp.blurSigma);
      canvas.drawCircle(
          Offset(x, y), bp.radius * math.min(sx, sy), blurPaint);
    }

    // ----- Layer 4b: 120 drifting focused particles (twinklers
    //                  modulate alpha against a 1.5–3.5 s sinusoid).
    //
    // Build an index→twinkle-alpha-multiplier table. Time source is the
    // 1 s _ping controller wrapped into a long-running clock: every
    // 60 Hz tick advances tSec by ~1/60. Falling back on
    // DateTime.now() (in seconds, fractional) ensures the twinkle
    // period stays stable across rebuilds.
    final double tSec = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final Map<int, double> twkAlpha = <int, double>{};
    for (final _Twinkler t in twinklers) {
      final double s = math.sin(tSec * 2 * math.pi / t.period + t.phase);
      twkAlpha[t.index] = 0.4 + 0.6 * (0.5 + 0.5 * s);
    }

    for (int i = 0; i < particles.length; i++) {
      final _Particle p = particles[i];
      final double dx = p.ampX * math.sin(tPart2pi * p.periodX + p.phaseX);
      final double dy = p.ampY * math.cos(tPart2pi * p.periodY + p.phaseY);
      final double x = (p.baseX + dx) * size.width + windX + parX;
      final double y = (p.baseY + dy) * size.height + windY + parY;
      final double alpha =
          (p.alpha * (twkAlpha[i] ?? 1.0)).clamp(0.0, 1.0);
      _fillPaint.color = pale.withValues(alpha: alpha);
      canvas.drawCircle(
          Offset(x, y), p.radius * math.min(sx, sy), _fillPaint);
    }

    // ----- Layer 4c: falling vertical hairlines.
    // Each line uses the dedicated _fallingLines controller (linear
    // loop, 45 s) — tFall ∈ [0,1] over one cycle, multiplied by each
    // line's fallSpeed to give per-line traversal times. y is wrapped
    // by modulo so the wrap teleports the line back above the cover
    // off-screen (length px above the top); no visible 1.0 → 0.0 snap.
    //
    // Wind is applied as a sideways translate (full windX), but the
    // ±12 px Y wind is omitted so the rain still reads as falling
    // straight down.
    for (int i = 0; i < fallingLines.length; i++) {
      final _FallingLine fl = fallingLines[i];
      final double lineLen = fl.length * sy;
      final double range = size.height + lineLen;
      final double yTop =
          ((fl.baseTopY + tFall * fl.fallSpeed) % 1.0) * range - lineLen;
      final double xPx = fl.x * size.width + windX + parX;
      final Paint linePaint = Paint()
        ..color = pale.withValues(alpha: fl.alpha)
        ..strokeWidth = fl.strokeWidth * math.min(sx, sy)
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(xPx, yTop),
        Offset(xPx, yTop + lineLen),
        linePaint,
      );
    }

    // ----- Layer 4d: radar pings (expanding-ring fades) ---------------
    _paintPings(canvas, size);

    // ----- Layer 5: category-driven illustration.
    // Inverse-direction parallax (max ±6 px) for fake-depth: the focal
    // shape shifts AGAINST the cursor while the particle field shifts
    // WITH it, the way a window-display works.
    canvas.save();
    canvas.translate(cursor.dx * -6.0, cursor.dy * -6.0);
    _dispatchIllustration(_pickIllustrationKey(category),
        canvas, size, sx, sy, pale, accent, tIll);
    canvas.restore();

    // ----- Layer 6: vignette (last so it darkens everything).
    final double vigStrength = 0.55 + 0.12 * tVig;
    final ui.Gradient vigGrad = ui.Gradient.radial(
      Offset(size.width / 2, size.height / 2),
      math.sqrt(size.width * size.width + size.height * size.height) / 1.7,
      <Color>[
        const Color(0x00000000),
        const Color(0x00000000),
        Color.fromARGB((vigStrength * 255).toInt(), 0, 0, 0),
      ],
      <double>[0.0, 0.55, 1.0],
    );
    canvas.drawRect(rect, Paint()..shader = vigGrad);
  }

  /// Paints the slow diagonal aurora sweep. The band travels along its
  /// perpendicular axis from off-screen left to off-screen right over a
  /// 30 s eased cycle, then sits invisibly past the right edge for the
  /// last 10% of the cycle so the wrap-to-zero is undetectable.
  void _paintAurora(Canvas canvas, Size size, double t) {
    // 35° from vertical (i.e. 55° from horizontal) — a soft tilt.
    const double angleDeg = 35.0;
    final double angleRad = angleDeg * math.pi / 180.0;
    // Sweep progress: 0..1 maps to the band's center traveling across
    // the perpendicular axis. We squash t to [0,1] over the first 90%
    // of the controller and pin to 1.0 (off-screen-right) for the last
    // 10% — masks the teleport.
    double sweep;
    if (t < 0.9) {
      sweep = Curves.easeInOutSine.transform(t / 0.9);
    } else {
      sweep = 1.05; // safely past the right edge
    }
    // Map sweep [0,1] to perpendicular position: -0.5 (off-screen left)
    // to +1.5 (off-screen right) of the cover.
    final double perp = -0.5 + sweep * 2.0;

    // The band is a wide diagonal strip. We draw a single rect with a
    // perpendicular gradient (low-alpha primary at center, transparent
    // edges), rotated into place.
    canvas.save();
    final Offset center = Offset(size.width / 2, size.height / 2);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angleRad);
    // Band thickness: ~22% of the cover's longest dimension. Length:
    // 2.4× longest dimension to guarantee the gradient edges stay off
    // the visible rect even after rotation.
    final double longest = math.max(size.width, size.height);
    final double bandThickness = longest * 0.22;
    final double bandLength = longest * 2.4;
    // Center offset along perpendicular axis (x in the rotated frame).
    final double cx = (perp - 0.5) * size.width;
    final Rect bandRect = Rect.fromCenter(
      center: Offset(cx, 0),
      width: bandThickness,
      height: bandLength,
    );
    final ui.Gradient bandGrad = ui.Gradient.linear(
      Offset(bandRect.left, 0),
      Offset(bandRect.right, 0),
      <Color>[
        accent.withValues(alpha: 0.0),
        accent.withValues(alpha: 0.06), // peak alpha — barely a tint
        accent.withValues(alpha: 0.0),
      ],
      <double>[0.0, 0.5, 1.0],
    );
    canvas.drawRect(bandRect, Paint()..shader = bandGrad);
    canvas.restore();
  }

  /// Draws all active radar pings. Each ping has an 800 ms lifecycle:
  /// expanding from 0 → maxRadius while alpha fades 0.30 → 0. Expired
  /// pings are culled in-place from the shared list.
  void _paintPings(Canvas canvas, Size size) {
    if (pings.isEmpty) return;
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    // Cull expired pings (iterate backwards so removals don't shift
    // the rest of the indices we still need to visit).
    for (int i = pings.length - 1; i >= 0; i--) {
      final _RadarPing p = pings[i];
      final double t = (nowMs - p.startMs) / 800.0;
      if (t >= 1.0) {
        pings.removeAt(i);
      }
    }
    final Paint pingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final _RadarPing p in pings) {
      final double t = (nowMs - p.startMs) / 800.0;
      if (t < 0 || t >= 1.0) continue;
      final Offset origin = Offset(
        p.originX * size.width,
        p.originY * size.height,
      );
      final double radius = t * p.maxRadius;
      pingPaint.color = accent.withValues(alpha: (1.0 - t) * 0.30);
      canvas.drawCircle(origin, radius, pingPaint);
    }
  }

  /// Maps a project category string to the matching illustration key.
  /// Mirrors the `ILLUSTRATIONS` token-match table in
  /// `tools/gen_covers.py`; falls back to `'constellation'` when no
  /// tokens overlap, exactly like the Python `if fn is None`.
  String _pickIllustrationKey(String cat) {
    final Set<String> tokens = _categoryTokens(cat);
    for (final _IllustrationEntry e in _illustrationTable) {
      if (tokens.intersection(e.keys).isNotEmpty) return e.key;
    }
    return 'constellation';
  }

  void _dispatchIllustration(String key, Canvas c, Size sz, double sx,
      double sy, Color b, Color a, double t) {
    switch (key) {
      case 'constellation':
        _paintConstellation(c, sz, sx, sy, b, a, t);
        break;
      case 'orbitingCircles':
        _paintOrbitingCircles(c, sz, sx, sy, b, a, t);
        break;
      case 'monumentalBlock':
        _paintMonumentalBlock(c, sz, sx, sy, b, a, t);
        break;
      case 'buildingSilhouette':
        _paintBuildingSilhouette(c, sz, sx, sy, b, a, t);
        break;
      case 'stackedStrata':
        _paintStackedStrata(c, sz, sx, sy, b, a, t);
        break;
      case 'foldedPaper':
        _paintFoldedPaper(c, sz, sx, sy, b, a, t);
        break;
      case 'machinedComponent':
        _paintMachinedComponent(c, sz, sx, sy, b, a, t);
        break;
      case 'stage':
        _paintStage(c, sz, sx, sy, b, a, t);
        break;
      case 'gameArc':
        _paintGameArc(c, sz, sx, sy, b, a, t);
        break;
      case 'strataLines':
        _paintStrataLines(c, sz, sx, sy, b, a, t);
        break;
      case 'sparseNetwork':
        _paintSparseNetwork(c, sz, sx, sy, b, a, t);
        break;
      case 'orbitalToken':
        _paintOrbitalToken(c, sz, sx, sy, b, a, t);
        break;
      case 'voiceWave':
        _paintVoiceWave(c, sz, sx, sy, b, a, t);
        break;
      case 'packageCube':
        _paintPackageCube(c, sz, sx, sy, b, a, t);
        break;
      case 'mobileOutline':
        _paintMobileOutline(c, sz, sx, sy, b, a, t);
        break;
      case 'webWindow':
        _paintWebWindow(c, sz, sx, sy, b, a, t);
        break;
      case 'diagonalLine':
        _paintDiagonalLine(c, sz, sx, sy, b, a, t);
        break;
      default:
        _paintConstellation(c, sz, sx, sy, b, a, t);
    }
  }

  Set<String> _categoryTokens(String cat) {
    final RegExp pat = RegExp(r'[A-Z0-9][A-Z0-9.\-]*');
    return pat
        .allMatches(cat.toUpperCase())
        .map((Match m) => m.group(0)!)
        .toSet();
  }

  // ============= Illustration paints =====================================
  //
  // Every illustration draws in 1600x900 reference coordinates scaled
  // by (sx, sy). Each one reads `t` (∈ [0,1]) from the shared
  // _illustration controller and derives per-element animation values
  // via cheap trig so the painter has no per-frame allocations.

  void _paintConstellation(Canvas c, Size sz, double sx, double sy,
      Color baseC, Color accentC, double t) {
    // Pre-seeded scatter to keep dot positions stable (matches Python
    // `random.Random(1)` inside draw_constellation).
    final math.Random rng = math.Random(1);
    final double cx = 1200 * sx;
    final double cy = 360 * sy;
    final List<Offset> points = <Offset>[];
    final double t2pi = t * 2 * math.pi;
    // Scatter spread widened by _illMul (561,361 → ~954,613) so the
    // constellation occupies the upper-right quadrant rather than a
    // tight cluster, and per-dot radii bumped 3 → 5 so the nodes
    // read at viewport sizes.
    final int spreadX = (561 * _illMul).round();
    final int spreadY = (361 * _illMul).round();
    final int halfX = (spreadX / 2).round();
    final int halfY = (spreadY / 2).round();
    for (int i = 0; i < 13; i++) {
      final double bx = cx + (rng.nextInt(spreadX) - halfX) * sx;
      final double by = cy + (rng.nextInt(spreadY) - halfY) * sy;
      // Per-dot Lissajous drift (±5-7 px), independent phase.
      final double dx = (5.0 + (i % 3) * 1.5) *
          sx *
          math.sin(t2pi * (0.7 + i * 0.11) + i * 0.37);
      final double dy = (5.0 + (i % 4) * 1.2) *
          sy *
          math.cos(t2pi * (0.6 + i * 0.09) + i * 0.41);
      final Offset p = Offset(bx + dx, by + dy);
      points.add(p);
      _fillPaint.color = baseC.withValues(alpha: 0.59);
      c.drawCircle(p, 5 * sx, _fillPaint);
    }
    // Connecting line — alpha breathes with the t-driven sin.
    // Per-element phase 0.83 so this isn't at t=0 when the global
    // controller bounces past 0 / 1.
    final Offset focal = points[3];
    final Offset target = points[8];
    final double lineAlpha =
        0.32 + 0.22 * (0.5 + 0.5 * math.sin(t2pi * 0.67 + 0.83));
    _strokePaint
      ..color = accentC.withValues(alpha: lineAlpha)
      ..strokeWidth = 2.5;
    c.drawLine(focal, target, _strokePaint);
    _fillPaint.color = accentC.withValues(alpha: 0.86);
    final double focalR =
        9 * _illMul * sx * (1.0 + 0.10 * math.sin(t2pi * 0.67 + 1.2));
    c.drawCircle(focal, focalR, _fillPaint);
  }

  void _paintOrbitingCircles(Canvas c, Size sz, double sx, double sy,
      Color baseC, Color accentC, double t) {
    final double cx = 1200 * sx;
    final double cy = 360 * sy;
    final double t2pi = t * 2 * math.pi;
    // Radii scaled ×_illMul (1.7) so the outermost orbit reaches ~510 px
    // of the 1600 px reference — the rings now read as the dominant
    // compositional element instead of crowding the right edge.
    final List<double> radii = <double>[
      160 * _illMul,
      220 * _illMul,
      300 * _illMul,
    ];
    final List<double> speeds = <double>[0.6, 0.42, 0.26];
    for (int i = 0; i < radii.length; i++) {
      _strokePaint
        ..color = baseC.withValues(alpha: 0.31 + 0.12 * i.toDouble())
        ..strokeWidth = 2.5;
      final double r = radii[i] * sx;
      // Each ring rotates at a different speed → draw as a circle with
      // a small accent arc that rotates around its perimeter.
      c.drawCircle(Offset(cx, cy), r, _strokePaint);
      final double a = t2pi * speeds[i] + i * 0.9;
      final Offset orbiter = Offset(cx + r * math.cos(a), cy + r * math.sin(a));
      _fillPaint.color = accentC.withValues(alpha: 0.55);
      c.drawCircle(orbiter, 7 * sx, _fillPaint);
    }
    // Central token — gentle scale pulse. Radius bumped 60 → 60×_illMul.
    final double pulse = 1.0 + 0.06 * math.sin(t2pi * 0.7);
    _fillPaint.color = accentC.withValues(alpha: 0.78);
    c.drawCircle(Offset(cx, cy), 60 * _illMul * sx * pulse, _fillPaint);
  }

  void _paintMonumentalBlock(Canvas c, Size sz, double sx, double sy,
      Color baseC, Color accentC, double t) {
    final double t2pi = t * 2 * math.pi;
    // Per-element phase 0.41 so the block dx never lands at zero
    // when the global controller bounces past 0 / 1.
    final double dx = 3 * sx * math.sin(t2pi * 0.67 + 0.41);
    // Block bounds expanded so the slab dominates the upper-right
    // quadrant: was (980→1480, 130→580) — now extended leftward and
    // taller to give the cover a clear monumental focal mass.
    final Rect rect = Rect.fromLTRB(
      720 * sx + dx, 70 * sy, 1530 * sx + dx, 680 * sy,
    );
    _fillPaint.color = baseC.withValues(alpha: 0.12);
    c.drawRect(rect, _fillPaint);
    _strokePaint
      ..color = baseC.withValues(alpha: 0.47)
      ..strokeWidth = 2.0;
    c.drawRect(rect, _strokePaint);
    // Vertical accent line on right edge, alpha breathes.
    final double laAlpha = 0.65 + 0.20 * math.sin(t2pi + 1.1);
    _strokePaint
      ..color = accentC.withValues(alpha: laAlpha)
      ..strokeWidth = 4.0;
    c.drawLine(
      Offset(rect.right - 6 * sx, rect.top),
      Offset(rect.right - 6 * sx, rect.bottom),
      _strokePaint,
    );
    // Horizontal striations breathing alpha independently.
    for (int i = 0; i < 7; i++) {
      final double y = rect.top + (i + 1) * (rect.height / 8);
      final double a = 0.10 +
          0.10 * (0.5 + 0.5 * math.sin(t2pi * (0.6 + i * 0.13) + i * 0.7));
      _strokePaint
        ..color = baseC.withValues(alpha: a)
        ..strokeWidth = 1.0;
      c.drawLine(Offset(rect.left, y), Offset(rect.right, y), _strokePaint);
    }
  }

  void _paintBuildingSilhouette(Canvas c, Size sz, double sx, double sy,
      Color baseC, Color accentC, double t) {
    final double t2pi = t * 2 * math.pi;
    // Façade widened (1080→1340 → 980→1500) and slightly taller so the
    // building reads as a prominent silhouette, not a thin slab.
    final Rect outer = Rect.fromLTRB(
      980 * sx, 50 * sy, 1500 * sx, 700 * sy,
    );
    _strokePaint
      ..color = baseC.withValues(alpha: 0.47)
      ..strokeWidth = 2.0;
    c.drawRect(outer, _strokePaint);
    // A grid of windows, each pulsing on its own period.
    const int cols = 3;
    const int rows = 8;
    final double cellW = outer.width / (cols + 1);
    final double cellH = outer.height / (rows + 1);
    for (int r = 0; r < rows; r++) {
      for (int col = 0; col < cols; col++) {
        final double cxw = outer.left + (col + 0.5) * cellW + cellW * 0.25;
        final double cyw = outer.top + (r + 0.5) * cellH + cellH * 0.1;
        final double phase = (r * 0.31 + col * 0.47);
        final double period = 0.4 + ((r + col) % 5) * 0.18;
        final double a = 0.15 +
            0.50 *
                (0.5 +
                    0.5 *
                        math.sin(t2pi * period + phase));
        _fillPaint.color = accentC.withValues(alpha: a);
        c.drawRect(
          Rect.fromLTWH(cxw, cyw, cellW * 0.45, cellH * 0.45),
          _fillPaint,
        );
      }
    }
    // The big lit window in accent. Per-element phase 1.93 so the
    // window's pulse never lands on the global zero-crossing.
    final double bigA = 0.78 + 0.14 * math.sin(t2pi * 0.33 + 1.93);
    _fillPaint.color = accentC.withValues(alpha: bigA);
    c.drawRect(
      Rect.fromLTWH(
          outer.left + 80 * sx, outer.top + 380 * sy, 90 * sx, 90 * sy),
      _fillPaint,
    );
  }

  void _paintStackedStrata(Canvas c, Size sz, double sx, double sy,
      Color baseC, Color accentC, double t) {
    final double t2pi = t * 2 * math.pi;
    // Bars stretched leftward and taller so the stacked strata
    // occupies a much bigger swath of the upper-right quadrant. Was
    // 520 wide × 50 tall — now ~820 wide × 70 tall, three layers
    // spread across more vertical space.
    final List<List<double>> bars = <List<double>>[
      <double>[700, 180, 1530, 250],
      <double>[680, 320, 1510, 390],
      <double>[660, 460, 1490, 530],
    ];
    for (int i = 0; i < bars.length; i++) {
      final List<double> b = bars[i];
      final double phase = i * 0.7;
      // Each bar's width breathes ±8%.
      final double widthMul =
          1.0 + 0.08 * math.sin(t2pi * (0.6 + i * 0.18) + phase);
      final double cx = (b[0] + b[2]) / 2 * sx;
      final double halfW = ((b[2] - b[0]) / 2) * sx * widthMul;
      final Rect r = Rect.fromLTRB(
        cx - halfW,
        b[1] * sy,
        cx + halfW,
        b[3] * sy,
      );
      if (i == 0) {
        _fillPaint.color = accentC.withValues(alpha: 0.78);
        c.drawRect(r, _fillPaint);
      } else {
        _strokePaint
          ..color = baseC.withValues(alpha: 0.43)
          ..strokeWidth = 2.0;
        c.drawRect(r, _strokePaint);
      }
    }
  }

  void _paintFoldedPaper(Canvas c, Size sz, double sx, double sy,
      Color baseC, Color accentC, double t) {
    final double t2pi = t * 2 * math.pi;
    // Per-fold ±1.5° rotation about the hinge. Periods slowed to
    // 0.46 / 0.33 (×~0.66) and phase 1.27 added to rot1 so the two
    // folds never both hit zero together.
    final double rot1 = 0.025 * math.sin(t2pi * 0.46 + 1.27);
    final double rot2 = 0.025 * math.cos(t2pi * 0.33 + 0.6);
    _strokePaint
      ..color = baseC.withValues(alpha: 0.51)
      ..strokeWidth = 2.0;
    // Sheets enlarged ~1.4× (500 → 700 wide, 400 → 600 tall) so the
    // overlapping paper rectangles fill the focal area.
    _paintRotatedRect(
      c,
      Rect.fromLTRB(740 * sx, 70 * sy, 1440 * sx, 670 * sy),
      rot1,
      _strokePaint,
    );
    _paintRotatedRect(
      c,
      Rect.fromLTRB(820 * sx, 140 * sy, 1520 * sx, 740 * sy),
      rot2,
      _strokePaint,
    );
    // Diagonal crease — alpha breathes. Phase 0.74 keeps it off the
    // global zero-crossing.
    final double creaseA = 0.78 + 0.12 * math.sin(t2pi * 0.67 + 0.74);
    _strokePaint
      ..color = accentC.withValues(alpha: creaseA)
      ..strokeWidth = 3.5;
    c.drawLine(
      Offset(740 * sx, 670 * sy),
      Offset(1520 * sx, 140 * sy),
      _strokePaint,
    );
  }

  void _paintRotatedRect(Canvas c, Rect rect, double rot, Paint p) {
    final Offset center = rect.center;
    c.save();
    c.translate(center.dx, center.dy);
    c.rotate(rot);
    c.translate(-center.dx, -center.dy);
    c.drawRect(rect, p);
    c.restore();
  }

  void _paintMachinedComponent(Canvas c, Size sz, double sx, double sy,
      Color baseC, Color accentC, double t) {
    final double t2pi = t * 2 * math.pi;
    final Offset center = Offset(1200 * sx, 320 * sy);
    // Outer ring radius scaled ×_illMul (120 → 204) so the wheel reads
    // as a major shape rather than a small badge near the corner.
    final double outerR = 120 * _illMul * sx;
    final double pulse = 1.0 + 0.03 * math.sin(t2pi * 0.6);
    _strokePaint
      ..color = baseC.withValues(alpha: 0.51)
      ..strokeWidth = 3.5;
    c.drawCircle(center, outerR * pulse, _strokePaint);
    // Inner radial spokes, rotating. Spoke endpoints scaled ×_illMul
    // so the spoke fan fills the larger ring.
    final double rot = t2pi * 0.17;
    const int spokes = 8;
    _strokePaint.strokeWidth = 2.5;
    for (int i = 0; i < spokes; i++) {
      final double a = rot + i * (2 * math.pi / spokes);
      final Offset p1 = center +
          Offset(math.cos(a) * 40 * _illMul * sx,
              math.sin(a) * 40 * _illMul * sy);
      final Offset p2 = center +
          Offset(math.cos(a) * 100 * _illMul * sx,
              math.sin(a) * 100 * _illMul * sy);
      c.drawLine(p1, p2, _strokePaint);
    }
    // Accent square offset to the lower right. Edge scaled ×_illMul.
    final double sqPulse = 1.0 + 0.05 * math.sin(t2pi * 0.9 + 1.4);
    final double sqSize = 70 * _illMul * sx * sqPulse;
    _fillPaint.color = accentC.withValues(alpha: 0.78);
    c.drawRect(
      Rect.fromCenter(
        center: Offset(1410 * sx, 450 * sy),
        width: sqSize,
        height: sqSize,
      ),
      _fillPaint,
    );
  }

  void _paintStage(Canvas c, Size sz, double sx, double sy,
      Color baseC, Color accentC, double t) {
    final double t2pi = t * 2 * math.pi;
    final Offset center = Offset(1280 * sx, 440 * sy);
    // Outer ring (accent), middle ring (base), pulsing.
    final double a1 = 0.51 + 0.12 * math.sin(t2pi * 0.6);
    final double a2 = 0.35 + 0.10 * math.sin(t2pi * 0.9 + 0.4);
    _strokePaint
      ..color = accentC.withValues(alpha: a1)
      ..strokeWidth = 3.5;
    // Stage rings scaled ×_illMul so the concentric halos read as a
    // major staged composition rather than a small badge.
    c.drawCircle(center, 170 * _illMul * sx * (1.0 + 0.03 * math.sin(t2pi)),
        _strokePaint);
    _strokePaint.color = baseC.withValues(alpha: a2);
    c.drawCircle(center,
        130 * _illMul * sx * (1.0 + 0.04 * math.cos(t2pi * 0.7)), _strokePaint);
    // Central token + accent pulse halo. Token radius bumped.
    final double tokR = 24 * _illMul * sx * (1.0 + 0.10 * math.sin(t2pi * 1.1));
    _fillPaint.color = accentC.withValues(alpha: 0.86);
    c.drawCircle(center, tokR, _fillPaint);
    // Perspective curtain lines.
    _strokePaint
      ..color = baseC.withValues(alpha: 0.25)
      ..strokeWidth = 1.0;
    for (int i = 0; i < 6; i++) {
      final double a = (i / 5.0) * math.pi + math.pi * 0.5;
      final double r1 = 200 * sx;
      final double r2 = 280 * sx;
      final Offset p1 = center + Offset(math.cos(a) * r1, math.sin(a) * r1 * 0.7);
      final Offset p2 = center +
          Offset(math.cos(a) * r2, math.sin(a) * r2 * 0.7 +
              (2 * sy * math.sin(t2pi + i * 0.6)));
      c.drawLine(p1, p2, _strokePaint);
    }
  }

  void _paintGameArc(Canvas c, Size sz, double sx, double sy,
      Color baseC, Color accentC, double t) {
    final double t2pi = t * 2 * math.pi;
    // The triangular arc, fill + outline. Per-element phase 1.07 so
    // the apex y-pulse never lands at zero on the global wrap.
    final double yPulse = 4 * sy * math.sin(t2pi * 0.67 + 1.07);
    // Triangular arc enlarged ~1.6× across both axes so it dominates
    // the focal area instead of sitting as a tiny pennant.
    final Path path = Path()
      ..moveTo(880 * sx, 680 * sy)
      ..lineTo(1240 * sx, 100 * sy + yPulse)
      ..lineTo(1500 * sx, 680 * sy)
      ..close();
    _fillPaint.color = accentC.withValues(alpha: 0.18);
    c.drawPath(path, _fillPaint);
    _strokePaint
      ..color = baseC.withValues(alpha: 0.51)
      ..strokeWidth = 2.0;
    c.drawPath(path, _strokePaint);
    // Baseline rule. Phase 2.31 keeps the pulse off the global wrap.
    _strokePaint
      ..color = accentC.withValues(
          alpha: 0.78 + 0.14 * math.sin(t2pi * 0.46 + 2.31))
      ..strokeWidth = 5.0;
    c.drawLine(Offset(880 * sx, 680 * sy), Offset(1500 * sx, 680 * sy),
        _strokePaint);
    // Scattered tokens drifting on Lissajous.
    for (int i = 0; i < 5; i++) {
      final double bx = (1180 + i * 50) * sx;
      final double by = (480 - (i % 3) * 25) * sy;
      final double dx = 6 * sx * math.sin(t2pi * (0.5 + i * 0.18) + i * 0.5);
      final double dy = 5 * sy * math.cos(t2pi * (0.4 + i * 0.21) + i * 0.7);
      _fillPaint.color = accentC.withValues(alpha: 0.59);
      c.drawCircle(Offset(bx + dx, by + dy), 4 * sx, _fillPaint);
    }
  }

  void _paintStrataLines(Canvas c, Size sz, double sx, double sy,
      Color baseC, Color accentC, double t) {
    final double t2pi = t * 2 * math.pi;
    // Strata stretched and spread vertically so the three lines fill
    // the focal area like a real strata diagram (was 220/320/420 over
    // 520 wide; now 160/360/620 spread across the full height with
    // 820 px width — feels architectural rather than tooltip-sized).
    final List<double> ys = <double>[160, 360, 620];
    for (int i = 0; i < ys.length; i++) {
      final double y = ys[i] * sy;
      final double x0 = (700 + i * 30) * sx;
      final double x1 = 1520 * sx;
      // Per-stripe translateX.
      final double dx = 6 * sx * math.sin(t2pi * (0.5 + i * 0.2) + i * 0.9);
      if (i == 0) {
        _fillPaint.color = accentC.withValues(alpha: 0.86);
        c.drawRect(Rect.fromLTWH(x0 + dx, y, x1 - x0, 10 * sy), _fillPaint);
      } else {
        _strokePaint
          ..color = baseC.withValues(alpha: 0.47)
          ..strokeWidth = 3.0;
        c.drawLine(Offset(x0 + dx, y + 5 * sy),
            Offset(x1 + dx, y + 5 * sy), _strokePaint);
      }
    }
    // Extra texture: a few short tick marks pulsing along the leading edge.
    for (int i = 0; i < 8; i++) {
      final double xy = (980 + i * 60) * sx;
      final double a = 0.15 + 0.45 *
          (0.5 + 0.5 * math.sin(t2pi * (0.4 + i * 0.13) + i * 0.7));
      _strokePaint
        ..color = baseC.withValues(alpha: a)
        ..strokeWidth = 1.5;
      c.drawLine(Offset(xy, 480 * sy), Offset(xy, 510 * sy), _strokePaint);
    }
  }

  void _paintSparseNetwork(Canvas c, Size sz, double sx, double sy,
      Color baseC, Color accentC, double t) {
    final double t2pi = t * 2 * math.pi;
    // Network nodes spread across a much wider region so the graph
    // reads as the focal element rather than a small cluster.
    final List<Offset> nodes = <Offset>[
      Offset(780 * sx, 140 * sy),
      Offset(1500 * sx, 240 * sy),
      Offset(960 * sx, 600 * sy),
      Offset(1490 * sx, 640 * sy),
    ];
    // Each node breathes scale; each edge alpha pulses.
    final List<List<int>> edges = <List<int>>[
      <int>[0, 1],
      <int>[1, 3],
      <int>[0, 2],
      <int>[2, 3],
    ];
    for (int i = 0; i < edges.length; i++) {
      final List<int> e = edges[i];
      final double a = 0.18 +
          0.30 *
              (0.5 +
                  0.5 * math.sin(t2pi * (0.5 + i * 0.21) + i * 0.7));
      _strokePaint
        ..color = baseC.withValues(alpha: a)
        ..strokeWidth = 1.0;
      c.drawLine(nodes[e[0]], nodes[e[1]], _strokePaint);
    }
    // Nodes — outline rings.
    _strokePaint
      ..color = baseC.withValues(alpha: 0.63)
      ..strokeWidth = 2.5;
    for (int i = 0; i < nodes.length; i++) {
      final double pulse = 1.0 + 0.10 * math.sin(t2pi * (0.6 + i * 0.15) + i);
      // Node radii bumped 6 → 14 px so the graph nodes register at
      // typical viewport sizes.
      c.drawCircle(nodes[i], 14 * sx * pulse, _strokePaint);
    }
    // First node — filled accent. Radius bumped 10 → 22 px.
    final double pulse0 = 1.0 + 0.12 * math.sin(t2pi * 0.5);
    _fillPaint.color = accentC.withValues(alpha: 0.86);
    c.drawCircle(nodes[0], 22 * sx * pulse0, _fillPaint);
  }

  void _paintOrbitalToken(Canvas c, Size sz, double sx, double sy,
      Color baseC, Color accentC, double t) {
    final double t2pi = t * 2 * math.pi;
    final Offset center = Offset(1240 * sx, 360 * sy);
    // Outer orbit ring — alpha breathes. Phase 1.48 keeps it off the
    // wrap point. Radius ×_illMul so the orbit dominates the corner.
    final double ringA = 0.55 + 0.15 * math.sin(t2pi * 0.67 + 1.48);
    _strokePaint
      ..color = accentC.withValues(alpha: ringA)
      ..strokeWidth = 3.5;
    final double outerR = 240 * _illMul * sx;
    final double innerR = 180 * _illMul * sx;
    c.drawCircle(center, outerR, _strokePaint);
    // Two moons orbiting at different periods.
    final double a1 = t2pi * 0.35;
    final double a2 = -t2pi * 0.48 + 1.6;
    final Offset m1 = center + Offset(math.cos(a1) * outerR, math.sin(a1) * outerR);
    final Offset m2 = center + Offset(math.cos(a2) * innerR, math.sin(a2) * innerR);
    _fillPaint.color = accentC.withValues(alpha: 0.78);
    c.drawCircle(m1, 10 * sx, _fillPaint);
    _fillPaint.color = baseC.withValues(alpha: 0.65);
    c.drawCircle(m2, 7 * sx, _fillPaint);
    // Central token scale-pulses. Radius ×_illMul.
    final double tokR = 60 * _illMul * sx * (1.0 + 0.08 * math.sin(t2pi * 0.7));
    _fillPaint.color = baseC.withValues(alpha: 0.70);
    c.drawCircle(center, tokR, _fillPaint);
  }

  void _paintVoiceWave(Canvas c, Size sz, double sx, double sy,
      Color baseC, Color accentC, double t) {
    final double t2pi = t * 2 * math.pi;
    final double y = 360 * sy;
    // Baseline + 30 bars — band stretched 980→1480 → 700→1520 so the
    // waveform spans the focal area instead of clinging to the corner.
    _strokePaint
      ..color = baseC.withValues(alpha: 0.51)
      ..strokeWidth = 3.0;
    c.drawLine(Offset(700 * sx, y), Offset(1520 * sx, y), _strokePaint);
    // 30 vertical waveform bars.
    const int bars = 30;
    final double x0 = 700 * sx;
    final double x1 = 1520 * sx;
    final double step = (x1 - x0) / (bars - 1);
    for (int i = 0; i < bars; i++) {
      final double xi = x0 + i * step;
      final double phase = i * 0.45;
      // Composite sine — feels like real audio waveform with peaks
      // and troughs walking across the band.
      // Bar height envelope bumped 60 → 140 px so the peaks feel like
      // a real audio meter rather than a thin strip.
      final double h = (140 * sy) *
          (0.20 +
              0.80 *
                  (0.5 +
                      0.5 *
                          math.sin(t2pi * (1.0 + (i % 5) * 0.15) + phase)));
      final bool accentBar = i >= bars - 8;
      _strokePaint
        ..color = (accentBar ? accentC : baseC).withValues(alpha: 0.78)
        ..strokeWidth = 4.0;
      c.drawLine(Offset(xi, y - h / 2), Offset(xi, y + h / 2), _strokePaint);
    }
  }

  void _paintPackageCube(Canvas c, Size sz, double sx, double sy,
      Color baseC, Color accentC, double t) {
    final double t2pi = t * 2 * math.pi;
    final double cx = 1240 * sx;
    final double cy = 360 * sy;
    // Cube edge scaled ×_illMul (130 → 221) so the isometric cube
    // reads as a clear focal solid instead of a thumbprint.
    final double s = 130 * _illMul * sx;
    // Simulate slow rotation around vertical axis by skewing the top
    // face's perspective offset.
    // Periods slowed (×~0.66) and per-element phases so the cube
    // never aligns with the global wrap.
    final double skew = math.sin(t2pi * 0.33 + 0.53) * 0.18;
    final double sH = s * 0.5 + s * 0.10 * math.sin(t2pi * 0.46 + 1.17);
    final Path top = Path()
      ..moveTo(cx + skew * s, cy - s)
      ..lineTo(cx + s, cy - sH)
      ..lineTo(cx + skew * s, cy)
      ..lineTo(cx - s, cy - sH)
      ..close();
    _fillPaint.color = accentC.withValues(alpha: 0.31);
    c.drawPath(top, _fillPaint);
    _strokePaint
      ..color = baseC.withValues(alpha: 0.55)
      ..strokeWidth = 2.0;
    c.drawPath(top, _strokePaint);

    final Path left = Path()
      ..moveTo(cx - s, cy - sH)
      ..lineTo(cx + skew * s, cy)
      ..lineTo(cx + skew * s, cy + s)
      ..lineTo(cx - s, cy + sH)
      ..close();
    c.drawPath(left, _strokePaint);

    final Path right = Path()
      ..moveTo(cx + skew * s, cy)
      ..lineTo(cx + s, cy - sH)
      ..lineTo(cx + s, cy + sH)
      ..lineTo(cx + skew * s, cy + s)
      ..close();
    _fillPaint.color = accentC
        .withValues(alpha: 0.55 + 0.20 * math.sin(t2pi * 0.67 + 1.81));
    c.drawPath(right, _fillPaint);
    c.drawPath(right, _strokePaint);

    // Surface tick marks pulsing alpha on each face.
    _strokePaint.strokeWidth = 1.0;
    for (int i = 0; i < 4; i++) {
      final double a = 0.20 + 0.30 * (0.5 + 0.5 * math.sin(t2pi + i * 0.7));
      _strokePaint.color = baseC.withValues(alpha: a);
      c.drawLine(
        Offset(cx - s + i * (s / 2.5), cy - sH + 5 * sy),
        Offset(cx + skew * s - i * (s / 4), cy - 5 * sy),
        _strokePaint,
      );
    }
  }

  void _paintMobileOutline(Canvas c, Size sz, double sx, double sy,
      Color baseC, Color accentC, double t) {
    final double t2pi = t * 2 * math.pi;
    // Phone outline scaled up: 190×460 → 320×740, anchored at the
    // upper-right so the device reads as the dominant prop.
    final Rect outer = Rect.fromLTRB(
      1100 * sx, 50 * sy, 1420 * sx, 790 * sy,
    );
    final RRect rRect =
        RRect.fromRectAndRadius(outer, Radius.circular(24 * sx));
    _strokePaint
      ..color = baseC.withValues(alpha: 0.55)
      ..strokeWidth = 3.0;
    c.drawRRect(rRect, _strokePaint);
    // Content stripes that scroll vertically (very slow loop) inside
    // the phone outline, clipped to the rounded rect. Driven by the
    // dedicated continuous-loop `fallingLinesC` so the scroll never
    // reverses when the illustration controller bounces. Modulo math
    // hides the 1.0 → 0.0 wrap inside the phone's clip.
    c.save();
    c.clipRRect(rRect);
    final double tFall = fallingLinesC.value;
    final double scroll =
        (tFall * outer.height * 2) % (outer.height + 80 * sy);
    for (int i = 0; i < 10; i++) {
      final double y = outer.top - 60 * sy + i * 60 * sy + scroll - outer.height;
      final double a = 0.15 + 0.35 * (0.5 + 0.5 * math.sin(t2pi + i * 0.6));
      _fillPaint.color = baseC.withValues(alpha: a);
      c.drawRect(
        Rect.fromLTWH(outer.left + 16 * sx, y, outer.width - 32 * sx, 32 * sy),
        _fillPaint,
      );
    }
    // Top lit panel. Phase 0.92 to break alignment with the global wrap.
    _fillPaint.color = accentC.withValues(
        alpha: 0.78 + 0.12 * math.sin(t2pi * 0.46 + 0.92));
    c.drawRect(
      Rect.fromLTWH(
        outer.left + 50 * sx, outer.top + 60 * sy,
        90 * sx, 90 * sy,
      ),
      _fillPaint,
    );
    c.restore();
  }

  void _paintWebWindow(Canvas c, Size sz, double sx, double sy,
      Color baseC, Color accentC, double t) {
    final double t2pi = t * 2 * math.pi;
    // Window frame widened (500×400 → 820×640) so the browser-window
    // illustration fills the focal quadrant.
    final Rect outer = Rect.fromLTRB(
      700 * sx, 90 * sy, 1520 * sx, 730 * sy,
    );
    _strokePaint
      ..color = baseC.withValues(alpha: 0.51)
      ..strokeWidth = 2.0;
    c.drawRect(outer, _strokePaint);
    // Title bar.
    _strokePaint
      ..color = baseC.withValues(alpha: 0.35)
      ..strokeWidth = 1.0;
    c.drawLine(Offset(outer.left, outer.top + 32 * sy),
        Offset(outer.right, outer.top + 32 * sy), _strokePaint);
    // Three traffic-light dots.
    for (int i = 0; i < 3; i++) {
      _fillPaint.color = baseC.withValues(
          alpha: 0.40 + 0.30 * (0.5 + 0.5 * math.sin(t2pi + i * 1.0)));
      c.drawCircle(
        Offset(outer.left + 18 * sx + i * 20 * sx, outer.top + 16 * sy),
        5 * sx,
        _fillPaint,
      );
    }
    // Inner content blocks fading in/out on staggered timing.
    final List<Rect> blocks = <Rect>[
      Rect.fromLTWH(outer.left + 60 * sx, outer.top + 60 * sy, 120 * sx, 120 * sy),
      Rect.fromLTWH(outer.left + 200 * sx, outer.top + 60 * sy, 220 * sx, 40 * sy),
      Rect.fromLTWH(outer.left + 200 * sx, outer.top + 110 * sy, 220 * sx, 40 * sy),
      Rect.fromLTWH(outer.left + 200 * sx, outer.top + 160 * sy, 180 * sx, 40 * sy),
      Rect.fromLTWH(outer.left + 60 * sx, outer.top + 230 * sy, 380 * sx, 110 * sy),
    ];
    for (int i = 0; i < blocks.length; i++) {
      final double a = 0.20 + 0.60 *
          (0.5 + 0.5 * math.sin(t2pi * (0.4 + i * 0.15) + i * 1.1));
      _fillPaint.color = (i == 0 ? accentC : baseC).withValues(alpha: a);
      c.drawRect(blocks[i], _fillPaint);
    }
  }

  void _paintDiagonalLine(Canvas c, Size sz, double sx, double sy,
      Color baseC, Color accentC, double t) {
    final double t2pi = t * 2 * math.pi;
    // Main diagonal slash — stretches ±4% endpoint position.
    // Phase 1.63 + slower 0.67 multiplier so the stretch never lands
    // on zero when the global controller bounces.
    final double stretch = 0.04 * math.sin(t2pi * 0.67 + 1.63);
    _strokePaint
      ..color = accentC.withValues(alpha: 0.86)
      ..strokeWidth = 5.5;
    // Slash extended ~700→1530 horizontally with a steeper Y so it
    // reads as a bold confident slash across the focal area.
    c.drawLine(
      Offset(700 * sx * (1.0 - stretch), 720 * sy * (1.0 + stretch)),
      Offset(1530 * sx * (1.0 + stretch * 0.5), 100 * sy * (1.0 - stretch)),
      _strokePaint,
    );
    // Accent dots along the line, breathing alpha. Dot radius bumped
    // 5 → 9 px so the punctuation reads at viewport sizes.
    for (int i = 0; i < 6; i++) {
      final double tlin = i / 5.0;
      final double x = (700 + tlin * (1530 - 700)) * sx;
      final double y = (720 + tlin * (100 - 720)) * sy;
      final double a = 0.32 + 0.40 * (0.5 + 0.5 * math.sin(t2pi + i * 0.9));
      _fillPaint.color = baseC.withValues(alpha: a);
      c.drawCircle(Offset(x, y), 9 * sx, _fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeroCoverPainter old) {
    return old.base != base ||
        old.category != category ||
        old.cursor != cursor;
  }
}

class _IllustrationEntry {
  const _IllustrationEntry(this.keys, this.key);
  final Set<String> keys;
  final String key;
}

// Token-match table. Mirrors ILLUSTRATIONS in tools/gen_covers.py.
// First match wins. The `key` value is dispatched to the matching
// `_paintXxx` method via [_HeroCoverPainter._dispatchIllustration].
final List<_IllustrationEntry> _illustrationTable = <_IllustrationEntry>[
  _IllustrationEntry(<String>{'LEGAL', 'EVIDENCE'}, 'stackedStrata'),
  _IllustrationEntry(
      <String>{'DOCUMENTS', 'DOCUMENT', 'DOKUMENTE'}, 'foldedPaper'),
  _IllustrationEntry(
      <String>{'ROBOTICS', 'ROBOTIK', 'ROBOTIK-FORSCHUNG'},
      'machinedComponent'),
  _IllustrationEntry(<String>{'VR', 'HEALTHCARE', 'GESUNDHEIT'}, 'stage'),
  _IllustrationEntry(
      <String>{'GAME', 'UNREAL', 'ITCH.IO', 'SPIEL'}, 'gameArc'),
  _IllustrationEntry(
      <String>{'SELF-HOSTED', 'EDGE', 'IOT', 'INFRA', 'PROXMOX'},
      'monumentalBlock'),
  _IllustrationEntry(<String>{'KUBERNETES', 'CLOUD'}, 'orbitingCircles'),
  _IllustrationEntry(
      <String>{'3D', 'PROPERTY', 'REAL-ESTATE', 'PROPTECH'},
      'buildingSilhouette'),
  _IllustrationEntry(
      <String>{'SEARCH', 'RAG', 'VECTOR', 'SUCHE'}, 'constellation'),
  _IllustrationEntry(<String>{'VOICE', 'STT', 'TTS'}, 'voiceWave'),
  _IllustrationEntry(
      <String>{
        'E-COMMERCE',
        'COMMERCE',
        'PRINT-ON-DEMAND',
        'PACKAGE',
        'TOOL',
        'UTILITY',
      },
      'packageCube'),
  _IllustrationEntry(
      <String>{'SALES', 'OUTREACH', 'BROWSER', 'SCRAPING', 'VERTRIEB'},
      'sparseNetwork'),
  _IllustrationEntry(
      <String>{'WEB3', 'CHARITY', 'SPENDEN'}, 'orbitalToken'),
  _IllustrationEntry(<String>{'WEB'}, 'webWindow'),
  _IllustrationEntry(<String>{'DEVSECOPS'}, 'orbitingCircles'),
  _IllustrationEntry(
      <String>{
        'SAAS',
        'AI',
        'KI',
        'AUTOMATION',
        'B2B',
        'OPERATIONS',
        'OPS',
        'FINANCE',
        'FINANZEN',
        'CV',
        'VISION',
      },
      'strataLines'),
  _IllustrationEntry(<String>{'MOBILE', 'MOBIL'}, 'mobileOutline'),
  _IllustrationEntry(
      <String>{'META', 'PORTFOLIO', 'PERSONAL', 'PERSÖNLICH', 'IN-HOUSE'},
      'diagonalLine'),
];
