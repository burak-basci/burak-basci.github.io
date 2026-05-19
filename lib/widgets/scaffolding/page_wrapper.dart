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
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > refinedBreakpoints.tablet;
    final Widget scrollContent = isDesktop
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
            scrollContent,
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
