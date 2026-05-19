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
/// browser sometimes routes the mouse-down to the content instead of
/// to the scrollbar drag, which opens links when the user is just
/// trying to scroll. Set ~2× the Scrollbar thickness used on the home
/// page (8 px) plus a small grab buffer.
///
/// IMPORTANT: this gutter is applied INSIDE the Scrollbar subtree, i.e.
/// the Scrollbar still spans the full viewport width and its thumb
/// stays flush against the right edge; only the scroll-view content
/// is inset. An earlier attempt wrapped [widget.child] in a
/// `Padding(right: 16)`, but because each page's own Scrollbar lives
/// inside [widget.child], that outer Padding shrank the Scrollbar's
/// bounds and pushed the thumb 16 px to the left of the viewport edge
/// — leaving a visible gap on the right and the thumb still hovering
/// over tile content. The fix injects a `MediaQuery.padding.right`
/// hint that descendant scroll views can consume (and which the
/// platform Scrollbar respects internally for its track inset), AND
/// overlays a transparent hit-absorber strip in the gutter zone so
/// stray clicks just left of the thumb do not fall through to a
/// project tile underneath.
const double _kDesktopScrollbarGutter = 16.0;

/// Scrollbar thumb thickness used on the home page (matches the
/// `thickness: 8.0` declared in `home_page.dart`). The hit-absorber
/// strip sits in `[_kHomeScrollbarThickness, _kDesktopScrollbarGutter]`
/// from the right edge so it never overlaps the thumb's drag area.
const double _kHomeScrollbarThickness = 8.0;

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
    //   1) `widget.child` is rendered at the full viewport width — no
    //      outer Padding — so the Scrollbar inside each page's subtree
    //      (e.g. home's `Scrollbar → SingleChildScrollView → Column`)
    //      keeps its right edge flush against the viewport. This is
    //      the fix for the regression where an outer `Padding(right:16)`
    //      shrank the Scrollbar's bounds and floated the thumb 16 px
    //      left of the viewport edge.
    //
    //   2) A transparent hit-absorber strip is overlaid in the gutter
    //      zone — between the rightmost edge of the Scrollbar thumb
    //      and the start of the desired content gutter — so any
    //      mouse-down just left of the thumb is swallowed instead of
    //      reaching a project tile underneath. The strip width is the
    //      gutter (16 px) minus the thumb thickness (8 px) so the
    //      strip never overlaps the thumb's own drag area.
    //
    // The visible content inside [widget.child] still extends to the
    // viewport's right edge today; the click-through bug is mitigated
    // by the absorber strip alone. Per-page Padding insets remain the
    // long-term home for visual inset, but cannot be applied from
    // here without reaching into each page's scroll subtree.
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > refinedBreakpoints.tablet;

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
            if (isDesktop)
              const Positioned(
                top: 0,
                bottom: 0,
                right: _kHomeScrollbarThickness,
                width: _kDesktopScrollbarGutter - _kHomeScrollbarThickness,
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
