import "package:flutter/material.dart";

import '../../../utils/adaptive_layout.dart';
import '../../../utils/page_transition.dart';
import '../../../utils/values/values.dart';
import 'floating_back_button.dart';
import 'header/app_drawer.dart';
import 'header/top_navigation_bar.dart';

/// Pixel gutter reserved on the right edge of every page on desktop so
/// the always-visible Scrollbar thumb has uncontested click space.
/// Without this the right edge of clickable content (project tiles,
/// links, hover cards) extends underneath the Scrollbar gutter and the
/// browser routes the mouse-down to the content instead of letting
/// the user drag the scrollbar thumb, which opens links when the user
/// is just trying to scroll.
///
/// The gutter is realised by insetting [widget.child] with a
/// right Padding of [_kDesktopScrollbarGutter] on desktop, which
/// shifts every clickable widget — and the page's own Scrollbar with
/// it — left by the gutter width. The scrollbar thumb still paints on
/// the right edge of the padded child, so the thumb sits at
/// `[viewportWidth - gutter - thumbThickness, viewportWidth - gutter]`,
/// while the rightmost [_kDesktopScrollbarGutter] pixels of the
/// viewport contain no clickable content at all. A transparent
/// hit-absorber strip is then overlaid in those rightmost pixels so
/// any stray click in that empty band is swallowed and cannot fall
/// through to anything underneath.
///
/// An earlier attempt overlaid only an 8 px absorber strip at
/// `right: 8 .. right: 16` (just left of the thumb) WITHOUT padding
/// the child: the scrollbar thumb itself remained directly on top of
/// the project tiles, and a mouse-down on the thumb was still routed
/// to the tile because the Scrollbar's gesture recognizer only claims
/// drag gestures, not single taps — so the tap fell through to the
/// tile and opened the project page. The current implementation
/// removes that overlap entirely by physically shifting the tiles
/// inward by the gutter width.
const double _kDesktopScrollbarGutter = 16.0;

/// Lightweight nav-argument bag kept for backward-compat with call-sites
/// that still expect it. The actual cover/uncover panel lives in the
/// global [PageTransitionOverlay], so these flags are only used now to
/// tell the home page whether to play its first-load intro animation.
class NavigationArguments {
  bool showUnVeilPageAnimation;
  bool reverseAnimationOnPop;

  NavigationArguments({
    this.showUnVeilPageAnimation = true,
    this.reverseAnimationOnPop = true,
  });
}

class PageWrapper extends StatefulWidget {
  const PageWrapper({
    required this.navigationBarAnimationController,
    required this.selectedRoute,
    required this.selectedPageName,
    required this.child,
    this.hasSideTitle = true,
    this.backgroundColor,
    this.customLoadingAnimation = const SizedBox(),
    this.onLoadingAnimationDone,
    this.hasStandardPageUnveilAnimation = true,
    this.reverseUnveilPageAnimationOnPop = true,
    this.showFloatingBack = false,
    super.key,
  });

  final AnimationController navigationBarAnimationController;
  final String selectedRoute;
  final String selectedPageName;
  final Widget child;
  final bool hasSideTitle;
  final Color? backgroundColor;
  final Widget customLoadingAnimation;
  final VoidCallback? onLoadingAnimationDone;
  final bool hasStandardPageUnveilAnimation;
  final bool reverseUnveilPageAnimationOnPop;
  final bool showFloatingBack;

  @override
  PageWrapperState createState() => PageWrapperState();
}

class PageWrapperState extends State<PageWrapper> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  /// Cover → push → uncover (handled centrally). The route argument
  /// continues to carry [NavigationArguments] so the home page can decide
  /// whether to replay its intro animation when it remounts.
  void slideAndPushNamed(String routeName, {Object? arguments}) {
    PageTransition.goTo(context, routeName, arguments: arguments);
  }

  /// Convenience: find the nearest [PageWrapperState] and trigger the
  /// global page-transition. Always returns true now (kept for backward
  /// compatibility — older call-sites used the return value as a "no
  /// ancestor found" fallback signal).
  static bool slideAndPushNamedFrom(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    PageTransition.goTo(context, routeName, arguments: arguments);
    return true;
  }

  @override
  void initState() {
    super.initState();
    // Pages that opt into the standard unveil animation fire their
    // onLoadingAnimationDone callback shortly after the global uncover
    // begins, so in-page content animations can stagger in as the panel
    // slides away. Home overrides this path with its [customLoadingAnimation].
    if (widget.hasStandardPageUnveilAnimation &&
        widget.onLoadingAnimationDone != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Match roughly the moment the global panel starts uncovering —
        // cover phase is ~700 ms, then a 40 ms framework breather, so
        // ~750 ms after mount the screen is starting to reveal again.
        Future<void>.delayed(const Duration(milliseconds: 100), () {
          if (!mounted) return;
          widget.onLoadingAnimationDone?.call();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reserve a right-edge gutter on desktop so clickable page content
    // (project tiles, links, hover targets) never extends underneath
    // the always-visible Scrollbar thumb. On tablet / mobile the
    // platform scrollbar overlays or auto-hides and we want the
    // content to use the full width, so the gutter is desktop-only.
    //
    // The gutter is realised in two complementary layers:
    //
    //   1) `widget.child` is wrapped in `Padding(right: _gutter)` on
    //      desktop. This shifts every page's content — and the page's
    //      own Scrollbar with it — inward by [_kDesktopScrollbarGutter]
    //      pixels. The scrollbar thumb now paints on the right edge of
    //      the padded child, NOT on the right edge of the viewport, so
    //      there is no longer any tile content sitting underneath the
    //      thumb to receive a stray click.
    //
    //   2) A transparent hit-absorber strip is overlaid in the
    //      rightmost [_kDesktopScrollbarGutter] pixels of the viewport.
    //      Those pixels contain no clickable content (the child has
    //      been padded away from them) and no scrollbar thumb (the
    //      thumb sits LEFT of the gutter inside the padded child), so
    //      the absorber simply guarantees that any click in this empty
    //      band cannot fall through to the Scaffold body underneath.
    //
    // Earlier attempts that tried to absorb only the 8 px gap LEFT of
    // the thumb without padding the child failed because the thumb
    // itself overlapped tile content: a single tap on the thumb was
    // not claimed by the Scrollbar (Scrollbar's gesture recognizer
    // only wins drag gestures) and fell through to the tile, opening
    // the project page.
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > refinedBreakpoints.tablet;

    final Widget paddedChild = isDesktop
        ? Padding(
            padding: const EdgeInsets.only(right: _kDesktopScrollbarGutter),
            child: widget.child,
          )
        : widget.child;

    return SelectionArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: widget.backgroundColor,
        drawer: AppDrawer(
          controller: widget.navigationBarAnimationController,
          menuList: Data.menuItems,
          selectedItemRouteName: widget.selectedRoute,
        ),
        body: Stack(
          children: <Widget>[
            paddedChild,
            if (isDesktop)
              const Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                width: _kDesktopScrollbarGutter,
                child: _ScrollbarGutterHitAbsorber(),
              ),
            TopNavigationBar(
              controller: widget.navigationBarAnimationController,
              selectedRouteTitle: widget.selectedPageName,
              selectedRouteName: widget.selectedRoute,
              hasSideTitle: widget.hasSideTitle,
              onMenuTap: () {
                if (_scaffoldKey.currentState!.isEndDrawerOpen) {
                  _scaffoldKey.currentState?.openEndDrawer();
                } else {
                  _scaffoldKey.currentState?.openDrawer();
                }
              },
              onNavItemWebTap: (String route) {
                PageTransition.goTo(context, route);
              },
            ),
            // The home page passes a custom intro animation here; for
            // every other page the global PageTransitionOverlay is the
            // only cover layer, so this just renders nothing.
            if (!widget.hasStandardPageUnveilAnimation)
              widget.customLoadingAnimation,
            if (widget.showFloatingBack)
              FloatingBackButton(
                controller: widget.navigationBarAnimationController,
              ),
          ],
        ),
      ),
    );
  }
}

/// Invisible click-blocker that sits in the right-edge scrollbar
/// gutter and absorbs taps so they do not fall through to a project
/// tile sitting underneath. Uses a [GestureDetector] in opaque mode
/// so it intercepts tap / pan gestures aimed at the gutter strip
/// without registering as a [Listener] for [PointerSignalEvent]s —
/// that way mouse-wheel scroll events in the gutter still propagate
/// to the page's [Scrollable] via Flutter's [PointerSignalResolver].
class _ScrollbarGutterHitAbsorber extends StatelessWidget {
  const _ScrollbarGutterHitAbsorber();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // Show the default cursor in the gutter zone — no pointer hover
      // affordance leaks through to the tile underneath.
      cursor: SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: const SizedBox.expand(),
      ),
    );
  }
}
