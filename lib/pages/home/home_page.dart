import "package:flutter/material.dart";
import 'package:visibility_detector/visibility_detector.dart';

import '../../../utils/adaptive_layout.dart';
import '../../../utils/values/values.dart';
import '../../widgets/animations/animated_text_slide_box_transition.dart';
import '../../widgets/helper/custom_spacer.dart';
import '../../widgets/scaffolding/animated_footer.dart';
import '../../widgets/scaffolding/page_wrapper.dart';
import 'widgets/home_page_header.dart';
import 'widgets/initial_loading_page.dart';

class HomePage extends StatefulWidget {
  static const String homePageRoute = StringConst.HOME_PAGE;

  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  GlobalKey key = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _viewProjectsController;
  late AnimationController _recentWorksController;
  late AnimationController _slideTextController;
  late NavigationArguments _arguments;

  @override
  void initState() {
    _arguments = NavigationArguments();
    _viewProjectsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideTextController = AnimationController(
      vsync: this,
      duration: Animations.slideAnimationDurationLong,
    );
    _recentWorksController = AnimationController(
      vsync: this,
      duration: Animations.slideAnimationDurationLong,
    );

    super.initState();
  }

  void getArguments() {
    final Object? args = ModalRoute.of(context)!.settings.arguments;
    // if page is being loaded for the first time, args will be null.
    // if args is null, I set boolean values to run the appropriate animation
    // In this case, if null run loading animation, if not null run the unveil animation
    if (args == null) {
      _arguments.showUnVeilPageAnimation = false;
    } else {
      _arguments = args as NavigationArguments;
    }
  }

  @override
  void dispose() {
    _viewProjectsController.dispose();
    _slideTextController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getArguments();
    final double projectItemHeight = assignHeight(context, 0.4);
    final double subHeight = (3 / 4) * projectItemHeight;
    final double extra = projectItemHeight - subHeight;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? textButtonStyle = textTheme.headline4?.copyWith(
      color: AppColors.black,
      fontSize: responsiveSize(context, 30, 40, medium: 36, small: 32),
      height: 2.0,
    );
    final EdgeInsets margin = EdgeInsets.only(
      left: responsiveSize(
        context,
        assignWidth(context, 0.10),
        assignWidth(context, 0.15),
        small: assignWidth(context, 0.15),
      ),
    );
    return PageWrapper(
      selectedRoute: HomePage.homePageRoute,
      selectedPageName: StringConst.HOME,
      navigationBarAnimationController: _slideTextController,
      hasSideTitle: false,
      hasUnveilPageAnimation: _arguments.showUnVeilPageAnimation,
      onLoadingAnimationDone: () {
        _slideTextController.forward();
      },
      customLoadingAnimation: LoadingHomePageAnimation(
        loadingText: StringConst.DEV_NAME,
        style: textTheme.headline4!.copyWith(color: AppColors.white),
        onLoadingDone: () {
          _slideTextController.forward();
        },
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        children: <Widget>[
          HomePageHeader(
            controller: _slideTextController,
            scrollToWorksKey: key,
          ),
          const CustomSpacer(heightFactor: 0.1),
          VisibilityDetector(
            key: const Key('recent-projects'),
            onVisibilityChanged: (visibilityInfo) {
              double visiblePercentage = visibilityInfo.visibleFraction * 100;
              if (visiblePercentage > 45) {
                _recentWorksController.forward();
              }
            },
            child: Container(
              key: key,
              margin: margin,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AnimatedTextSlideBoxTransition(
                    controller: _recentWorksController,
                    text: StringConst.CRAFTED_WITH_LOVE,
                    width: responsiveSize(
                      context,
                      assignWidth(context, 0.80),
                      assignWidth(context, 0.70),
                      small: assignWidth(context, 0.70),
                    ),
                    maxLines: 5,
                    textStyle: textTheme.headline4?.copyWith(
                      color: AppColors.black,
                      fontSize: responsiveSize(context, 30, 48, medium: 40, small: 36),
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
            ),
          ),
          const CustomSpacer(heightFactor: 0.1),
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
          //               // TODO: Reimplement when WorksPage is ready
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
          const CustomSpacer(heightFactor: 0.15),
          const AnimatedFooter(),
        ],
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
