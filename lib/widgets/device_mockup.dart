import 'package:flutter/material.dart';

import '../utils/values/values.dart';

/// Cinematic device-frame wrapper for project screenshots.
///
/// `type` switches the visual frame:
///   - 'phone'        rounded-corner iPhone-style bezel with a notch
///   - 'laptop'       MacBook-style frame with a hinge sliver
///   - 'fullbleed'    no frame, just a soft shadow + rounded corners
///   - 'terminal'     window chrome with three traffic-light dots
///   - 'unreal-still' letter-boxed, slight grain, no bezel
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
      case 'laptop':
        frame = _laptopFrame();
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
    // 16:9 to match the 1600x900 source images so the placeholder
    // wordmark and any in-image text doesn't get cropped on the sides.
    return AspectRatio(
      aspectRatio: 16 / 9.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(color: Color(0x33000000), blurRadius: 40, offset: Offset(0, 22)),
                ],
                border: Border.all(color: const Color(0xFF1F1F1F), width: 3),
              ),
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(widget.imageAsset, fit: BoxFit.contain),
              ),
            ),
          ),
          Container(
            height: 14,
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Container(
                width: 80,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
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
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          boxShadow: <BoxShadow>[
            BoxShadow(color: Color(0x44000000), blurRadius: 36, offset: Offset(0, 18)),
          ],
        ),
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: Image.asset(widget.imageAsset, fit: BoxFit.cover)),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(height: 18, color: Colors.black),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(height: 18, color: Colors.black),
            ),
          ],
        ),
      ),
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
