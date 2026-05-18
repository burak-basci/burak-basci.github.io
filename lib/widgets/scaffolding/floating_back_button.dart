import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../utils/page_transition.dart';
import '../../utils/values/values.dart';

/// Top-left floating back button.
///
/// **At rest**: a perfect circle ([size] × [size]) with just the chevron.
/// **On hover**: smoothly widens into a pill that reveals the word *BACK*.
///
/// Tapping always routes through [PageTransition.goBack] so the screen
/// transitions identically to every other navigation: cover → pop →
/// uncover. The reentrancy guard in [PageTransition] also makes the
/// button safe to spam-click — extra taps during a transition no-op
/// instead of stacking listeners.
class FloatingBackButton extends StatefulWidget {
  const FloatingBackButton({
    super.key,
    this.controller,
    this.color = CustomColors.black,
    this.iconColor = Colors.white,
    this.size = 48,
    this.margin = const EdgeInsets.only(left: 32, top: 80),
  });

  final AnimationController? controller;
  final Color color;
  final Color iconColor;
  final double size;
  final EdgeInsets margin;

  @override
  State<FloatingBackButton> createState() => _FloatingBackButtonState();
}

class _FloatingBackButtonState extends State<FloatingBackButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final Widget core = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () {
          PageTransition.goBack(context);
        },
        // A single TweenAnimationBuilder drives the BACK-label reveal so it
        // slides into place as the pill widens — never out of sync with the
        // container's grow / shrink.
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: _hover ? 1 : 0),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          builder: (BuildContext context, double t, Widget? _) {
            return Container(
              height: widget.size,
              // At t=0 the container is a circle (size × size, only the
              // chevron inside). As t grows the inner BACK label widens via
              // the Align widthFactor; the outer container grows naturally
              // because the Row is mainAxisSize.min.
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(widget.size),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // The chevron sits in a fixed-size circular cap so the
                  // resting shape is a true circle.
                  SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: Center(
                      child: Icon(
                        Icons.chevron_left,
                        color: widget.iconColor,
                        size: widget.size * 0.5,
                      ),
                    ),
                  ),
                  ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: t,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 18),
                        child: Opacity(
                          opacity: t,
                          child: Text(
                            'BACK',
                            style: TextStyle(
                              color: widget.iconColor,
                              fontFamily: StringConst.INTER,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    final Widget animated = widget.controller != null
        ? core
            .animate(controller: widget.controller, autoPlay: false)
            .fadeIn(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            )
            .slideX(
              begin: -0.6,
              end: 0,
              duration: const Duration(milliseconds: 700),
              delay: const Duration(milliseconds: 400),
              curve: Curves.fastOutSlowIn,
            )
        : core;

    return Padding(
      padding: widget.margin,
      child: Align(
        alignment: Alignment.topLeft,
        child: animated,
      ),
    );
  }
}
