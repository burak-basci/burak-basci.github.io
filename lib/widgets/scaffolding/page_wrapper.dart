import "package:flutter/material.dart";

import '../../../utils/page_transition.dart';
import '../../../utils/values/values.dart';
import 'floating_back_button.dart';
import 'header/app_drawer.dart';
import 'header/top_navigation_bar.dart';

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
