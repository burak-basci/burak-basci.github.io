import "package:flutter/material.dart";

import '../../../utils/adaptive_layout.dart';
import '../../../utils/values/values.dart';
import '../../pages/home/home_page.dart';
import 'app_drawer.dart';
import 'loading_slider.dart';
import 'top_navigation_bar.dart';

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
    required this.selectedRoute,
    required this.selectedPageName,
    required this.navigationBarAnimationController,
    required this.child,
    this.customLoadingAnimation = const SizedBox(),
    this.onLoadingAnimationDone,
    this.hasSideTitle = true,
    this.hasUnveilPageAnimation = true,
    this.reverseAnimationOnPop = true,
    this.backgroundColor,
    this.navigationBarTitleColor = AppColors.grey600,
    this.navigationBarSelectedTitleColor = Colors.black,
    this.appLogoColor = Colors.black,
    Key? key,
  }) : super(key: key);

  final String selectedRoute;
  final String selectedPageName;
  final AnimationController navigationBarAnimationController;
  final VoidCallback? onLoadingAnimationDone;
  final Widget child;
  final Widget customLoadingAnimation;
  final bool hasSideTitle;
  final bool hasUnveilPageAnimation;
  final bool reverseAnimationOnPop;
  final Color? backgroundColor;
  final Color navigationBarTitleColor;
  final Color navigationBarSelectedTitleColor;
  final Color appLogoColor;

  @override
  PageWrapperState createState() => PageWrapperState();
}

class PageWrapperState extends State<PageWrapper> with TickerProviderStateMixin {
  late AnimationController forwardSlideController;
  late AnimationController unveilPageSlideController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final Duration duration = const Duration(milliseconds: 1000);

  loadPage() {
    forwardSlideController.forward();
    forwardSlideController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.onLoadingAnimationDone != null) {
          widget.onLoadingAnimationDone!();
        }
      }
    });
  }

  @override
  void initState() {
    forwardSlideController = AnimationController(
      vsync: this,
      duration: duration,
    );
    unveilPageSlideController = AnimationController(
      vsync: this,
      duration: duration,
    );

    if (widget.hasUnveilPageAnimation) {
      unveilPageSlideController.forward();
      unveilPageSlideController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (widget.onLoadingAnimationDone != null) {
            widget.onLoadingAnimationDone!();
          }
        }
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    forwardSlideController.dispose();
    unveilPageSlideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // simple hack to reverse animation when navigation is popped
    // I don't know if there's a better way to do this, but for now it works
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (forwardSlideController.isCompleted && widget.reverseAnimationOnPop) {
        forwardSlideController.reverse();
      }
    });

    return Scaffold(
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
            selectedRouteTitle: widget.selectedPageName,
            controller: widget.navigationBarAnimationController,
            selectedRouteName: widget.selectedRoute,
            hasSideTitle: widget.hasSideTitle,
            appLogoColor: widget.appLogoColor,
            titleColor: widget.navigationBarTitleColor,
            selectedTitleColor: widget.navigationBarSelectedTitleColor,
            onNavItemWebTap: (String route) {
              forwardSlideController.forward();
              forwardSlideController.addStatusListener((status) {
                if (status == AnimationStatus.completed) {
                  if (route == HomePage.homePageRoute) {
                    Navigator.of(context).pushNamed(
                      route,
                      arguments: NavigationArguments(
                        showUnVeilPageAnimation: true,
                      ),
                    );
                  } else {
                    Navigator.of(context).pushNamed(route);
                  }
                }
              });
            },
            onMenuTap: () {
              if (_scaffoldKey.currentState!.isEndDrawerOpen) {
                _scaffoldKey.currentState?.openEndDrawer();
              } else {
                _scaffoldKey.currentState?.openDrawer();
              }
            },
          ),
          LoadingSlider(
            controller: forwardSlideController,
            width: widthOfScreen(context),
            height: heightOfScreen(context),
          ),
          widget.hasUnveilPageAnimation
              ? Positioned(
                  right: 0,
                  child: LoadingSlider(
                    controller: unveilPageSlideController,
                    curve: Curves.fastOutSlowIn,
                    width: widthOfScreen(context),
                    height: heightOfScreen(context),
                    isSlideForward: false,
                  ),
                )
              : widget.customLoadingAnimation,
        ],
      ),
    );
  }
}
