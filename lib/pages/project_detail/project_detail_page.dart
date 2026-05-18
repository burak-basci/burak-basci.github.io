import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../utils/adaptive_layout.dart';
import '../../../utils/functions.dart';
import '../../../utils/i18n_strings.dart';
import '../../../utils/lang.dart';
import '../../../utils/page_transition.dart';
import '../../../utils/values/values.dart';
import '../../utils/values/spaces.dart';
import '../../data/projects.dart';
import '../../widgets/animations/animated_wave_line.dart';
import '../../widgets/device_mockup.dart';
import '../../widgets/helper/custom_spacer.dart';
import '../../widgets/project_item/project_item.dart';
import '../../widgets/scaffolding/footer/full_footer.dart';
import '../../widgets/scaffolding/page_wrapper.dart';
import '../../widgets/text/self_positioning_text.dart';
import '../../widgets/text/slide_box_transitioning_text.dart';

/// Pill CTA. Visible at rest — solid color background with white text —
/// and lifts on hover. Replaces the AnimatedBubbleButton on the detail page
/// because the bubble's small-at-rest pattern only works on dark backgrounds.
class _PillButton extends StatefulWidget {
  const _PillButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: _hover ? 36 : 32,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(60),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: widget.color.withValues(alpha: _hover ? 0.32 : 0.16),
                blurRadius: _hover ? 24 : 12,
                offset: Offset(0, _hover ? 10 : 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.label,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: StringConst.INTER,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigator argument shape.
class ProjectDetailArguments {
  ProjectDetailArguments({required this.index});
  final int index;
}

class ProjectDetailPage extends StatefulWidget {
  const ProjectDetailPage({super.key, this.slug});

  /// Optional URL slug (set by the per-project route
  /// `^/projects/([\w-]+)\$` in `RouteConfiguration`). When non-null,
  /// the page looks up the project in `recentWorks` by [ProjectItemData.slug].
  /// When null we fall back to the legacy `ProjectDetailArguments` route.
  final String? slug;

  static const String projectDetailPageRoute = StringConst.PROJECT_DETAIL_PAGE;

  @override
  ProjectDetailPageState createState() => ProjectDetailPageState();
}

class ProjectDetailPageState extends State<ProjectDetailPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  // One controller per logical section, all gated by VisibilityDetector
  // except _heroController (forwarded on page-load complete),
  // _heroBreathController + _waveController (both loop forever).
  late AnimationController _navController;
  late AnimationController _heroController;
  late AnimationController _heroBreathController;
  late AnimationController _waveController;
  // Ambient hero overlays — very slow, very subtle. Layered above the
  // gradient but below the wave line so they read as atmosphere, never
  // as UI. Each animates its own subtree via AnimatedBuilder so the
  // Image.asset cover never repaints.
  late AnimationController _heroPulseController;   // vertical accent pulse
  late AnimationController _heroDriftController;   // upper-right star drift
  late AnimationController _heroDotsController;    // tiny twinkling signals
  // Second-wave ambient pieces. Different periods from the first three so
  // their phases never re-align cleanly — the hero stays "alive" without
  // ever beating in unison.
  late AnimationController _heroTwinPulseController;   // right-edge companion pulse
  late AnimationController _heroConstellationController; // upper-arc dots
  late AnimationController _heroEdgeGlowController;    // bottom-left corner halo
  // Third-wave ambient pieces — direct cousins of the original drifting
  // halo. Different periods again (14.5 / 16.4 / 17.8 s) from the first
  // six (10 / 9.5 / 12 / 11 / 12 / 13 s) so no two ever beat in unison.
  late AnimationController _heroCompanionDriftController; // lower-left companion halo
  late AnimationController _heroOrbitAController;         // inner orbit halo
  late AnimationController _heroOrbitBController;         // outer orbit halo
  // The mote field uses a single AnimationController whose `.value` is
  // remapped per-dot by each dot's own period — six different cycle
  // lengths (10.5 / 11.7 / 13.3 / 14.1 / 15.6 / 17.2 s) inside one tick.
  late AnimationController _heroMoteController;           // suspended dust motes
  // Fourth-wave ambient pieces — sharper, crystalline contrast to the soft
  // halos above. All three are parent-timer controllers whose elapsed
  // seconds are remapped per-child by each child's own period, so we get
  // many independent cycles from three controllers (same pattern as the
  // mote field on overlay 8).
  late AnimationController _heroPinpointController;       // sharp-twinkle pinpoint constellation
  late AnimationController _heroStreakController;         // slow falling-streak motes
  late AnimationController _heroCrossController;          // pulsing micro-crosses
  late AnimationController _aboutController;
  late AnimationController _aboutBodyController;
  late AnimationController _decisionsController;
  late AnimationController _learningsController;
  late AnimationController _technicalController;
  late AnimationController _galleryController;
  late AnimationController _nextProjectController;
  late AnimationController _footerController;

  @override
  void initState() {
    _navController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    // Continuous Ken-Burns "breathing" on the hero cover — slow zoom
    // 1.00 → 1.06 on an ease-in-out, reverses on completion so the
    // background drifts in and out beneath the static text overlay
    // for a calm cinematic ambience.
    _heroBreathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat(reverse: true);
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _waveController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _waveController.forward();
        }
      });
    _waveController.forward();

    // Ambient hero overlays. All loop forever, started immediately.
    // Pulse uses reverse:true so the vertical line eases at both ends;
    // drift + dots loop continuously so cos/sin phases stay seamless.
    _heroPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _heroDriftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _heroDotsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 11),
    )..repeat();

    // Second-wave ambient overlays. The twin pulse reverses (symmetrical
    // ease at both ends) to match the original pulse's behaviour; the
    // constellation arc and edge glow loop continuously so their sin/cos
    // phases stay seamless across the wrap.
    _heroTwinPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9500),
    )..repeat(reverse: true);
    _heroConstellationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _heroEdgeGlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 13),
    )..repeat(reverse: true);

    // Third-wave ambient overlays. All orbit-driven cos/sin animations
    // loop continuously so phases wrap seamlessly; the mote controller
    // is a single long timer that each dot remaps to its own period.
    _heroCompanionDriftController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 14500),
    )..repeat();
    _heroOrbitAController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
    _heroOrbitBController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    // 60s parent timer; each mote modulates value by its own period via
    // a sine of (t / period), giving us six independent cycles inside
    // one ticking controller.
    _heroMoteController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    // Fourth-wave ambient overlays. Each is a long parent timer; the
    // children remap its elapsed seconds against their own per-element
    // period so we get many cycle lengths inside one ticking controller
    // (same trick the mote field uses on overlay 8). Parent windows are
    // picked so each remapped child period divides cleanly enough that
    // the wrap point never lands on a visible peak.
    _heroPinpointController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 90),
    )..repeat();
    _heroStreakController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 80),
    )..repeat();
    _heroCrossController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 99),
    )..repeat();

    _aboutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _aboutBodyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _decisionsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _learningsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _technicalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _galleryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _nextProjectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _footerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    super.initState();
  }

  @override
  void dispose() {
    _navController.dispose();
    _heroController.dispose();
    _heroBreathController.dispose();
    _waveController.dispose();
    _heroPulseController.dispose();
    _heroDriftController.dispose();
    _heroDotsController.dispose();
    _heroTwinPulseController.dispose();
    _heroConstellationController.dispose();
    _heroEdgeGlowController.dispose();
    _heroCompanionDriftController.dispose();
    _heroOrbitAController.dispose();
    _heroOrbitBController.dispose();
    _heroMoteController.dispose();
    _heroPinpointController.dispose();
    _heroStreakController.dispose();
    _heroCrossController.dispose();
    _aboutController.dispose();
    _aboutBodyController.dispose();
    _decisionsController.dispose();
    _learningsController.dispose();
    _technicalController.dispose();
    _galleryController.dispose();
    _nextProjectController.dispose();
    _footerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Find the project either by slug (per-project URL) or by index
    // (legacy `ProjectDetailArguments`).
    int idx;
    if (widget.slug != null) {
      final int found = recentWorks.indexWhere((p) => p.slug == widget.slug);
      idx = found == -1 ? 0 : found;
    } else {
      final ProjectDetailArguments args =
          ModalRoute.of(context)!.settings.arguments
                  as ProjectDetailArguments? ??
              ProjectDetailArguments(index: 0);
      idx = args.index.clamp(0, recentWorks.length - 1);
    }
    final ProjectItemData project = recentWorks[idx];
    final ProjectItemData? nextProject = recentWorks.length > 1
        ? recentWorks[(idx + 1) % recentWorks.length]
        : null;
    final int nextIdx = (idx + 1) % recentWorks.length;

    final AppLang lang = LangController.to.lang;
    final double horizontalPadding = responsiveSize(
      mobile: Get.width * 0.10,
      desktop: Get.width * 0.15,
    );
    final double contentWidth = Get.width - horizontalPadding * 2;

    return PageWrapper(
      selectedRoute: ProjectDetailPage.projectDetailPageRoute,
      selectedPageName: project.titleFor(lang),
      navigationBarAnimationController: _navController,
      hasSideTitle: false,
      showFloatingBack: true,
      onLoadingAnimationDone: () {
        // The cover/uncover transition already shows the page arriving.
        // Snap the entry controllers to their final state instead of
        // animating a second time — only the home page replays its
        // in-page content animations on entry.
        _navController.value = 1;
        _heroController.value = 1;
      },
      child: ListView(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        children: <Widget>[
          _hero(project, lang),
          const CustomSpacer(heightFactor: 0.12),
          _aboutSection(project, lang, contentWidth, horizontalPadding),
          if (project.decisionsFor(lang).isNotEmpty) ...<Widget>[
            const CustomSpacer(heightFactor: 0.10),
            _decisionsSection(project, lang, contentWidth, horizontalPadding),
          ],
          if (project.learningsFor(lang).isNotEmpty) ...<Widget>[
            const CustomSpacer(heightFactor: 0.10),
            _learningsSection(project, lang, contentWidth, horizontalPadding),
          ],
          if (project.technicalImages.isNotEmpty) ...<Widget>[
            const CustomSpacer(heightFactor: 0.10),
            _technicalSection(project, lang, contentWidth, horizontalPadding),
          ],
          if (project.screenshots.isNotEmpty) ...<Widget>[
            const CustomSpacer(heightFactor: 0.10),
            _gallerySection(project, contentWidth, horizontalPadding),
          ],
          if (nextProject != null) ...<Widget>[
            const CustomSpacer(heightFactor: 0.15),
            _nextProjectSection(nextProject, lang, nextIdx,
                contentWidth, horizontalPadding),
          ],
          const CustomSpacer(heightFactor: 0.10),
          VisibilityDetector(
            key: const Key('project-detail-footer'),
            onVisibilityChanged: (info) {
              if (info.visibleFraction > 0.25) _footerController.forward();
            },
            child: FullFooter(controller: _footerController),
          ),
        ],
      ),
    );
  }

  // ---------- HERO ----------
  Widget _hero(ProjectItemData project, AppLang lang) {
    return SizedBox(
      width: Get.width,
      height: Get.height,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // The procedural cover is now a text-less background
          // (gradient + illustration). It slowly zooms in and out
          // between 1.00 and 1.06 on an ease-in-out, beneath a static
          // text overlay (added further down this Stack). ClipRect
          // contains the zoom so it never bleeds past the hero bounds.
          Positioned.fill(
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _heroBreathController,
                builder: (context, child) {
                  final double t = Curves.easeInOut
                      .transform(_heroBreathController.value);
                  final double scale = 1.0 + t * 0.06; // 1.00 -> 1.06
                  return Transform.scale(
                    scale: scale,
                    alignment: Alignment.center,
                    child: child,
                  );
                },
                child: Image.asset(project.coverFor(lang), fit: BoxFit.cover),
              ),
            ),
          ),

          // Very soft bottom shade so the wave line + scroll-down cue
          // stay legible without darkening the poster's typography.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.18),
                    ],
                    stops: const <double>[0.0, 0.7, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // --- Ambient overlay 1: vertical accent pulse ---------------
          // A 4 px wide, 120 px tall hairline that breathes its opacity
          // and shifts a few px on the Y axis in the bottom-third of
          // the frame, far left of the wave's centre so it never fights
          // for attention with the wave or the poster typography.
          Positioned(
            left: 56,
            bottom: 140,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _heroPulseController,
                builder: (context, _) {
                  // Sine-eased at both ends because the controller
                  // already reverses; we still want the *opacity*
                  // curve to bow smoothly rather than ramp linearly.
                  final double t = _heroPulseController.value;
                  final double eased =
                      0.5 - 0.5 * math.cos(t * math.pi);
                  final double opacity = 0.18 + eased * 0.34; // 0.18 → 0.52
                  final double dy = (eased - 0.5) * 18.0;     // ±9 px drift
                  return Transform.translate(
                    offset: Offset(0, dy),
                    child: Container(
                      width: 4,
                      height: 120,
                      decoration: BoxDecoration(
                        color: project.primaryColor
                            .withValues(alpha: opacity),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // --- Ambient overlay 2: drifting star glow -----------------
          // A small, soft, blurred dot that orbits an ellipse in the
          // upper-right of the hero. cos/sin parametrisation keeps
          // the path perfectly closed across the 12 s loop.
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(builder: (context, c) {
                // Anchor the orbit centre to the upper-right region;
                // radii are kept small so the drift is almost imperceptible.
                final double cx = c.maxWidth - 140;
                final double cy = 160;
                const double rx = 42;
                const double ry = 26;
                return AnimatedBuilder(
                  animation: _heroDriftController,
                  builder: (context, _) {
                    final double a =
                        _heroDriftController.value * 2 * math.pi;
                    final double x = cx + math.cos(a) * rx;
                    final double y = cy + math.sin(a) * ry;
                    return Stack(children: <Widget>[
                      Positioned(
                        left: x - 16,
                        top: y - 16,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // Soft halo via a single radial gradient —
                            // cheaper than a BackdropFilter and stays
                            // crisp on web.
                            gradient: RadialGradient(
                              colors: <Color>[
                                project.primaryColor
                                    .withValues(alpha: 0.42),
                                project.primaryColor
                                    .withValues(alpha: 0.0),
                              ],
                              stops: const <double>[0.25, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ]);
                  },
                );
              }),
            ),
          ),

          // --- Ambient overlay 3: four tiny phase-offset signals -----
          // Each dot has its own (x, y, phase) tuple so the four
          // twinkle out of sync. 1.5 px squares so they read as
          // pixel-level grain rather than UI dots.
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(builder: (context, c) {
                // Fractional positions so the constellation scales with
                // the hero regardless of viewport size.
                final List<_HeroDot> dots = <_HeroDot>[
                  _HeroDot(fx: 0.18, fy: 0.22, phase: 0.00),
                  _HeroDot(fx: 0.72, fy: 0.38, phase: 0.27),
                  _HeroDot(fx: 0.34, fy: 0.78, phase: 0.55),
                  _HeroDot(fx: 0.88, fy: 0.66, phase: 0.81),
                ];
                return AnimatedBuilder(
                  animation: _heroDotsController,
                  builder: (context, _) {
                    final double t = _heroDotsController.value;
                    return Stack(
                      children: <Widget>[
                        for (final _HeroDot d in dots)
                          Builder(builder: (_) {
                            // Per-dot sine wave; clamped low so dots
                            // never bloom past ~50 % alpha.
                            final double p =
                                (t + d.phase) % 1.0;
                            final double s =
                                0.5 + 0.5 * math.sin(p * 2 * math.pi);
                            final double opacity = 0.10 + s * 0.40;
                            return Positioned(
                              left: c.maxWidth * d.fx,
                              top: c.maxHeight * d.fy,
                              child: Container(
                                width: 2,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: project.primaryColor
                                      .withValues(alpha: opacity),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }),
                      ],
                    );
                  },
                );
              }),
            ),
          ),

          // --- Ambient overlay 4: twin pulse companion ---------------
          // Mirror of overlay 1 on the opposite (right) edge, near the
          // upper-third instead of bottom-third, with a slightly different
          // period (9.5s vs 10s) and a touch less amplitude so it reads
          // as a quieter echo of its partner — never a beat in sync.
          Positioned(
            right: 56,
            top: 160,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _heroTwinPulseController,
                builder: (context, _) {
                  final double t = _heroTwinPulseController.value;
                  final double eased =
                      0.5 - 0.5 * math.cos(t * math.pi);
                  // Slightly tighter opacity range than the left pulse so
                  // the right one feels secondary, not a competing focal.
                  final double opacity = 0.14 + eased * 0.28; // 0.14 → 0.42
                  final double dy = (eased - 0.5) * 14.0;     // ±7 px drift
                  return Transform.translate(
                    offset: Offset(0, dy),
                    child: Container(
                      width: 3,
                      height: 96,
                      decoration: BoxDecoration(
                        color: project.primaryColor
                            .withValues(alpha: opacity),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // --- Ambient overlay 5: faint constellation arc -----------
          // Four 2 px dots arranged along a gentle arc across the upper
          // third of the hero. Each has a long phase-offset so they
          // bloom in sequence rather than as a cluster. Different
          // y-fractions from the existing _heroDots so the two systems
          // never sit on top of each other.
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(builder: (context, c) {
                // Arc anchored across the upper third, dipping slightly
                // in the middle so the constellation reads as a curve
                // rather than a straight line of pixels.
                final List<_HeroDot> arc = <_HeroDot>[
                  _HeroDot(fx: 0.28, fy: 0.14, phase: 0.00),
                  _HeroDot(fx: 0.44, fy: 0.10, phase: 0.30),
                  _HeroDot(fx: 0.60, fy: 0.12, phase: 0.55),
                  _HeroDot(fx: 0.76, fy: 0.18, phase: 0.78),
                ];
                return AnimatedBuilder(
                  animation: _heroConstellationController,
                  builder: (context, _) {
                    final double t = _heroConstellationController.value;
                    return Stack(
                      children: <Widget>[
                        for (final _HeroDot d in arc)
                          Builder(builder: (_) {
                            // Sharper peak than the original dots so the
                            // arc reads as discrete "blinks" instead of
                            // a soft twinkle. Cubed sine keeps the tail
                            // long and the peak brief.
                            final double p = (t + d.phase) % 1.0;
                            final double s =
                                math.sin(p * 2 * math.pi).clamp(0.0, 1.0);
                            final double opacity = s * s * 0.46;
                            return Positioned(
                              left: c.maxWidth * d.fx,
                              top: c.maxHeight * d.fy,
                              child: Container(
                                width: 2,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: project.primaryColor
                                      .withValues(alpha: opacity),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }),
                      ],
                    );
                  },
                );
              }),
            ),
          ),

          // --- Ambient overlay 6: bottom-left edge-glow breathing ----
          // A very wide soft radial gradient anchored at the bottom-left
          // corner, breathing its radius (and a sliver of opacity) over
          // 13 s. Reads as the room itself pulsing — the most ambient
          // of the six pieces, deliberately the slowest.
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(builder: (context, c) {
                return AnimatedBuilder(
                  animation: _heroEdgeGlowController,
                  builder: (context, _) {
                    final double t = Curves.easeInOut
                        .transform(_heroEdgeGlowController.value);
                    // Radius breathes between ~46% and ~62% of the
                    // shortest side; opacity peaks at 6 % so the glow
                    // never threatens the poster's typography.
                    final double shortest =
                        math.min(c.maxWidth, c.maxHeight);
                    final double radius =
                        shortest * (0.46 + t * 0.16);
                    final double peakAlpha = 0.025 + t * 0.035; // 0.025 → 0.06
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.bottomLeft,
                          radius: radius / shortest,
                          colors: <Color>[
                            project.primaryColor
                                .withValues(alpha: peakAlpha),
                            project.primaryColor
                                .withValues(alpha: 0.0),
                          ],
                          stops: const <double>[0.0, 1.0],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),

          // --- Ambient overlay 7: companion drifting halo ------------
          // A dimmer, smaller cousin of overlay 2, anchored in the
          // lower-left third instead of the upper-right. Different
          // ellipse, different period (14.5 s vs 12 s), opposite phase
          // tendency — so the two halos drift independently and the
          // viewer's eye never has a single "centre of orbit" to lock
          // onto.
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(builder: (context, c) {
                // Anchor to roughly 22 % from the left, 70 % down.
                final double cx = c.maxWidth * 0.22;
                final double cy = c.maxHeight * 0.70;
                const double rx = 34;
                const double ry = 22;
                return AnimatedBuilder(
                  animation: _heroCompanionDriftController,
                  builder: (context, _) {
                    // Negative phase offset (-pi/3) so its orbit is
                    // never in lockstep with the original halo even
                    // before the period difference does its work.
                    final double a =
                        _heroCompanionDriftController.value * 2 * math.pi
                            - math.pi / 3;
                    final double x = cx + math.cos(a) * rx;
                    final double y = cy + math.sin(a) * ry;
                    return Stack(children: <Widget>[
                      Positioned(
                        left: x - 11,
                        top: y - 11,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // Peak alpha 0.28 — about two-thirds the
                            // original halo's 0.42, so it reads as a
                            // distant cousin rather than a duplicate.
                            gradient: RadialGradient(
                              colors: <Color>[
                                project.primaryColor
                                    .withValues(alpha: 0.28),
                                project.primaryColor
                                    .withValues(alpha: 0.0),
                              ],
                              stops: const <double>[0.25, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ]);
                  },
                );
              }),
            ),
          ),

          // --- Ambient overlay 8: suspended mote field ----------------
          // Six tiny dust dots distributed across the mid-frame, each
          // with its own period (10.5 / 11.7 / 13.3 / 14.1 / 15.6 / 17.2
          // seconds) so they never sync. Vertical drift is ±8 px on a
          // sine, opacity wobbles 0.05 → 0.35 on the same sine — the
          // result reads like dust suspended in a light beam.
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(builder: (context, c) {
                // Each mote: fractional anchor + independent period (s)
                // + phase offset so peaks don't all hit at t=0.
                const List<_HeroMote> motes = <_HeroMote>[
                  _HeroMote(fx: 0.14, fy: 0.42, periodSec: 10.5, phase: 0.00),
                  _HeroMote(fx: 0.31, fy: 0.55, periodSec: 11.7, phase: 0.17),
                  _HeroMote(fx: 0.48, fy: 0.36, periodSec: 13.3, phase: 0.34),
                  _HeroMote(fx: 0.63, fy: 0.58, periodSec: 14.1, phase: 0.51),
                  _HeroMote(fx: 0.81, fy: 0.46, periodSec: 15.6, phase: 0.68),
                  _HeroMote(fx: 0.92, fy: 0.54, periodSec: 17.2, phase: 0.85),
                ];
                return AnimatedBuilder(
                  animation: _heroMoteController,
                  builder: (context, _) {
                    // Convert the controller's 0-1 value across a 60 s
                    // window into elapsed seconds, then remap per mote.
                    final double tSec =
                        _heroMoteController.value * 60.0;
                    return Stack(
                      children: <Widget>[
                        for (final _HeroMote m in motes)
                          Builder(builder: (_) {
                            final double cycle =
                                ((tSec / m.periodSec) + m.phase) % 1.0;
                            final double sine =
                                math.sin(cycle * 2 * math.pi);
                            // dy: -8 .. +8 px
                            final double dy = sine * 8.0;
                            // opacity envelope rides the same sine but
                            // mapped to 0.05 → 0.35 (peak alpha 0.35).
                            final double env = (sine + 1.0) * 0.5;
                            final double opacity = 0.05 + env * 0.30;
                            return Positioned(
                              left: c.maxWidth * m.fx,
                              top: c.maxHeight * m.fy + dy,
                              child: Container(
                                width: 2,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withValues(alpha: opacity),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }),
                      ],
                    );
                  },
                );
              }),
            ),
          ),

          // --- Ambient overlay 9 & 10: two-orbit dance ---------------
          // Two more soft, blurry halos that orbit concentric ellipses
          // around a shared mid-frame centre, at different angular
          // speeds (15 s and 18 s). They pass each other periodically
          // every ~90 s. Both kept very dim (peak alpha 0.15) so the
          // dance reads as ambience, never as a focal point.
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(builder: (context, c) {
                // Shared orbit centre, slightly right of mid-frame so it
                // doesn't fight the wave line's horizontal symmetry.
                final double cx = c.maxWidth * 0.56;
                final double cy = c.maxHeight * 0.48;
                return Stack(
                  children: <Widget>[
                    // Inner orbit — 15 s, smaller halo (18 px), tighter
                    // ellipse.
                    AnimatedBuilder(
                      animation: _heroOrbitAController,
                      builder: (context, _) {
                        const double rx = 70;
                        const double ry = 44;
                        final double a =
                            _heroOrbitAController.value * 2 * math.pi;
                        final double x = cx + math.cos(a) * rx;
                        final double y = cy + math.sin(a) * ry;
                        return Stack(children: <Widget>[
                          Positioned(
                            left: x - 9,
                            top: y - 9,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: <Color>[
                                    project.primaryColor
                                        .withValues(alpha: 0.15),
                                    project.primaryColor
                                        .withValues(alpha: 0.0),
                                  ],
                                  stops: const <double>[0.2, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ]);
                      },
                    ),
                    // Outer orbit — 18 s, slightly larger halo (22 px),
                    // wider ellipse. Phase-offset by pi so the two halos
                    // start on opposite sides of the shared centre.
                    AnimatedBuilder(
                      animation: _heroOrbitBController,
                      builder: (context, _) {
                        const double rx = 110;
                        const double ry = 64;
                        final double a =
                            _heroOrbitBController.value * 2 * math.pi
                                + math.pi;
                        final double x = cx + math.cos(a) * rx;
                        final double y = cy + math.sin(a) * ry;
                        return Stack(children: <Widget>[
                          Positioned(
                            left: x - 11,
                            top: y - 11,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: <Color>[
                                    project.primaryColor
                                        .withValues(alpha: 0.13),
                                    project.primaryColor
                                        .withValues(alpha: 0.0),
                                  ],
                                  stops: const <double>[0.2, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ]);
                      },
                    ),
                  ],
                );
              }),
            ),
          ),

          // --- Ambient overlay 11: sharp-pinpoint constellation ------
          // Eight 1×1 px crystalline dots scattered in the upper third
          // and along the outer edges. Each twinkles on its own period
          // (8.0 → 14.7 s, no two matching) and the envelope is
          // double-eased (easeInOut twice) so the peak pops in and out
          // crisply rather than fading. The visual contrast against the
          // soft halos above is the whole point — these read like sharp
          // dust in a beam of light, not like ambient atmosphere.
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(builder: (context, c) {
                // Anchors are fractional so the constellation scales with
                // the hero. Five sit in the upper third, three along the
                // left/right outer edges — never the centre.
                const List<_HeroPinpoint> pins = <_HeroPinpoint>[
                  _HeroPinpoint(fx: 0.08, fy: 0.18, periodSec: 8.0, phase: 0.00, white: true),
                  _HeroPinpoint(fx: 0.22, fy: 0.07, periodSec: 8.7, phase: 0.13),
                  _HeroPinpoint(fx: 0.41, fy: 0.04, periodSec: 9.0, phase: 0.26, white: true),
                  _HeroPinpoint(fx: 0.58, fy: 0.09, periodSec: 10.8, phase: 0.39),
                  _HeroPinpoint(fx: 0.79, fy: 0.05, periodSec: 11.3, phase: 0.52, white: true),
                  _HeroPinpoint(fx: 0.94, fy: 0.22, periodSec: 12.2, phase: 0.65),
                  _HeroPinpoint(fx: 0.03, fy: 0.48, periodSec: 13.8, phase: 0.78, white: true),
                  _HeroPinpoint(fx: 0.96, fy: 0.62, periodSec: 14.7, phase: 0.91),
                ];
                return AnimatedBuilder(
                  animation: _heroPinpointController,
                  builder: (context, _) {
                    // 90 s parent window remapped per-pin.
                    final double tSec = _heroPinpointController.value * 90.0;
                    return Stack(
                      children: <Widget>[
                        for (final _HeroPinpoint p in pins)
                          Builder(builder: (_) {
                            final double cycle =
                                ((tSec / p.periodSec) + p.phase) % 1.0;
                            // Sine envelope normalised to 0..1.
                            final double s = 0.5 +
                                0.5 * math.sin(cycle * 2 * math.pi);
                            // Double easeInOut for a sharper, crisper
                            // peak than a single ease — the dot snaps
                            // bright, lingers a beat, then snaps dark.
                            final double sharp = Curves.easeInOut.transform(
                                Curves.easeInOut.transform(s));
                            final double opacity = sharp * 0.55;
                            final Color tint = p.white
                                ? Colors.white
                                : project.primaryColor;
                            return Positioned(
                              left: c.maxWidth * p.fx,
                              top: c.maxHeight * p.fy,
                              child: Container(
                                width: 1,
                                height: 1,
                                color: tint.withValues(alpha: opacity),
                              ),
                            );
                          }),
                      ],
                    );
                  },
                );
              }),
            ),
          ),

          // --- Ambient overlay 12: falling-streak motes --------------
          // Four 1 px × 14 px vertical hairlines that slowly translate
          // top-to-bottom across the hero on independent cycles (16.1 /
          // 16.9 / 19.2 / 14.7 s). Each has its own start-x and a phase
          // offset so two are typically visible at any given moment —
          // the result reads like very slow rain. A 1.5 px soft halo
          // sits behind each line so it doesn't aliase to nothing on
          // sub-pixel rows.
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(builder: (context, c) {
                const List<_HeroStreak> streaks = <_HeroStreak>[
                  _HeroStreak(fx: 0.16, periodSec: 16.1, phase: 0.00),
                  _HeroStreak(fx: 0.39, periodSec: 16.9, phase: 0.30),
                  _HeroStreak(fx: 0.67, periodSec: 19.2, phase: 0.55),
                  _HeroStreak(fx: 0.88, periodSec: 14.7, phase: 0.80),
                ];
                return AnimatedBuilder(
                  animation: _heroStreakController,
                  builder: (context, _) {
                    // 80 s parent window remapped per-streak.
                    final double tSec = _heroStreakController.value * 80.0;
                    return Stack(
                      children: <Widget>[
                        for (final _HeroStreak s in streaks)
                          Builder(builder: (_) {
                            final double cycle =
                                ((tSec / s.periodSec) + s.phase) % 1.0;
                            // y travels from -20 (just above the frame)
                            // to maxHeight+20 (just below) so the streak
                            // enters and exits off-screen rather than
                            // popping in/out at the edge.
                            final double y =
                                -20.0 + cycle * (c.maxHeight + 40.0);
                            // Fade in over the first 12 % of the cycle
                            // and out over the last 12 % so the streak
                            // never abruptly appears or vanishes.
                            double envelope;
                            if (cycle < 0.12) {
                              envelope = cycle / 0.12;
                            } else if (cycle > 0.88) {
                              envelope = (1.0 - cycle) / 0.12;
                            } else {
                              envelope = 1.0;
                            }
                            envelope = envelope.clamp(0.0, 1.0);
                            final double lineAlpha = envelope * 0.55;
                            final double haloAlpha = envelope * 0.18;
                            return Positioned(
                              left: c.maxWidth * s.fx,
                              top: y,
                              child: SizedBox(
                                width: 1.5,
                                height: 14,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    // Soft halo behind the hairline so
                                    // the streak still reads on lighter
                                    // areas of the poster.
                                    Container(
                                      width: 1.5,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: <Color>[
                                            project.primaryColor
                                                .withValues(alpha: 0.0),
                                            project.primaryColor
                                                .withValues(alpha: haloAlpha),
                                            project.primaryColor
                                                .withValues(alpha: 0.0),
                                          ],
                                          stops: const <double>[0.0, 0.5, 1.0],
                                        ),
                                      ),
                                    ),
                                    // Crisp 1 px hairline on top.
                                    Container(
                                      width: 1,
                                      height: 14,
                                      color: project.primaryColor
                                          .withValues(alpha: lineAlpha),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    );
                  },
                );
              }),
            ),
          ),

          // --- Ambient overlay 13: pulsing micro-crosses -------------
          // Two tiny "+" cross shapes (8 × 8 px, 1 px stroke) at fixed
          // positions — one lower-left of centre, one upper-right of
          // centre. Each scales 0.6 → 1.0 and alpha 0.18 → 0.55 on a
          // sine envelope (9.0 s + 11.3 s). They read as survey
          // markers — the most overtly "instrument" of the new pieces,
          // tying the soft halos to a sense of measurement.
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(builder: (context, c) {
                // Fractional anchors — one lower-left of centre, one
                // upper-right of centre. Kept away from the wave line
                // bottom area so they never fight the wave for focus.
                const List<_HeroCross> crosses = <_HeroCross>[
                  _HeroCross(fx: 0.38, fy: 0.62, periodSec: 9.0, phase: 0.00),
                  _HeroCross(fx: 0.66, fy: 0.32, periodSec: 11.3, phase: 0.45),
                ];
                return AnimatedBuilder(
                  animation: _heroCrossController,
                  builder: (context, _) {
                    // 99 s parent window remapped per-cross.
                    final double tSec = _heroCrossController.value * 99.0;
                    return Stack(
                      children: <Widget>[
                        for (final _HeroCross x in crosses)
                          Builder(builder: (_) {
                            final double cycle =
                                ((tSec / x.periodSec) + x.phase) % 1.0;
                            // Pure sine envelope, normalised to 0..1.
                            final double env = 0.5 +
                                0.5 * math.sin(cycle * 2 * math.pi);
                            final double scale = 0.6 + env * 0.4; // 0.6 → 1.0
                            final double opacity = 0.18 + env * 0.37; // 0.18 → 0.55
                            return Positioned(
                              left: c.maxWidth * x.fx - 4,
                              top: c.maxHeight * x.fy - 4,
                              child: Transform.scale(
                                scale: scale,
                                child: SizedBox(
                                  width: 8,
                                  height: 8,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                      // Horizontal arm.
                                      Container(
                                        width: 8,
                                        height: 1,
                                        color: project.primaryColor
                                            .withValues(alpha: opacity),
                                      ),
                                      // Vertical arm.
                                      Container(
                                        width: 1,
                                        height: 8,
                                        color: project.primaryColor
                                            .withValues(alpha: opacity),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                      ],
                    );
                  },
                );
              }),
            ),
          ),

          // --- Static text overlay (poster typography) ----------------
          // Rendered live by Flutter so the title / subtitle / category
          // are pixel-sharp at any zoom and adapt instantly to the
          // active language. Anchored as a Positioned outside the
          // zooming Transform.scale so the text never scales with the
          // Ken-Burns breath — only the background image moves.
          Positioned(
            left: responsiveSize(mobile: 32, desktop: 96),
            right: responsiveSize(mobile: 32, desktop: 96),
            bottom: responsiveSize(mobile: 180, desktop: 200),
            child: IgnorePointer(
              child: _heroTextOverlay(project, lang),
            ),
          ),

          // Wave line at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: AnimatedWaveLine(
                controller: _waveController,
                height: 64,
                color: project.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The static poster typography that sits on top of the breathing
  /// hero cover: small uppercase letter-spaced category line, large
  /// bold title, lighter wrapping subtitle, and two short accent
  /// rules in the project's primary colour. Reads its strings from
  /// the language-aware `*For(lang)` getters so a language switch
  /// is reflected instantly without re-generating the asset.
  Widget _heroTextOverlay(ProjectItemData project, AppLang lang) {
    final TextStyle? categoryStyle = Get.textTheme.bodyLarge?.copyWith(
      fontFamily: StringConst.INTER,
      fontSize: responsiveSize(mobile: 11, desktop: 13),
      fontWeight: FontWeight.w600,
      letterSpacing: 3,
      color: Colors.white.withValues(alpha: 0.72),
    );
    final TextStyle? titleStyle = Get.textTheme.displayLarge?.copyWith(
      fontFamily: StringConst.VISUELT_PRO,
      fontSize: responsiveSize(mobile: 36, desktop: 72),
      fontWeight: FontWeight.w700,
      height: 1.05,
      color: Colors.white,
    );
    final TextStyle? subtitleStyle = Get.textTheme.bodyLarge?.copyWith(
      fontFamily: StringConst.INTER,
      fontSize: responsiveSize(mobile: 14, desktop: 18),
      fontWeight: FontWeight.w300,
      height: 1.4,
      color: Colors.white.withValues(alpha: 0.86),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          project.categoryFor(lang).toUpperCase(),
          style: categoryStyle,
        ),
        const SizedBox(height: 16),
        Text(
          project.titleFor(lang),
          style: titleStyle,
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: responsiveSize(mobile: 520, desktop: 720),
          ),
          child: Text(
            project.subtitleFor(lang),
            style: subtitleStyle,
          ),
        ),
        const SizedBox(height: 24),
        // Two short accent rules in the hero colour — mirrors the
        // composition the user is used to from the previously baked
        // covers, just rendered live now.
        Container(
          width: 92,
          height: 3,
          color: project.primaryColor,
        ),
        const SizedBox(height: 8),
        Container(
          width: 44,
          height: 2,
          color: Colors.white.withValues(alpha: 0.42),
        ),
      ],
    );
  }

  // ---------- SECTION HEADER ----------
  Widget _sectionHeader({
    required AnimationController controller,
    required String number,
    required String label,
    required String heading,
    required double width,
  }) {
    final TextStyle? numberStyle = Get.textTheme.bodyLarge?.copyWith(
      fontFamily: StringConst.INTER,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: 3,
      color: CustomColors.black,
    );
    final TextStyle? labelStyle = Get.textTheme.bodyLarge?.copyWith(
      fontFamily: StringConst.INTER,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 3,
      color: CustomColors.grey700,
    );
    final TextStyle? headingStyle = Get.textTheme.headlineMedium?.copyWith(
      fontFamily: StringConst.VISUELT_PRO,
      fontSize: responsiveSize(mobile: 32, desktop: 44),
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: CustomColors.black,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AnimatedSlideBoxTransitionText(
              controller: controller,
              text: number,
              textStyle: numberStyle,
            ),
            const SizedBox(width: 14),
            // small accent rule
            Container(width: 28, height: 2, color: CustomColors.black),
            const SizedBox(width: 14),
            AnimatedSlideBoxTransitionText(
              controller: controller,
              text: label,
              textStyle: labelStyle,
            ),
          ],
        ),
        const SpaceH40(),
        AnimatedSlideBoxTransitionText(
          controller: controller,
          text: heading,
          textStyle: headingStyle,
          width: width,
        ),
      ],
    );
  }

  // ---------- ABOUT ----------
  Widget _aboutSection(
      ProjectItemData project, AppLang lang, double width, double pad) {
    return VisibilityDetector(
      key: const Key('project-detail-about'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.20) {
          _aboutController.forward();
          Future<void>.delayed(const Duration(milliseconds: 350), () {
            if (mounted) _aboutBodyController.forward();
          });
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _sectionHeader(
              controller: _aboutController,
              number: '/01',
              label: Tr.of('section.about'),
              heading: Tr.of('section.about_heading'),
              width: width,
            ),
            const SpaceH32(),
            LayoutBuilder(builder: (context, constraints) {
              final bool wide = constraints.maxWidth > 800;
              final Widget description = SelfPositioningText(
                controller: _aboutBodyController,
                text: project.descriptionFor(lang),
                width: wide ? width * 0.62 : width,
                heightFactor: 1.0,
                textStyle: Get.textTheme.bodyLarge?.copyWith(
                  fontFamily: StringConst.INTER,
                  fontSize: responsiveSize(mobile: 16, desktop: 19),
                  fontWeight: FontWeight.w300,
                  color: CustomColors.grey800,
                  height: 1.8,
                ),
              );
              final Widget meta = _metaPanel(project, lang, wide ? width * 0.32 : width);
              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(flex: 2, child: description),
                    const SpaceW40(),
                    Expanded(flex: 1, child: meta),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[description, const SpaceH40(), meta],
              );
            }),
            const SpaceH32(),
            _ctaRow(project),
          ],
        ),
      ),
    );
  }

  Widget _metaPanel(ProjectItemData p, AppLang lang, double width) {
    final List<MapEntry<String, String>> rows = <MapEntry<String, String>>[
      MapEntry(Tr.of('meta.platform'), p.platformFor(lang)),
      MapEntry(Tr.of('meta.category'), p.categoryFor(lang)),
      if ((p.technologyFor(lang) ?? '').isNotEmpty)
        MapEntry(Tr.of('meta.technology'), p.technologyFor(lang)!),
      MapEntry(Tr.of('meta.status'),
          p.isLive ? Tr.of('meta.live') : Tr.of('meta.archived')),
    ];
    final TextStyle? labelStyle = Get.textTheme.bodyLarge?.copyWith(
      fontFamily: StringConst.INTER,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 2,
      color: CustomColors.grey600,
    );
    final TextStyle? valueStyle = Get.textTheme.bodyLarge?.copyWith(
      fontFamily: StringConst.INTER,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: CustomColors.black,
      height: 1.6,
    );
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: CustomColors.grey100.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CustomColors.grey300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < rows.length; i++) ...<Widget>[
            Text(rows[i].key.toUpperCase(), style: labelStyle),
            const SpaceH8(),
            Text(rows[i].value, style: valueStyle),
            if (i < rows.length - 1) const SpaceH20(),
          ],
        ],
      )
          .animate(controller: _aboutBodyController, autoPlay: false)
          .fadeIn(
            duration: const Duration(milliseconds: 1100),
            delay: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          )
          .slideY(
            begin: 0.35,
            end: 0,
            duration: const Duration(milliseconds: 1100),
            delay: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          )
          .slideX(
            begin: 0.04,
            end: 0,
            duration: const Duration(milliseconds: 1100),
            delay: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          ),
    );
  }

  Widget _ctaRow(ProjectItemData p) {
    if (p.webUrl.isEmpty && p.gitHubUrl.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 20,
      runSpacing: 16,
      children: <Widget>[
        if (p.webUrl.isNotEmpty)
          _PillButton(
            label: Tr.of('btn.open_live'),
            color: p.primaryColor,
            onTap: () => Functions.launchUrl(p.webUrl),
          ),
        if (p.gitHubUrl.isNotEmpty)
          _PillButton(
            label: Tr.of('btn.view_source'),
            color: CustomColors.black,
            onTap: () => Functions.launchUrl(p.gitHubUrl),
          ),
      ],
    );
  }

  // ---------- DECISIONS ----------
  Widget _decisionsSection(
      ProjectItemData p, AppLang lang, double width, double pad) {
    return VisibilityDetector(
      key: const Key('project-detail-decisions'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.20) _decisionsController.forward();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _sectionHeader(
              controller: _decisionsController,
              number: '/02',
              label: Tr.of('section.decisions'),
              heading: Tr.of('section.decisions_heading'),
              width: width,
            ),
            const SpaceH32(),
            ..._bulletList(p.decisionsFor(lang), _decisionsController, width),
          ],
        ),
      ),
    );
  }

  // ---------- LEARNINGS ----------
  Widget _learningsSection(
      ProjectItemData p, AppLang lang, double width, double pad) {
    return VisibilityDetector(
      key: const Key('project-detail-learnings'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.20) _learningsController.forward();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _sectionHeader(
              controller: _learningsController,
              number: '/03',
              label: Tr.of('section.learnings'),
              heading: Tr.of('section.learnings_heading'),
              width: width,
            ),
            const SpaceH32(),
            ..._bulletList(p.learningsFor(lang), _learningsController, width),
          ],
        ),
      ),
    );
  }

  List<Widget> _bulletList(
    List<String> items,
    AnimationController controller,
    double width,
  ) {
    final TextStyle? itemStyle = Get.textTheme.bodyLarge?.copyWith(
      fontFamily: StringConst.INTER,
      fontSize: responsiveSize(mobile: 15, desktop: 17),
      fontWeight: FontWeight.w300,
      color: CustomColors.grey800,
      height: 1.7,
    );
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Same arrow marker the experience + about pages use for
              // their roles — keeps the bullet vocabulary consistent
              // across every list in the site.
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 12),
                child: const Icon(
                  Icons.play_arrow_outlined,
                  color: CustomColors.black,
                  size: 16,
                )
                    .animate(controller: controller, autoPlay: false)
                    .fadeIn(
                      duration: const Duration(milliseconds: 400),
                      delay: Duration(milliseconds: 400 + i * 200),
                      curve: Curves.easeOut,
                    ),
              ),
              Expanded(
                child: Text.rich(
                  _markdownBoldSpan(items[i], itemStyle),
                  style: itemStyle,
                )
                    .animate(controller: controller, autoPlay: false)
                    .fadeIn(
                      duration: const Duration(milliseconds: 600),
                      delay: Duration(milliseconds: 600 + i * 200),
                      curve: Curves.easeOut,
                    )
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      duration: const Duration(milliseconds: 600),
                      delay: Duration(milliseconds: 600 + i * 200),
                      curve: Curves.easeOut,
                    ),
              ),
            ],
          ),
        ),
      );
    }
    return rows;
  }

  // ---------- TECHNICAL ----------
  // System diagrams / architecture sketches per project. Each entry has
  // an image + a short caption. The section is hidden automatically for
  // projects with an empty technicalImages list (see `if` guard in the
  // page's main ListView).
  Widget _technicalSection(
      ProjectItemData p, AppLang lang, double width, double pad) {
    final TextStyle? captionStyle = Get.textTheme.bodyLarge?.copyWith(
      fontFamily: StringConst.INTER,
      fontSize: responsiveSize(mobile: 14, desktop: 16),
      fontWeight: FontWeight.w300,
      color: CustomColors.grey700,
      height: 1.55,
      letterSpacing: 0.2,
    );
    return VisibilityDetector(
      key: const Key('project-detail-technical'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.12) _technicalController.forward();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _sectionHeader(
              controller: _technicalController,
              number: '/04',
              label: Tr.of('section.technical'),
              heading: Tr.of('section.technical_heading'),
              width: width,
            ),
            const SpaceH40(),
            for (int i = 0; i < p.technicalImages.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(height: 96),
              _TechnicalDiagram(
                image: p.technicalImages[i],
                index: i,
                accentColor: p.primaryColor,
                captionStyle: captionStyle,
                controller: _technicalController,
                maxWidth: width,
                lang: lang,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------- GALLERY ----------
  Widget _gallerySection(ProjectItemData p, double width, double pad) {
    return VisibilityDetector(
      key: const Key('project-detail-gallery'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.10) _galleryController.forward();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _sectionHeader(
              controller: _galleryController,
              number: '/05',
              label: Tr.of('section.shots'),
              heading: Tr.of('section.shots_heading'),
              width: width,
            ),
            const SpaceH40(),
            for (int i = 0; i < p.screenshots.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i == p.screenshots.length - 1 ? 0 : 80),
                child: DeviceMockup(
                  imageAsset: p.screenshots[i],
                  type: p.mockupType,
                  tiltLeft: i.isOdd,
                  maxWidth: width * 0.9,
                  maxHeight: responsiveSize(mobile: 420, desktop: 640),
                  scrollController: _scrollController,
                )
                    .animate(controller: _galleryController, autoPlay: false)
                    .fadeIn(
                      duration: const Duration(milliseconds: 900),
                      delay: Duration(milliseconds: 200 + i * 250),
                      curve: Curves.easeOut,
                    )
                    .slideY(
                      begin: 0.15,
                      end: 0,
                      duration: const Duration(milliseconds: 900),
                      delay: Duration(milliseconds: 200 + i * 250),
                      curve: Curves.easeOutCubic,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------- NEXT PROJECT ----------
  Widget _nextProjectSection(
    ProjectItemData next,
    AppLang lang,
    int nextIndex,
    double width,
    double pad,
  ) {
    return VisibilityDetector(
      key: const Key('project-detail-next'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.20) _nextProjectController.forward();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 80),
            AnimatedSlideBoxTransitionText(
              controller: _nextProjectController,
              text: Tr.of('btn.next_project'),
              textStyle: Get.textTheme.bodyLarge?.copyWith(
                fontFamily: StringConst.INTER,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
                color: CustomColors.grey700,
              ),
            ),
            const SizedBox(height: 24),
            Container(width: 56, height: 2, color: CustomColors.black),
            const SizedBox(height: 72),
            // The next-project tile itself: a soft card with explicit
            // internal padding (40pt) so the big title never touches
            // the surrounding container's edge.
            Material(
              color: CustomColors.grey100.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  // Use the same global cover / uncover transition every
                  // other navigation uses, and *replace* the current
                  // detail page so back never walks through a chain of
                  // visited projects.
                  PageTransition.goTo(
                    context,
                    '/projects/${next.slug}',
                    replace: true,
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveSize(mobile: 32, desktop: 72),
                    vertical: responsiveSize(mobile: 28, desktop: 48),
                  ),
                  child: LayoutBuilder(builder: (context, constraints) {
                    final bool wide = constraints.maxWidth > 800;
                    final double titleWidth = wide
                        ? (constraints.maxWidth - 40) * 0.55
                        : constraints.maxWidth;
                final Widget title = AnimatedSlideBoxTransitionText(
                  controller: _nextProjectController,
                  text: next.titleFor(lang),
                  width: titleWidth,
                  textStyle: Get.textTheme.displayMedium?.copyWith(
                    fontFamily: StringConst.VISUELT_PRO,
                    fontSize: responsiveSize(mobile: 28, desktop: 48),
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    color: CustomColors.black,
                  ),
                );
                final Widget cover = ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.asset(next.coverFor(lang), fit: BoxFit.cover),
                  ),
                )
                    .animate(controller: _nextProjectController, autoPlay: false)
                    .fadeIn(
                      duration: const Duration(milliseconds: 900),
                      delay: const Duration(milliseconds: 300),
                    )
                    .slideY(
                      begin: 0.15,
                      end: 0,
                      duration: const Duration(milliseconds: 900),
                      delay: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    );
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(child: title),
                      const SpaceW40(),
                      Expanded(child: cover),
                    ],
                  );
                }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[title, const SpaceH24(), cover],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Static descriptor for one tiny ambient signal dot on the hero. Kept
/// out of build() so the list literal doesn't get rebuilt on every
/// AnimationController tick.
class _HeroDot {
  const _HeroDot({required this.fx, required this.fy, required this.phase});

  /// Horizontal position as a fraction of the hero width.
  final double fx;
  /// Vertical position as a fraction of the hero height.
  final double fy;
  /// 0–1 phase offset into the global twinkle cycle.
  final double phase;
}

/// Static descriptor for one suspended-dust mote on the hero. Each mote
/// has its own period (in seconds) so the six dots never sync — the
/// `_heroMoteController` is a long parent timer and we remap its elapsed
/// seconds by [periodSec] per dot.
class _HeroMote {
  const _HeroMote({
    required this.fx,
    required this.fy,
    required this.periodSec,
    required this.phase,
  });

  /// Horizontal anchor as a fraction of the hero width.
  final double fx;
  /// Vertical anchor as a fraction of the hero height.
  final double fy;
  /// Full sine cycle length (seconds) for this mote's drift + opacity.
  final double periodSec;
  /// 0–1 phase offset so peaks don't all hit at t=0.
  final double phase;
}

/// Static descriptor for one crystalline pinpoint on the hero. The
/// pinpoint constellation (overlay 11) renders 1×1 px dots that twinkle
/// on a double-eased sine envelope; each pin has its own period so the
/// eight dots never sync, and a [white] flag picks between project tint
/// and pure white for higher-contrast pinpoints.
class _HeroPinpoint {
  const _HeroPinpoint({
    required this.fx,
    required this.fy,
    required this.periodSec,
    required this.phase,
    this.white = false,
  });

  /// Horizontal anchor as a fraction of the hero width.
  final double fx;
  /// Vertical anchor as a fraction of the hero height.
  final double fy;
  /// Full twinkle cycle length (seconds) for this pinpoint.
  final double periodSec;
  /// 0–1 phase offset so the eight pins never peak together.
  final double phase;
  /// When true, render white instead of `project.primaryColor`.
  final bool white;
}

/// Static descriptor for one slow-falling streak mote on the hero
/// (overlay 12). Each streak translates top → bottom over [periodSec]
/// seconds, fading in/out at the frame edges; [fx] picks the column.
class _HeroStreak {
  const _HeroStreak({
    required this.fx,
    required this.periodSec,
    required this.phase,
  });

  /// Horizontal column position as a fraction of the hero width.
  final double fx;
  /// Full top→bottom transit length (seconds) for this streak.
  final double periodSec;
  /// 0–1 phase offset so the four streaks stagger across the frame.
  final double phase;
}

/// Static descriptor for one pulsing micro-cross on the hero (overlay
/// 13). Each cross sits at a fixed fractional anchor and pulses its
/// scale + opacity on a sine envelope over [periodSec] seconds.
class _HeroCross {
  const _HeroCross({
    required this.fx,
    required this.fy,
    required this.periodSec,
    required this.phase,
  });

  /// Horizontal anchor as a fraction of the hero width.
  final double fx;
  /// Vertical anchor as a fraction of the hero height.
  final double fy;
  /// Full scale+alpha pulse length (seconds) for this cross.
  final double periodSec;
  /// 0–1 phase offset between the two crosses.
  final double phase;
}

/// Tiny inline-markdown parser used by the decisions / learnings bullet
/// lists. Recognises two markers:
///
///   - `**foo**` → bold (`FontWeight.w600`)
///   - `*foo*`   → italic (`FontStyle.italic`)
///
/// The bold pattern is tried first so a string like `**both**` is parsed
/// as bold rather than as two single-asterisk italic runs. Unpaired or
/// empty markers are dropped silently — a stray asterisk never leaks into
/// the rendered output.
TextSpan _markdownBoldSpan(String source, TextStyle? base) {
  final TextStyle? bold = base?.copyWith(fontWeight: FontWeight.w600);
  final TextStyle? italic = base?.copyWith(fontStyle: FontStyle.italic);
  final RegExp pattern = RegExp(
    r'\*\*(.+?)\*\*|\*(.+?)\*',
    dotAll: true,
  );
  final List<InlineSpan> children = <InlineSpan>[];
  int cursor = 0;
  for (final RegExpMatch m in pattern.allMatches(source)) {
    if (m.start > cursor) {
      children.add(TextSpan(text: source.substring(cursor, m.start)));
    }
    if (m.group(1) != null) {
      children.add(TextSpan(text: m.group(1), style: bold));
    } else if (m.group(2) != null) {
      children.add(TextSpan(text: m.group(2), style: italic));
    }
    cursor = m.end;
  }
  if (cursor < source.length) {
    children.add(TextSpan(text: source.substring(cursor)));
  }
  return TextSpan(style: base, children: children);
}


/// One row in the /04 TECHNICAL section: an architectural diagram with a
/// short caption underneath. Alternates a small horizontal nudge per
/// row so the section reads as a curated layout instead of a plain
/// column. Each row fades-in and slides up via the shared
/// `_technicalController` so they stagger naturally as the section
/// scrolls into view.
class _TechnicalDiagram extends StatelessWidget {
  const _TechnicalDiagram({
    required this.image,
    required this.index,
    required this.accentColor,
    required this.captionStyle,
    required this.controller,
    required this.maxWidth,
    required this.lang,
  });

  final TechnicalImage image;
  final int index;
  final Color accentColor;
  final TextStyle? captionStyle;
  final AnimationController controller;
  final double maxWidth;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    // Even rows shift slightly left, odd rows shift slightly right, so a
    // stack of diagrams alternates as a gentle zig-zag. The shift is
    // ~3% of the section width — enough to feel intentional, not so much
    // it crashes into the page padding.
    final double sideOffset = maxWidth * 0.025;
    final EdgeInsets nudge = index.isEven
        ? EdgeInsets.only(right: sideOffset * 1.6)
        : EdgeInsets.only(left: sideOffset * 1.6);

    return Padding(
      padding: nudge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.10),
                    blurRadius: 36,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  image.path,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
              .animate(controller: controller, autoPlay: false)
              .fadeIn(
                duration: const Duration(milliseconds: 900),
                delay: Duration(milliseconds: 200 + index * 240),
                curve: Curves.easeOut,
              )
              .slideY(
                begin: 0.10,
                end: 0,
                duration: const Duration(milliseconds: 900),
                delay: Duration(milliseconds: 200 + index * 240),
                curve: Curves.easeOutCubic,
              ),
          const SizedBox(height: 18),
          // The caption sits flush with the diagram on the side that
          // anchors the row, so the asymmetric nudge feels deliberate.
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth * 0.72),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 8, right: 14),
                  width: 28,
                  height: 2,
                  color: accentColor,
                ),
                Expanded(
                  child: Text(image.captionFor(lang), style: captionStyle),
                ),
              ],
            ),
          )
              .animate(controller: controller, autoPlay: false)
              .fadeIn(
                duration: const Duration(milliseconds: 700),
                delay: Duration(milliseconds: 500 + index * 240),
                curve: Curves.easeOut,
              ),
        ],
      ),
    );
  }
}
