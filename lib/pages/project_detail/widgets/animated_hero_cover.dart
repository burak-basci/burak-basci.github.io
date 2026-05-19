import 'dart:math' as math;
import 'dart:ui' as ui;

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
  });

  final ProjectItemData project;
  final AppLang lang;

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

  late final List<_Particle> _particleTable;
  late final Listenable _ticker;

  @override
  void initState() {
    super.initState();
    _gradient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _particles = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    _illustration = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _vignette = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat(reverse: true);

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

    _ticker = Listenable.merge(<Listenable>[
      _gradient,
      _glow,
      _particles,
      _illustration,
      _vignette,
    ]);
  }

  @override
  void dispose() {
    _gradient.dispose();
    _glow.dispose();
    _particles.dispose();
    _illustration.dispose();
    _vignette.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color base = widget.project.primaryColor;
    return RepaintBoundary(
      child: CustomPaint(
        painter: _HeroCoverPainter(
          base: base,
          category: widget.project.categoryFor(widget.lang),
          particles: _particleTable,
          gradient: _gradient,
          glow: _glow,
          particlesC: _particles,
          illustration: _illustration,
          vignette: _vignette,
          repaint: _ticker,
        ),
        size: Size.infinite,
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
    required this.gradient,
    required this.glow,
    required this.particlesC,
    required this.illustration,
    required this.vignette,
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
  final AnimationController gradient;
  final AnimationController glow;
  final AnimationController particlesC;
  final AnimationController illustration;
  final AnimationController vignette;

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

    // ----- Layer 4: 120 drifting particles.
    final double tPart2pi = tPart * 2 * math.pi;
    for (int i = 0; i < particles.length; i++) {
      final _Particle p = particles[i];
      final double dx = p.ampX * math.sin(tPart2pi * p.periodX + p.phaseX);
      final double dy = p.ampY * math.cos(tPart2pi * p.periodY + p.phaseY);
      final double x = (p.baseX + dx) * size.width;
      final double y = (p.baseY + dy) * size.height;
      _fillPaint.color = pale.withValues(alpha: p.alpha);
      canvas.drawCircle(Offset(x, y), p.radius * math.min(sx, sy), _fillPaint);
    }

    // ----- Layer 5: category-driven illustration.
    _dispatchIllustration(_pickIllustrationKey(category),
        canvas, size, sx, sy, pale, accent, tIll);

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
    for (int i = 0; i < 13; i++) {
      final double bx = cx + (rng.nextInt(561) - 280) * sx;
      final double by = cy + (rng.nextInt(361) - 180) * sy;
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
      c.drawCircle(p, 3 * sx, _fillPaint);
    }
    // Connecting line — alpha breathes with the t-driven sin.
    final Offset focal = points[3];
    final Offset target = points[8];
    final double lineAlpha =
        0.32 + 0.22 * (0.5 + 0.5 * math.sin(t2pi));
    _strokePaint
      ..color = accentC.withValues(alpha: lineAlpha)
      ..strokeWidth = 2.0;
    c.drawLine(focal, target, _strokePaint);
    _fillPaint.color = accentC.withValues(alpha: 0.86);
    final double focalR =
        9 * sx * (1.0 + 0.10 * math.sin(t2pi + 1.2));
    c.drawCircle(focal, focalR, _fillPaint);
  }

  void _paintOrbitingCircles(Canvas c, Size sz, double sx, double sy,
      Color baseC, Color accentC, double t) {
    final double cx = 1200 * sx;
    final double cy = 360 * sy;
    final double t2pi = t * 2 * math.pi;
    final List<double> radii = <double>[160, 220, 300];
    final List<double> speeds = <double>[0.6, 0.42, 0.26];
    for (int i = 0; i < radii.length; i++) {
      _strokePaint
        ..color = baseC.withValues(alpha: 0.31 + 0.12 * i.toDouble())
        ..strokeWidth = 2.0;
      final double r = radii[i] * sx;
      // Each ring rotates at a different speed → draw as a circle with
      // a small accent arc that rotates around its perimeter.
      c.drawCircle(Offset(cx, cy), r, _strokePaint);
      final double a = t2pi * speeds[i] + i * 0.9;
      final Offset orbiter = Offset(cx + r * math.cos(a), cy + r * math.sin(a));
      _fillPaint.color = accentC.withValues(alpha: 0.55);
      c.drawCircle(orbiter, 5 * sx, _fillPaint);
    }
    // Central token — gentle scale pulse.
    final double pulse = 1.0 + 0.06 * math.sin(t2pi * 0.7);
    _fillPaint.color = accentC.withValues(alpha: 0.78);
    c.drawCircle(Offset(cx, cy), 60 * sx * pulse, _fillPaint);
  }

  void _paintMonumentalBlock(Canvas c, Size sz, double sx, double sy,
      Color baseC, Color accentC, double t) {
    final double t2pi = t * 2 * math.pi;
    final double dx = 3 * sx * math.sin(t2pi);
    final Rect rect = Rect.fromLTRB(
      980 * sx + dx, 130 * sy, 1480 * sx + dx, 580 * sy,
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
    final Rect outer = Rect.fromLTRB(
      1080 * sx, 90 * sy, 1340 * sx, 620 * sy,
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
    // The big lit window in accent.
    final double bigA = 0.78 + 0.14 * math.sin(t2pi * 0.5);
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
    final List<List<double>> bars = <List<double>>[
      <double>[960, 220, 1480, 270],
      <double>[940, 320, 1460, 370],
      <double>[920, 420, 1440, 470],
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
    // Per-fold ±1.5° rotation about the hinge.
    final double rot1 = 0.025 * math.sin(t2pi * 0.7);
    final double rot2 = 0.025 * math.cos(t2pi * 0.5 + 0.6);
    _strokePaint
      ..color = baseC.withValues(alpha: 0.51)
      ..strokeWidth = 2.0;
    _paintRotatedRect(
      c,
      Rect.fromLTRB(960 * sx, 130 * sy, 1460 * sx, 530 * sy),
      rot1,
      _strokePaint,
    );
    _paintRotatedRect(
      c,
      Rect.fromLTRB(1010 * sx, 180 * sy, 1510 * sx, 580 * sy),
      rot2,
      _strokePaint,
    );
    // Diagonal crease — alpha breathes.
    final double creaseA = 0.78 + 0.12 * math.sin(t2pi);
    _strokePaint
      ..color = accentC.withValues(alpha: creaseA)
      ..strokeWidth = 3.0;
    c.drawLine(
      Offset(960 * sx, 530 * sy),
      Offset(1510 * sx, 180 * sy),
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
    final double outerR = 120 * sx;
    final double pulse = 1.0 + 0.03 * math.sin(t2pi * 0.6);
    _strokePaint
      ..color = baseC.withValues(alpha: 0.51)
      ..strokeWidth = 3.0;
    c.drawCircle(center, outerR * pulse, _strokePaint);
    // Inner radial spokes, rotating.
    final double rot = t2pi * 0.17;
    const int spokes = 8;
    _strokePaint.strokeWidth = 2.0;
    for (int i = 0; i < spokes; i++) {
      final double a = rot + i * (2 * math.pi / spokes);
      final Offset p1 = center + Offset(math.cos(a) * 40 * sx, math.sin(a) * 40 * sy);
      final Offset p2 = center + Offset(math.cos(a) * 100 * sx, math.sin(a) * 100 * sy);
      c.drawLine(p1, p2, _strokePaint);
    }
    // Accent square offset to the lower right.
    final double sqPulse = 1.0 + 0.05 * math.sin(t2pi * 0.9 + 1.4);
    final double sqSize = 70 * sx * sqPulse;
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
      ..strokeWidth = 3.0;
    c.drawCircle(center, 170 * sx * (1.0 + 0.03 * math.sin(t2pi)), _strokePaint);
    _strokePaint.color = baseC.withValues(alpha: a2);
    c.drawCircle(center, 130 * sx * (1.0 + 0.04 * math.cos(t2pi * 0.7)),
        _strokePaint);
    // Central token + accent pulse halo.
    final double tokR = 24 * sx * (1.0 + 0.10 * math.sin(t2pi * 1.1));
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
    // The triangular arc, fill + outline.
    final double yPulse = 4 * sy * math.sin(t2pi);
    final Path path = Path()
      ..moveTo(1100 * sx, 540 * sy)
      ..lineTo(1260 * sx, 220 * sy + yPulse)
      ..lineTo(1420 * sx, 540 * sy)
      ..close();
    _fillPaint.color = accentC.withValues(alpha: 0.18);
    c.drawPath(path, _fillPaint);
    _strokePaint
      ..color = baseC.withValues(alpha: 0.51)
      ..strokeWidth = 2.0;
    c.drawPath(path, _strokePaint);
    // Baseline rule.
    _strokePaint
      ..color = accentC.withValues(alpha: 0.78 + 0.14 * math.sin(t2pi * 0.7))
      ..strokeWidth = 4.0;
    c.drawLine(Offset(1100 * sx, 540 * sy), Offset(1420 * sx, 540 * sy),
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
    final List<double> ys = <double>[220, 320, 420];
    for (int i = 0; i < ys.length; i++) {
      final double y = ys[i] * sy;
      final double x0 = (960 + i * 24) * sx;
      final double x1 = 1480 * sx;
      // Per-stripe translateX.
      final double dx = 6 * sx * math.sin(t2pi * (0.5 + i * 0.2) + i * 0.9);
      if (i == 0) {
        _fillPaint.color = accentC.withValues(alpha: 0.86);
        c.drawRect(Rect.fromLTWH(x0 + dx, y, x1 - x0, 6 * sy), _fillPaint);
      } else {
        _strokePaint
          ..color = baseC.withValues(alpha: 0.47)
          ..strokeWidth = 2.0;
        c.drawLine(Offset(x0 + dx, y + 3 * sy),
            Offset(x1 + dx, y + 3 * sy), _strokePaint);
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
    final List<Offset> nodes = <Offset>[
      Offset(1000 * sx, 220 * sy),
      Offset(1380 * sx, 280 * sy),
      Offset(1180 * sx, 460 * sy),
      Offset(1450 * sx, 480 * sy),
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
      ..strokeWidth = 2.0;
    for (int i = 0; i < nodes.length; i++) {
      final double pulse = 1.0 + 0.10 * math.sin(t2pi * (0.6 + i * 0.15) + i);
      c.drawCircle(nodes[i], 6 * sx * pulse, _strokePaint);
    }
    // First node — filled accent.
    final double pulse0 = 1.0 + 0.12 * math.sin(t2pi * 0.5);
    _fillPaint.color = accentC.withValues(alpha: 0.86);
    c.drawCircle(nodes[0], 10 * sx * pulse0, _fillPaint);
  }

  void _paintOrbitalToken(Canvas c, Size sz, double sx, double sy,
      Color baseC, Color accentC, double t) {
    final double t2pi = t * 2 * math.pi;
    final Offset center = Offset(1240 * sx, 360 * sy);
    // Outer orbit ring — alpha breathes.
    final double ringA = 0.55 + 0.15 * math.sin(t2pi);
    _strokePaint
      ..color = accentC.withValues(alpha: ringA)
      ..strokeWidth = 3.0;
    c.drawCircle(center, 240 * sx, _strokePaint);
    // Two moons orbiting at different periods.
    final double a1 = t2pi * 0.35;
    final double a2 = -t2pi * 0.48 + 1.6;
    final Offset m1 = center + Offset(math.cos(a1) * 240 * sx, math.sin(a1) * 240 * sy);
    final Offset m2 = center + Offset(math.cos(a2) * 180 * sx, math.sin(a2) * 180 * sy);
    _fillPaint.color = accentC.withValues(alpha: 0.78);
    c.drawCircle(m1, 8 * sx, _fillPaint);
    _fillPaint.color = baseC.withValues(alpha: 0.65);
    c.drawCircle(m2, 5 * sx, _fillPaint);
    // Central token scale-pulses.
    final double tokR = 60 * sx * (1.0 + 0.08 * math.sin(t2pi * 0.7));
    _fillPaint.color = baseC.withValues(alpha: 0.70);
    c.drawCircle(center, tokR, _fillPaint);
  }

  void _paintVoiceWave(Canvas c, Size sz, double sx, double sy,
      Color baseC, Color accentC, double t) {
    final double t2pi = t * 2 * math.pi;
    final double y = 360 * sy;
    // Baseline.
    _strokePaint
      ..color = baseC.withValues(alpha: 0.51)
      ..strokeWidth = 2.0;
    c.drawLine(Offset(980 * sx, y), Offset(1480 * sx, y), _strokePaint);
    // 30 vertical waveform bars.
    const int bars = 30;
    final double x0 = 980 * sx;
    final double x1 = 1480 * sx;
    final double step = (x1 - x0) / (bars - 1);
    for (int i = 0; i < bars; i++) {
      final double xi = x0 + i * step;
      final double phase = i * 0.45;
      // Composite sine — feels like real audio waveform with peaks
      // and troughs walking across the band.
      final double h = (60 * sy) *
          (0.20 +
              0.80 *
                  (0.5 +
                      0.5 *
                          math.sin(t2pi * (1.0 + (i % 5) * 0.15) + phase)));
      final bool accentBar = i >= bars - 8;
      _strokePaint
        ..color = (accentBar ? accentC : baseC).withValues(alpha: 0.78)
        ..strokeWidth = 3.0;
      c.drawLine(Offset(xi, y - h / 2), Offset(xi, y + h / 2), _strokePaint);
    }
  }

  void _paintPackageCube(Canvas c, Size sz, double sx, double sy,
      Color baseC, Color accentC, double t) {
    final double t2pi = t * 2 * math.pi;
    final double cx = 1240 * sx;
    final double cy = 360 * sy;
    final double s = 130 * sx;
    // Simulate slow rotation around vertical axis by skewing the top
    // face's perspective offset.
    final double skew = math.sin(t2pi * 0.5) * 0.18;
    final double sH = s * 0.5 + s * 0.10 * math.sin(t2pi * 0.7);
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
    _fillPaint.color = accentC.withValues(alpha: 0.55 + 0.20 * math.sin(t2pi));
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
    final Rect outer = Rect.fromLTRB(
      1150 * sx, 130 * sy, 1340 * sx, 590 * sy,
    );
    final RRect rRect =
        RRect.fromRectAndRadius(outer, Radius.circular(24 * sx));
    _strokePaint
      ..color = baseC.withValues(alpha: 0.55)
      ..strokeWidth = 3.0;
    c.drawRRect(rRect, _strokePaint);
    // Content stripes that scroll vertically (very slow loop) inside
    // the phone outline, clipped to the rounded rect.
    c.save();
    c.clipRRect(rRect);
    final double scroll = (t * outer.height) % (outer.height + 80 * sy);
    for (int i = 0; i < 10; i++) {
      final double y = outer.top - 60 * sy + i * 60 * sy + scroll - outer.height;
      final double a = 0.15 + 0.35 * (0.5 + 0.5 * math.sin(t2pi + i * 0.6));
      _fillPaint.color = baseC.withValues(alpha: a);
      c.drawRect(
        Rect.fromLTWH(outer.left + 16 * sx, y, outer.width - 32 * sx, 32 * sy),
        _fillPaint,
      );
    }
    // Top lit panel.
    _fillPaint.color = accentC.withValues(
        alpha: 0.78 + 0.12 * math.sin(t2pi * 0.7));
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
    final Rect outer = Rect.fromLTRB(
      980 * sx, 160 * sy, 1480 * sx, 560 * sy,
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
    final double stretch = 0.04 * math.sin(t2pi);
    _strokePaint
      ..color = accentC.withValues(alpha: 0.86)
      ..strokeWidth = 4.0;
    c.drawLine(
      Offset(960 * sx * (1.0 - stretch), 540 * sy * (1.0 + stretch)),
      Offset(1500 * sx * (1.0 + stretch * 0.5), 180 * sy * (1.0 - stretch)),
      _strokePaint,
    );
    // Accent dots along the line, breathing alpha.
    for (int i = 0; i < 6; i++) {
      final double tlin = i / 5.0;
      final double x = (960 + tlin * (1500 - 960)) * sx;
      final double y = (540 + tlin * (180 - 540)) * sy;
      final double a = 0.32 + 0.40 * (0.5 + 0.5 * math.sin(t2pi + i * 0.9));
      _fillPaint.color = baseC.withValues(alpha: a);
      c.drawCircle(Offset(x, y), 5 * sx, _fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeroCoverPainter old) {
    return old.base != base || old.category != category;
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
