import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Cinematic device-frame wrapper for project screenshots.
///
/// `type` switches the visual frame:
///   - 'phone'        rounded-corner iPhone-style bezel with a notch
///   - 'tablet'       iPad-style frame: thin bezel all around + home pill
///   - 'laptop'       open-clamshell laptop — screen + flared keyboard base
///   - 'desktop'      external monitor on a centred stand + base foot
///   - 'fullbleed'    no frame, just a soft shadow + rounded corners
///   - 'terminal'     window chrome with three traffic-light dots
///   - 'unreal-still' cinema-monitor frame with visible bezel + base bar
///
/// When [scrollController] is provided, the mockup's tilt + Y-offset
/// are driven by the widget's position in the viewport: it enters
/// tilted up, levels out as it crosses centre, and tilts down as it
/// exits. Without a controller it just floats with the resting tilt.
class DeviceMockup extends StatefulWidget {
  const DeviceMockup({
    required this.imageAsset,
    this.type = 'phone',
    this.tiltLeft = false,
    this.maxHeight = 540,
    this.maxWidth = 920,
    this.scrollController,
    super.key,
  });

  final String imageAsset;
  final String type;
  final bool tiltLeft;
  final double maxHeight;
  final double maxWidth;
  final ScrollController? scrollController;

  @override
  State<DeviceMockup> createState() => _DeviceMockupState();
}

class _DeviceMockupState extends State<DeviceMockup> {
  /// Normalised viewport position of the widget centre, in [-1, 1]:
  ///   -1 = bottom of widget just below the top of the viewport
  ///    0 = widget perfectly centred
  ///   +1 = top of widget just above the bottom of the viewport
  double _scrollT = 0.0;
  final GlobalKey _key = GlobalKey();

  static const double _baseTiltY = 0.04; // resting Y rotation (radians)
  static const double _baseTiltX = 0.02; // resting X rotation (radians)
  static const double _scrollGainX = 0.08; // X rotation gain on scroll
  static const double _scrollDriftY = 10.0; // vertical drift in px

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void didUpdateWidget(covariant DeviceMockup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScroll);
      widget.scrollController?.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final RenderObject? ro = _key.currentContext?.findRenderObject();
    if (ro is! RenderBox || !ro.attached) return;
    final Offset topLeft = ro.localToGlobal(Offset.zero);
    final double widgetCentreY = topLeft.dy + ro.size.height / 2;
    final double viewportH = MediaQuery.of(context).size.height;
    // (-1, 1): widgetCentre below the top of the viewport on its
    // way in is negative; once past viewport centre it goes positive.
    final double t = ((widgetCentreY - viewportH / 2) / (viewportH / 2))
        .clamp(-1.5, 1.5);
    if ((t - _scrollT).abs() > 0.005) {
      setState(() => _scrollT = t);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget frame;
    switch (widget.type) {
      case 'phone':
        frame = _phoneFrame();
        break;
      case 'tablet':
        frame = _tabletFrame();
        break;
      case 'laptop':
        frame = _laptopFrame();
        break;
      case 'desktop':
        frame = _desktopFrame();
        break;
      case 'terminal':
        frame = _terminalFrame();
        break;
      case 'unreal-still':
        frame = _unrealFrame();
        break;
      case 'fullbleed':
      default:
        frame = _fullBleed();
    }

    final double restY = widget.tiltLeft ? _baseTiltY : -_baseTiltY;
    // X rotation: tilt down when the widget is above centre, tilt up
    // when it's below — invert because positive scrollT means the
    // widget has moved past viewport centre (i.e. user scrolled it
    // upward and is reading it).
    final double rotX = _baseTiltX + (-_scrollT * _scrollGainX);
    // Subtle vertical drift, opposite to the rotation, so the mockup
    // feels like a 3D card being read.
    final double dy = _scrollT * _scrollDriftY;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.maxWidth,
          maxHeight: widget.maxHeight,
        ),
        child: KeyedSubtree(
          key: _key,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: rotX, end: rotX),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            builder: (context, smoothRotX, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0011)
                  ..translate(0.0, dy)
                  ..rotateY(restY)
                  ..rotateX(smoothRotX),
                child: child,
              );
            },
            child: frame,
          ),
        ),
      ),
    );
  }

  Widget _phoneFrame() {
    return AspectRatio(
      aspectRatio: 9 / 19.5,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(44),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x33000000), blurRadius: 40, offset: Offset(0, 24)),
            BoxShadow(color: Color(0x22000000), blurRadius: 16, offset: Offset(0, 6)),
          ],
          border: Border.all(color: const Color(0xFF1A1A1A), width: 3),
        ),
        padding: const EdgeInsets.all(6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(38),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Image.asset(widget.imageAsset, fit: BoxFit.cover),
              ),
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 88,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _laptopFrame() {
    // Open-clamshell laptop: thick dark screen bezel sitting on top of a
    // wider, lighter keyboard base that flares 10% past the screen on
    // each side and ends in a rounded chassis lip. The screen itself
    // shows the image inside a recessed, slightly inset display panel.
    // The whole assembly is screen + base, so we size it from whichever
    // outer constraint (width or height) binds first to keep both
    // dimensions inside the surrounding ConstrainedBox.
    return LayoutBuilder(
      builder: (context, constraints) {
        const double screenAspect = 16 / 10; // MacBook-ish open clamshell
        const double baseHRatio = 0.045;      // base height vs width
        const double overhangRatio = 0.06;    // flare vs width
        const double totalRatio =
            1 / screenAspect + baseHRatio; // total height / width
        final double w = constraints.hasBoundedHeight
            ? math.min(constraints.maxWidth,
                constraints.maxHeight / totalRatio)
            : constraints.maxWidth;
        final double screenH = w / screenAspect;
        final double baseH = w * baseHRatio;
        final double baseOverhang = w * overhangRatio;
        return SizedBox(
          width: w,
          height: screenH + baseH,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // ---- Screen (closed top of clamshell) ----
              Container(
                width: w,
                height: screenH,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B0B0D),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                        color: Color(0x44000000),
                        blurRadius: 36,
                        offset: Offset(0, 18)),
                  ],
                  border: Border.all(
                      color: const Color(0xFF2A2A2D), width: 1.5),
                ),
                padding: EdgeInsets.fromLTRB(
                    w * 0.022, w * 0.022, w * 0.022, w * 0.022),
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          color: Colors.black,
                          child: Image.asset(widget.imageAsset,
                              fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    // Tiny camera dot on the top bezel.
                    Positioned(
                      top: -w * 0.011,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1A1A1A),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ---- Keyboard base (flares wider than the screen) ----
              SizedBox(
                width: w + baseOverhang * 2,
                height: baseH,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    // Soft contact-shadow under the chassis.
                    Positioned(
                      bottom: 0,
                      left: baseOverhang,
                      right: baseOverhang,
                      child: Container(
                        height: 4,
                        decoration: const BoxDecoration(
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 18,
                                offset: Offset(0, 10)),
                          ],
                        ),
                      ),
                    ),
                    // Chassis: light grey with a subtle vertical gradient
                    // so the hinge edge reads against the screen.
                    Container(
                      width: w + baseOverhang * 2,
                      height: baseH,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Color(0xFFB9BCC3),
                            Color(0xFF8A8E97),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        border: Border(
                          top: BorderSide(
                              color: Color(0xFF5A5D63), width: 1.2),
                        ),
                      ),
                      child: Center(
                        // The slim trackpad cutout — anchors the eye on
                        // "this is a laptop base, not just a bar".
                        child: Container(
                          width: w * 0.16,
                          height: baseH * 0.35,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7F838B),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tabletFrame() {
    // iPad-style frame: thin uniform bezel, a discrete camera dot on the
    // top edge, and a home-indicator pill near the bottom edge. Aspect
    // ratio matches a 12.9" iPad (4/3) so wide screenshots get gently
    // letterboxed instead of squashed.
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final double bezel = w * 0.018;
        return AspectRatio(
          aspectRatio: 4 / 3,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0E0E10),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 40,
                    offset: Offset(0, 22)),
                BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 12,
                    offset: Offset(0, 4)),
              ],
              border: Border.all(
                  color: const Color(0xFF1F1F22), width: 2),
            ),
            padding: EdgeInsets.all(bezel),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Container(
                      color: Colors.black,
                      child:
                          Image.asset(widget.imageAsset, fit: BoxFit.cover),
                    ),
                  ),
                  // Camera dot, top centre of the bezel area.
                  Positioned(
                    top: -bezel * 0.55,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1A1A1A),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _desktopFrame() {
    // External monitor — thick visible bezel, the chassis sits on a
    // short central neck plus a wider foot. Screen aspect 16/9, the
    // stand adds height beneath it. Reads unmistakably as a desk PC.
    return LayoutBuilder(
      builder: (context, constraints) {
        const double screenAspect = 16 / 9;
        const double neckHRatio = 0.04;
        const double footHRatio = 0.018;
        const double totalRatio =
            1 / screenAspect + neckHRatio + footHRatio;
        final double w = constraints.hasBoundedHeight
            ? math.min(constraints.maxWidth,
                constraints.maxHeight / totalRatio)
            : constraints.maxWidth;
        final double screenH = w / screenAspect;
        final double neckH = w * neckHRatio;
        final double footH = w * footHRatio;
        return SizedBox(
          width: w,
          height: screenH + neckH + footH,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // ---- Monitor body ----
              Container(
                width: w,
                height: screenH,
                decoration: BoxDecoration(
                  color: const Color(0xFF111114),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                        color: Color(0x44000000),
                        blurRadius: 40,
                        offset: Offset(0, 20)),
                  ],
                  border: Border.all(
                      color: const Color(0xFF2A2A2E), width: 1.5),
                ),
                padding: EdgeInsets.fromLTRB(
                    w * 0.014,
                    w * 0.014,
                    w * 0.014,
                    w * 0.030, // thicker bottom bezel (chin)
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Container(
                          color: Colors.black,
                          child: Image.asset(widget.imageAsset,
                              fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    // Tiny brand dot on the bottom bezel.
                    Positioned(
                      bottom: -w * 0.014,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: w * 0.018,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A3A3F),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ---- Stand neck (centred trapezoid-ish) ----
              Container(
                width: w * 0.10,
                height: neckH,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Color(0xFF2A2A2E),
                      Color(0xFF1A1A1D),
                    ],
                  ),
                ),
              ),
              // ---- Stand foot (wide base) ----
              Container(
                width: w * 0.32,
                height: footH,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1D),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 14,
                        offset: Offset(0, 8)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _terminalFrame() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0B0F12),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x44000000), blurRadius: 40, offset: Offset(0, 22)),
          ],
          border: Border.all(color: const Color(0xFF1A2329), width: 1),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: <Widget>[
            Container(
              height: 32,
              color: const Color(0xFF161B20),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: <Widget>[
                  _dot(const Color(0xFFFF5F57)),
                  const SizedBox(width: 8),
                  _dot(const Color(0xFFFFBD2E)),
                  const SizedBox(width: 8),
                  _dot(const Color(0xFF28C840)),
                ],
              ),
            ),
            Expanded(
              child: Image.asset(
                widget.imageAsset,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color color) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _unrealFrame() {
    // Cinema-monitor frame: a clearly visible dark chassis with a soft
    // grey rim around the display, a thicker bottom chin (where a brand
    // mark would sit on a real PC monitor), and a wide low-profile foot.
    // Used for cinematic/CGI stills (Unreal renders) so the image feels
    // mounted in a screen instead of floating in space.
    return LayoutBuilder(
      builder: (context, constraints) {
        const double screenAspect = 16 / 9;
        const double footHRatio = 0.022;
        const double gapRatio = 0.012;
        const double totalRatio =
            1 / screenAspect + footHRatio + gapRatio;
        final double w = constraints.hasBoundedHeight
            ? math.min(constraints.maxWidth,
                constraints.maxHeight / totalRatio)
            : constraints.maxWidth;
        final double screenH = w / screenAspect;
        final double footH = w * footHRatio;
        final double gap = w * gapRatio;
        return SizedBox(
          width: w,
          height: screenH + footH + gap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // ---- Monitor body ----
              Container(
                width: w,
                height: screenH,
                decoration: BoxDecoration(
                  color: const Color(0xFF101013),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                        color: Color(0x55000000),
                        blurRadius: 40,
                        offset: Offset(0, 20)),
                  ],
                  border: Border.all(
                      color: const Color(0xFF26262B), width: 1.5),
                ),
                padding: EdgeInsets.fromLTRB(
                    w * 0.012,
                    w * 0.012,
                    w * 0.012,
                    w * 0.028, // thicker bottom chin
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Container(
                          color: Colors.black,
                          child: Image.asset(widget.imageAsset,
                              fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    // Brand sliver on the chin.
                    Positioned(
                      bottom: -w * 0.013,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: w * 0.022,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFF40404A),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: gap),
              // ---- Foot bar (wide, low-profile) ----
              Container(
                width: w * 0.40,
                height: footH,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1F),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                        color: Color(0x44000000),
                        blurRadius: 14,
                        offset: Offset(0, 8)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _fullBleed() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x33000000), blurRadius: 32, offset: Offset(0, 18)),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Image.asset(widget.imageAsset, fit: BoxFit.cover),
      ),
    );
  }
}

// Silence unused-field warning while we keep the size cache around for
// future scroll-driven tilt work.
// ignore_for_file: unused_field
