import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:url_launcher/link.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../utils/adaptive_layout.dart';
import '../../../utils/functions.dart';
import '../../../utils/i18n_strings.dart';
import '../../../utils/intro_redirect.dart';
import '../../../utils/lang.dart';
import '../../../utils/page_transition.dart';
import '../../../utils/route_observers.dart';
import '../../../utils/values/values.dart';
import '../../data/projects.dart';
import '../../widgets/animations/slide_in_on_visible.dart';
import '../../widgets/project_item/project_item.dart';
import '../project_detail/project_detail_page.dart';
import '../../widgets/helper/custom_spacer.dart';
import '../../widgets/scaffolding/footer/full_footer.dart';
import '../../widgets/scaffolding/page_wrapper.dart';
import '../../widgets/text/slide_box_transitioning_text.dart';
import 'widgets/home_page_header.dart';
import 'widgets/initial_loading_page_animation.dart';

class HomePage extends StatefulWidget {
  static const String homePageRoute = StringConst.HOME_PAGE;

  const HomePage({
    super.key,
  });

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with TickerProviderStateMixin, RouteAware, WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  // late AnimationController _viewProjectsController;
  late AnimationController _recentWorksController;
  late AnimationController _headerTextController;
  late AnimationController _headerCircleController;
  late AnimationController _footerController;
  late NavigationArguments _arguments;

  /// Last known scroll offset, kept in sync via a listener on
  /// [_scrollController]. We mirror it onto this field so [didPopNext]
  /// has a stable target even if the position object briefly resets to 0
  /// when the home route re-activates after a project-detail pop.
  double _lastKnownOffset = 0.0;

  // --- Cached viewport-derived heights -------------------------------
  // Every section in the home cascade is sized as a fixed pixel value
  // derived from the viewport ONCE, and then frozen until the browser
  // viewport actually changes (handled in [didChangeMetrics]). Reading
  // `Get.height` mid-build during a scrollbar drag produces 1-pixel DPR
  // jitter that bubbles up to maxScrollExtent and visibly resizes the
  // scrollbar thumb; caching kills that source of jitter at the root.
  bool _heightsReady = false;
  late double _viewportHeight;
  late double _viewportWidth;
  late double _itemH;
  late double _subH;
  late double _headerH;
  late double _topSpacerH;
  late double _midSpacerH;
  late double _footerH;
  late double _bottomPartH;
  // Recent-works heading ("Crafted with love.") — the only cascade child
  // whose height was previously the *intrinsic* Column/TextPainter height.
  // TextPainter re-measures on every rebuild (and shifts by font-swap,
  // animation tick, DPR jitter), nudging maxScrollExtent and visibly
  // resizing the scrollbar thumb. Freezing it here matches the rest of
  // the cascade.
  late double _recentHeadingH;

  @override
  void initState() {
    _arguments = NavigationArguments();
    // _viewProjectsController = AnimationController(vsync: this);
    _headerTextController = AnimationController(vsync: this);
    _headerCircleController = AnimationController(vsync: this);
    _recentWorksController = AnimationController(vsync: this);
    _footerController = AnimationController(vsync: this);

    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final double px = _scrollController.position.pixels;
    if (px >= 0) _lastKnownOffset = px;
  }

  /// Compute and cache every viewport-derived height in one shot. Called
  /// once on first [didChangeDependencies] and again from
  /// [didChangeMetrics] when the browser viewport actually changes — never
  /// from the build path itself, so scroll-time rebuilds can't observe a
  /// freshly-resolved (and possibly DPR-jittered) `Get.height` mid-drag.
  void _recomputeHeights(Size size) {
    _viewportHeight = size.height;
    _viewportWidth = size.width;
    final double w = _viewportWidth;
    final double itemFactor = w < 600
        ? 0.40
        : w < 1023
            ? 0.40
            : w < 1439
                ? 0.42
                : 0.45;
    _itemH = _viewportHeight * itemFactor;
    _subH = _itemH * 0.72;
    _headerH = _viewportHeight * 0.92;
    _topSpacerH = _viewportHeight * 0.10;
    _midSpacerH = _viewportHeight * 0.05;
    final double rawFooter = _viewportHeight * 0.54;
    _footerH = rawFooter <= 450.0 ? 450.0 : rawFooter;
    _bottomPartH = (size.height * 0.2).clamp(175.0, double.infinity);
    // Mirror the responsive font ladder used for the "Crafted with love."
    // heading. Two lines × lineHeight (2.0) gives enough room for the
    // mobile wrap case while keeping the section size stable on every
    // rebuild — TextPainter's intrinsic measurement is no longer load-
    // bearing for maxScrollExtent.
    final double headingFs = w < 600
        ? 30.0
        : w < 1023
            ? 36.0
            : w < 1439
                ? 40.0
                : 48.0;
    _recentHeadingH = headingFs * 2.0 * 2.0;
    _heightsReady = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to the app-wide RouteObserver so [didPopNext] fires when
    // the user pops back to home from a detail page. Safe to call every
    // didChangeDependencies — [RouteObserver.subscribe] is idempotent for
    // the same (subscriber, route) pair.
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      appRouteObserver.subscribe(this, route);
    }
    // First-time resolve of the cached viewport heights. didChangeMetrics
    // takes over for subsequent browser resizes.
    if (!_heightsReady) {
      _recomputeHeights(MediaQuery.sizeOf(context));
    }
  }

  @override
  void didChangeMetrics() {
    // Browser viewport actually changed (resize, devtools toggle, etc.).
    // Recompute the cached heights and rebuild. This is the ONLY place
    // viewport metrics propagate into the cascade; everything else reads
    // the frozen cached values.
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final double dpr = view.devicePixelRatio;
    final Size physical = view.physicalSize;
    final Size logical = Size(physical.width / dpr, physical.height / dpr);
    if ((logical.height - _viewportHeight).abs() < 0.5 &&
        (logical.width - _viewportWidth).abs() < 0.5) {
      return;
    }
    setState(() => _recomputeHeights(logical));
  }

  @override
  void didPopNext() {
    // The detail page above us was just popped; this home route is the
    // top of the stack again. Restore the saved scroll offset *now*,
    // before the global cover panel finishes uncovering, so the page
    // never paints at 0 first. Clamped against maxScrollExtent in case
    // a viewport resize shrank the scrollable while we were away.
    super.didPopNext();
    if (!_scrollController.hasClients) return;
    if (_lastKnownOffset <= 0) return;
    final double max = _scrollController.position.maxScrollExtent;
    final double target = _lastKnownOffset.clamp(0.0, max);
    if ((_scrollController.position.pixels - target).abs() < 0.5) return;
    _scrollController.jumpTo(target);
  }

  void getArguments() {
    // Intro animation plays *once* per page session. After that, every
    // return to the home page — logo click, browser back, top-nav home,
    // pop from a detail page — uses the standard cross-page unveil. The
    // flag in IntroRedirect resets only on a hard refresh, which is also
    // when the user explicitly asked the intro to play again.
    if (IntroRedirect.hasPlayedIntro) {
      _arguments.showUnVeilPageAnimation = true;
      return;
    }
    final Object? args = ModalRoute.of(context)!.settings.arguments;
    if (args == null) {
      _arguments.showUnVeilPageAnimation = false;
    } else {
      _arguments = args as NavigationArguments;
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    // _viewProjectsController.dispose();
    _headerTextController.dispose();
    _headerCircleController.dispose();
    _recentWorksController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getArguments();
    // final double projectItemHeight = Get.height * 0.4;
    // final double subHeight = (3 / 4) * projectItemHeight;
    // final double extra = projectItemHeight - subHeight;
    // final TextTheme textTheme = Get.textTheme;
    // final TextStyle? textButtonStyle = textTheme.headlineMedium?.copyWith(
    //   color: AppColors.black,
    //   fontSize: responsiveSize(context, 30, 40, medium: 36, small: 32),
    //   height: 2.0,
    // );

    return PageWrapper(
      selectedRoute: HomePage.homePageRoute,
      selectedPageName: StringConst.HOME,
      navigationBarAnimationController: _headerTextController,
      hasSideTitle: false,
      hasStandardPageUnveilAnimation: _arguments.showUnVeilPageAnimation,
      onLoadingAnimationDone: () {
        _headerTextController.forward();
        _headerCircleController.forward();
      },
      customLoadingAnimation: LoadingHomePageAnimation(
        loadingText: StringConst.DEV_NAME,
        style: Get.textTheme.headlineMedium!.copyWith(color: CustomColors.white),
        onLoadingDone: () {
          IntroRedirect.markIntroPlayed();
          _headerTextController.forward();
          _headerCircleController.forward();
          // If the user arrived on a deep link, the URL was rewritten to
          // "/" at startup so the intro could play. Hold on the home page
          // for a comfortable beat so the user sees it settle, then ride
          // the global cover / uncover transition into where they were
          // actually going. Don't replace — leave home in the back stack
          // so the back button still returns here naturally.
          final String? deferred = IntroRedirect.consumeDeferred();
          if (deferred != null) {
            Future<void>.delayed(const Duration(milliseconds: 1100), () {
              if (!mounted) return;
              PageTransition.goTo(context, deferred);
            });
          }
        },
      ),
      child: Scrollbar(
        // Explicit Scrollbar with fixed thickness and a controller bound
        // to the same ScrollController as the ListView. The default
        // platform scrollbar (injected by MaterialScrollBehavior) reads
        // its thumb size from `position.maxScrollExtent` and `viewport`
        // every frame, so any image-decode-induced layout settle, font
        // metric reflow or viewport resize made the thumb visibly
        // rescale and jump mid-drag. Providing a Scrollbar ourselves
        // with `thumbVisibility: true` and a fixed thickness pins the
        // thumb to a stable visual size and stops the platform fallback
        // from overlaying a second, jumpier scrollbar on top.
        controller: _scrollController,
        thumbVisibility: true,
        thickness: 8.0,
        radius: const Radius.circular(4),
        // SingleChildScrollView + Column lays out the whole cascade in one
        // pass on first build, so `position.maxScrollExtent` is the total
        // content height from frame zero and never drifts as the user
        // scrolls. The previous `ListView` used Flutter's lazy
        // SliverChildListDelegate layout — children outside the cacheExtent
        // were not laid out yet, so maxScrollExtent grew when new sections
        // came into view AND shrank again when they left the cache on the
        // way back up, making the Scrollbar thumb visibly resize and pop
        // multiple times per scroll. Numbers from a captured [scroll]
        // log went 14347 → 16640 → 29463 → 16640 → 14347 across one
        // round trip; with SingleChildScrollView they stay constant.
        child: SingleChildScrollView(
          key: const PageStorageKey<String>('home-list'),
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
          HomePageHeader(
            scrollController: _scrollController,
            textController: _headerTextController,
            circleController: _headerCircleController,
            height: _headerH,
          ),
          SizedBox(height: _topSpacerH),
          // Heading section is force-sized so the animated text inside
          // (TextPainter-measured on every rebuild) cannot push or pull
          // the cascade's maxScrollExtent while its slide-box animation
          // plays. See [_recentHeadingH] for the height ladder.
          SizedBox(
            height: _recentHeadingH,
            child: VisibilityDetector(
            key: const Key('recent-projects'),
            onVisibilityChanged: (visibilityInfo) {
              if (visibilityInfo.visibleFraction > 0.25) {
                _recentWorksController.forward();
              }
            },
            child: LayoutBuilder(builder: (context, constraints) {
              final EdgeInsets margin = EdgeInsets.only(
                left: responsiveSize(
                  mobile: Get.width * 0.10,
                  tabletSmall: Get.width * 0.15,
                  desktop: Get.width * 0.15,
                ),
              );

              return Container(
                margin: margin,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AnimatedSlideBoxTransitionText(
                      controller: _recentWorksController,
                      text: Tr.of('home.crafted'),
                      width: Get.width * 0.70,
                      textStyle: Get.textTheme.headlineMedium?.copyWith(
                        color: CustomColors.black,
                        fontSize: responsiveSize(
                          mobile: 30,
                          tabletSmall: 36,
                          tabletNormal: 40,
                          desktop: 48,
                        ),
                        height: 2.0,
                      ),
                    ),
                    // const SpaceH16(),
                    // AnimatedPositionedText(
                    //   controller: CurvedAnimation(
                    //     parent: _recentWorksController,
                    //     curve: const Interval(0.6, 1.0, curve: Curves.fastOutSlowIn),
                    //   ),
                    //   text: StringConst.SELECTION,
                    //   textStyle: textTheme.bodyText1?.copyWith(
                    //     fontSize: responsiveSize(
                    //       context,
                    //       Sizes.TEXT_SIZE_16,
                    //       Sizes.TEXT_SIZE_18,
                    //     ),
                    //     height: 2,
                    //     fontWeight: FontWeight.w400,
                    //   ),
                    // ),
                  ],
                ),
              );
            }),
          ),
          ),
          SizedBox(height: _midSpacerH),
          LayoutBuilder(
            builder: (context, constraints) {
              // Use the State-cached heights so the cascade's total
              // height is invariant across rebuilds. Reading Get.height
              // here would re-resolve viewport metrics per build and
              // jitter maxScrollExtent during a scrollbar drag.
              final double itemH = _itemH;
              final double subH = _subH;
              final List<ProjectItemData> projects = recentWorks;
              final int n = projects.length;

              // Build cards top-down: card 0 added FIRST (bottom z),
              // card n-1 added LAST (top z). Each card's exclusive hit area
              // is its own visible header — the image-bottom is covered by
              // the next card both visually and for click testing.
              final LangController lc = Get.find<LangController>();
              return Obx(() {
                final AppLang lang = lc.lang;
                final List<Widget> cascade = <Widget>[];
                for (int i = 0; i < n; i++) {
                  final double topMargin = subH * i;
                  final String logical = '/projects/${projects[i].slug}';
                  final String displayUri = lc.localiseRoute(logical);
                  cascade.add(
                    Container(
                      margin: EdgeInsets.only(top: topMargin),
                      // SlideInOnVisible lets each tile animate in
                      // (fade + slide from the left, 60 px) the first
                      // time it crosses 15% visibility in the viewport,
                      // instead of all 33 tiles snapping into place at
                      // the moment the cascade enters view. The unique
                      // `ValueKey` per index is required by
                      // VisibilityDetector.
                      child: SlideInOnVisible(
                        uniqueKey: ValueKey<String>('cascade-$i'),
                        child: Link(
                        uri: Uri.parse(displayUri),
                        target: LinkTarget.self,
                        builder: (BuildContext context, FollowLink? _) {
                          return ProjectItemLarge(
                            projectNumber:
                                (i + 1) > 9 ? "${i + 1}" : "0${i + 1}",
                            imageUrl: projects[i].coverFor(lang),
                            hoverImageUrl: projects[i].coverColorUrl,
                            projectItemheight: itemH,
                            subheight: subH,
                            duration: const Duration(milliseconds: 900),
                            backgroundColor: CustomColors.accentColor2
                                .withValues(alpha: 0.35),
                            title: projects[i].titleFor(lang),
                            subtitle: projects[i].categoryFor(lang),
                            containerColor: projects[i].primaryColor,
                            onTap: () {
                              PageTransition.goTo(context, logical);
                            },
                          );
                        },
                        ),
                      ),
                    ),
                  );
                }
                return SizedBox(
                  width: double.infinity,
                  height: subH * (n - 1) + itemH,
                  child: Stack(children: cascade),
                );
              });
            },
          ),
          // ResponsiveBuilder(
          //   builder: (context, sizingInformation) {
          //     double screenWidth = sizingInformation.screenSize.width;
          //
          //     if (screenWidth <= const RefinedBreakpoints().tabletSmall) {
          //       return Column(
          //         children: _buildProjectsForMobile(
          //           data: Data.recentWorks,
          //           projectHeight: projectItemHeight.toInt(),
          //           subHeight: subHeight.toInt(),
          //         ),
          //       );
          //     } else {
          //       return SizedBox(
          //         height: (subHeight * (Data.recentWorks.length)) + extra,
          //         child: Stack(
          //           children: _buildRecentProjects(
          //             data: Data.recentWorks,
          //             projectHeight: projectItemHeight.toInt(),
          //             subHeight: subHeight.toInt(),
          //           ),
          //         ),
          //       );
          //     }
          //   },
          // ),
          // const CustomSpacer(heightFactor: 0.05),
          // Container(
          //   margin: margin,
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: <Widget>[
          //       Text(
          //         StringConst.THERES_MORE.toUpperCase(),
          //         style: textTheme.bodyText1?.copyWith(
          //           fontSize: responsiveSize(context, 11, Sizes.TEXT_SIZE_12),
          //           letterSpacing: 2,
          //           fontWeight: FontWeight.w300,
          //         ),
          //       ),
          //       const SpaceH16(),
          //       MouseRegion(
          //         onEnter: (e) => _viewProjectsController.forward(),
          //         onExit: (e) => _viewProjectsController.reverse(),
          //         child: AnimatedSlideTransition(
          //           controller: _viewProjectsController,
          //           beginOffset: const Offset(0, 0),
          //           targetOffset: const Offset(0.05, 0),
          //           child: TextButton(
          //             onPressed: () {
          //               // TOD O: Reimplement when WorksPage is ready
          //               Navigator.pushNamed(context, AboutPage.aboutPageRoute);
          //             },
          //             child: Row(
          //               mainAxisSize: MainAxisSize.min,
          //               crossAxisAlignment: CrossAxisAlignment.center,
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               children: <Widget>[
          //                 Text(
          //                   StringConst.VIEW_ALL_PROJECTS.toLowerCase(),
          //                   style: textButtonStyle,
          //                 ),
          //                 const SpaceW12(),
          //                 Container(
          //                   margin: EdgeInsets.only(top: textButtonStyle!.fontSize! / 2),
          //                   child: Image.asset(
          //                     ImagePath.ARROW_RIGHT,
          //                     width: 25,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          SizedBox(height: _viewportHeight * 0.15),
          VisibilityDetector(
            key: const Key('animated-footer'),
            onVisibilityChanged: (visibilityInfo) {
              if (visibilityInfo.visibleFraction > 0.25) {
                _footerController.forward();
              }
            },
            child: FullFooter(
              controller: _footerController,
              height: _footerH,
              bottomPartHeight: _bottomPartH,
            ),
          ),
          ],
          ),
        ),
      ),
    );
  }

//   List<Widget> _buildRecentProjects({
//     required List<ProjectItemData> data,
//     required int projectHeight,
//     required int subHeight,
//   }) {
//     List<Widget> items = <Widget>[];
//     int margin = subHeight * (data.length - 1);
//     for (int index = data.length - 1; index >= 0; index--) {
//       items.add(
//         Container(
//           margin: EdgeInsets.only(top: margin.toDouble()),
//           child: ProjectItemLarge(
//             projectNumber: index + 1 > 9 ? "${index + 1}" : "0${index + 1}",
//             imageUrl: data[index].image,
//             projectItemheight: projectHeight.toDouble(),
//             subheight: subHeight.toDouble(),
//             backgroundColor: AppColors.accentColor2.withOpacity(0.35),
//             title: data[index].title.toLowerCase(),
//             subtitle: data[index].category,
//             containerColor: data[index].primaryColor,
//             onTap: () {
//               Functions.navigateToProject(
//                 context: context,
//                 dataSource: data,
//                 currentProject: data[index],
//                 currentProjectIndex: index,
//               );
//             },
//           ),
//         ),
//       );
//       margin -= subHeight;
//     }
//     return items;
//   }
//
//   List<Widget> _buildProjectsForMobile({
//     required List<ProjectItemData> data,
//     required int projectHeight,
//     required int subHeight,
//   }) {
//     List<Widget> items = <Widget>[];
//
//     for (int index = 0; index < data.length; index++) {
//       items.add(
//         ProjectItemSm(
//           projectNumber: index + 1 > 9 ? "${index + 1}" : "0${index + 1}",
//           imageUrl: data[index].image,
//           title: data[index].title.toLowerCase(),
//           subtitle: data[index].category,
//           containerColor: data[index].primaryColor,
//           onTap: () {
//             Functions.navigateToProject(
//               context: context,
//               dataSource: data,
//               currentProject: data[index],
//               currentProjectIndex: index,
//             );
//           },
//         ),
//       );
//       items.add(const CustomSpacer(
//         heightFactor: 0.10,
//       ));
//     }
//     return items;
//   }
}
