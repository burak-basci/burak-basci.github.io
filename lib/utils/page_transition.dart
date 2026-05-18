import 'package:flutter/material.dart';

import 'lang.dart';
import 'values/values.dart';

/// One global cover-panel that every page transition shares.
///
/// All navigation in the app routes through [PageTransition.goTo] or
/// [PageTransition.goBack]. Both follow the same three-step shape:
///
///   1. **cover**    — the black panel slides in from the left until the
///                     screen is fully covered.
///   2. **navigate** — pushNamed / pushReplacementNamed / pop happens while
///                     the screen is hidden under the panel.
///   3. **uncover**  — the panel slides off to the right and the new page
///                     is revealed.
///
/// Because the panel is one app-level widget, the new page never has to
/// coordinate with the previous page's animation controllers — there's no
/// "snap-back" flash on pop, no listener leak from rapid clicks, and the
/// transition feels identical regardless of which control triggered it.
///
/// A reentrancy guard ensures multiple back-to-back clicks queue cleanly
/// instead of stacking duplicate navigations.
/// Direction the cover panel is currently moving in. Used by
/// [PageTransitionOverlay] to pick the right translateX offset.
enum _CoverPhase { offstageLeft, covering, uncovering }

class PageTransition {
  PageTransition._();

  static AnimationController? _controller;
  static _CoverPhase _phase = _CoverPhase.offstageLeft;
  static bool _busy = false;

  /// Duration of one half (cover OR uncover) of a transition. Matches the
  /// 800 ms used by the original `PageLoadingSlider` so the page-to-page
  /// wipe feels exactly like it did before centralisation.
  static const Duration phaseDuration = Duration(milliseconds: 800);

  /// Called once by [PageTransitionOverlay] to wire the controller.
  static void attach(AnimationController controller) {
    _controller = controller;
  }

  /// Drop the reference so calls to [cover] / [uncover] after the overlay
  /// has been disposed turn into no-ops instead of crashing.
  static void detach() {
    _controller = null;
    _busy = false;
  }

  /// Whether a transition is currently in flight. Useful for things like
  /// the back button that should ignore taps while the panel is moving.
  static bool get isBusy => _busy;

  /// Current direction of the cover panel — read by the overlay to decide
  /// whether the panel sits offscreen-left, mid-cover, or sliding offscreen-
  /// right.
  static _CoverPhase get phase => _phase;

  /// Animate the panel in from the **left** until it fully covers the page.
  /// After this completes the panel sits flush against the visible area and
  /// the route change can fire under the cover.
  static Future<void> cover() async {
    final AnimationController? c = _controller;
    if (c == null) return;
    _phase = _CoverPhase.covering;
    c.value = 0;
    await c.forward();
  }

  /// Continue the same direction of travel: the panel slides *off to the
  /// right*, revealing the new page underneath. The previous cover phase
  /// ended with the panel flush over the screen; this phase moves it the
  /// rest of the way across.
  static Future<void> uncover() async {
    final AnimationController? c = _controller;
    if (c == null) return;
    _phase = _CoverPhase.uncovering;
    c.value = 0;
    await c.forward();
    // After uncovering, the panel is offstage on the right. The next cover
    // implicitly resets it to the offstage-left starting position via the
    // c.value = 0 above, so the visible motion is always strictly left →
    // right across the screen.
    _phase = _CoverPhase.offstageLeft;
  }

  /// Cover → navigate → uncover. Set [replace] to swap the current route
  /// instead of pushing a new entry onto the stack (e.g. for "next project"
  /// so back doesn't walk through every project ever visited).
  ///
  /// The [routeName] is the *logical* path (e.g. `/projects/foo`); the URL
  /// shown in the address bar is prefixed with `/de` automatically when
  /// the [LangController] is in German mode.
  static Future<void> goTo(
    BuildContext context,
    String routeName, {
    bool replace = false,
    Object? arguments,
  }) async {
    if (_busy) return;
    _busy = true;
    try {
      await cover();
      if (!context.mounted) return;
      final NavigatorState navigator = Navigator.of(context);
      final String localised = LangController.to.localiseRoute(routeName);
      if (replace) {
        unawaited(navigator.pushReplacementNamed(localised, arguments: arguments));
      } else {
        unawaited(navigator.pushNamed(localised, arguments: arguments));
      }
      // Let the framework mount the new page before we start uncovering.
      await Future<void>.delayed(const Duration(milliseconds: 40));
      await uncover();
    } finally {
      _busy = false;
    }
  }

  /// Cover → switch language + update URL → uncover. Stays on the same
  /// logical page; only the language prefix changes (and every
  /// language-aware widget rebuilds via [LangController]'s Rx).
  static Future<void> switchLanguage(
    BuildContext context,
    AppLang target,
  ) async {
    if (_busy) return;
    if (LangController.to.lang == target) return;
    _busy = true;
    try {
      // 1) Slide the cover in fully so the language swap happens with
      //    the screen hidden — no mid-animation flash of half-translated
      //    content.
      // 2) Once covered, swap the LangController and push the new
      //    localised URL. Every widget that reads `Tr.of` / `titleFor`
      //    rebuilds while the cover is still over the screen.
      // 3) Uncover to reveal the page already in the new language.
      //
      // The language-pill thumb is driven by its own local state and
      // starts animating immediately on click, so the visual confirm
      // happens before the cover hides the nav — see
      // language_switch.dart.
      await cover();
      if (!context.mounted) return;
      final String currentName =
          ModalRoute.of(context)?.settings.name ?? '/';
      final String logical = LangController.stripLangPrefix(currentName);
      LangController.to.setLang(target);
      final String localised = LangController.to.localiseRoute(logical);
      unawaited(Navigator.of(context).pushReplacementNamed(localised));
      await Future<void>.delayed(const Duration(milliseconds: 40));
      await uncover();
    } finally {
      _busy = false;
    }
  }

  /// Cover → pop → uncover. Falls back to a goTo home if there's nothing on
  /// the stack to pop to (e.g. user deep-linked directly to a project page).
  static Future<void> goBack(
    BuildContext context, {
    String fallbackRoute = '/',
  }) async {
    if (_busy) return;
    _busy = true;
    try {
      await cover();
      if (!context.mounted) return;
      final NavigatorState navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop();
      } else {
        unawaited(navigator.pushReplacementNamed(fallbackRoute));
      }
      await Future<void>.delayed(const Duration(milliseconds: 40));
      await uncover();
    } finally {
      _busy = false;
    }
  }
}

/// Fire-and-forget helper so we don't need an explicit `// ignore: unawaited_futures`
/// on every navigator call inside [PageTransition].
void unawaited(Future<void> _) {}

/// The widget that actually renders the cover panel above the rest of the
/// app. Mount it once at the root, typically via `MaterialApp.builder`.
class PageTransitionOverlay extends StatefulWidget {
  const PageTransitionOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<PageTransitionOverlay> createState() => _PageTransitionOverlayState();
}

class _PageTransitionOverlayState extends State<PageTransitionOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: PageTransition.phaseDuration,
      reverseDuration: PageTransition.phaseDuration,
      value: 0.0, // start uncovered — the home page's intro plays its own
      // local cover-and-reveal on first load, the global panel only steps
      // in once the user actually starts navigating between pages.
    );
    PageTransition.attach(_controller);
  }

  @override
  void dispose() {
    PageTransition.detach();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        widget.child,
        AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? _) {
            final double v = _controller.value;
            final _CoverPhase phase = PageTransition.phase;

            // This reproduces the original `PageLoadingSlider` exactly:
            //   * covering   → anchor centerLeft,  scaleX 0 → 1 with
            //                   easeInCubic. The panel wipes in from the
            //                   left edge, its right edge sweeping right.
            //   * uncovering → anchor centerRight, scaleX 1 → 0 with
            //                   easeOutQuart. The panel collapses toward
            //                   the right edge, revealing the page.
            //   * offstage   → not rendered.
            double scaleX;
            Alignment alignment;
            switch (phase) {
              case _CoverPhase.covering:
                scaleX = Curves.easeInCubic.transform(v);
                alignment = Alignment.centerLeft;
                break;
              case _CoverPhase.uncovering:
                scaleX = 1.0 - Curves.easeOutQuart.transform(v);
                alignment = Alignment.centerRight;
                break;
              case _CoverPhase.offstageLeft:
                return const SizedBox.shrink();
            }
            if (scaleX < 0.001) {
              return const SizedBox.shrink();
            }
            return IgnorePointer(
              ignoring: phase != _CoverPhase.covering || scaleX < 0.05,
              child: Transform(
                alignment: alignment,
                transform: Matrix4.identity()..scale(scaleX, 1.0),
                child: const SizedBox.expand(
                  child: ColoredBox(color: CustomColors.black),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

