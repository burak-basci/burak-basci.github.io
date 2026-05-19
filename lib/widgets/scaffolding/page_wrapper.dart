import "package:flutter/material.dart";

import '../../../utils/adaptive_layout.dart';
import '../../../utils/page_transition.dart';
import '../../../utils/values/values.dart';
import 'floating_back_button.dart';
import 'header/app_drawer.dart';
import 'header/top_navigation_bar.dart';

/// Pixel gutter every desktop page reserves on the right edge of its
/// scrollable content, INSIDE its own Scrollbar / scrollable viewport,
/// so the always-visible Scrollbar thumb sits in dead space and never
/// overlaps clickable content (project tiles, links, hover cards).
///
/// The gutter is realised per-page: each page wraps the child of its
/// `SingleChildScrollView` (or other scrollable) in a
/// `Padding(EdgeInsets.only(right: kDesktopScrollbarGutter))` on desktop.
/// This insets the inner content WITHOUT shifting the Scrollbar — the
/// Scrollbar still paints at the right edge of the scrollable's
/// viewport, but the content now ends `kDesktopScrollbarGutter` pixels
/// before the viewport's right edge. The thumb therefore occupies a
/// strip with no tile underneath, and a mouse-down on the thumb cannot
/// fall through to a tile.
///
/// Use [kDesktopScrollbarGutter] in every page that owns a scrollable
/// view; the helper [desktopScrollGutterPadding] returns an
/// [EdgeInsets] that is the gutter on desktop and zero on tablet /
/// mobile (where the platform scrollbar overlays or auto-hides and
/// using the full width is preferred).
///
/// Earlier attempts that wrapped `widget.child` in a Padding here in
/// PageWrapper failed: the padding shifted the entire scrollable —
/// Scrollbar and content together — left by the gutter, so the
/// Scrollbar continued to sit on top of tiles in its new position. The
/// gutter MUST be inserted between the scrollable's viewport and its
/// child so that only the content moves inward, not the scrollbar.
const double kDesktopScrollbarGutter = 24.0;

/// Convenience helper for pages: returns a right-inset gutter on
/// desktop and zero padding on smaller screens. Pages wrap the child
/// of their scrollable with `Padding(padding: desktopScrollGutterPadding(context), child: ...)`.
EdgeInsets desktopScrollGutterPadding(BuildContext context) {
  final double width = MediaQuery.of(context).size.width;
  final bool isDesktop = width > refinedBreakpoints.tablet;
  return isDesktop
      ? const EdgeInsets.only(right: kDesktopScrollbarGutter)
      : EdgeInsets.zero;
}

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
    // NOTE: the right-edge scrollbar gutter that prevents clicks from
    // falling through to tiles underneath the Scrollbar thumb is NOT
    // applied here — applying a Padding around `widget.child` shifts
    // both the content AND the scrollable's own Scrollbar inward by the
    // same amount, leaving the scrollbar still sitting directly on top
    // of the content. Instead, each page inserts a
    // `Padding(EdgeInsets.only(right: kDesktopScrollbarGutter))` BETWEEN
    // its scrollable (e.g. SingleChildScrollView) and the scrollable's
    // child column. That way the Scrollbar paints at the viewport's
    // true right edge while the content ends one gutter-width before
    // it, putting the thumb in genuinely empty dead space.
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
            widget.child,
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
