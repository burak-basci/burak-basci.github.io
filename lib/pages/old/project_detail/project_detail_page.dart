// import 'package:flutter/material.dart';
// import 'package:visibility_detector/visibility_detector.dart';
//
// import '../../../utils/adaptive_layout.dart';
// import '../../../utils/functions.dart';
// import '../../../utils/values/values.dart';
// import '../../utils/values/spaces.dart';
// import '../../widgets/about_project.dart';
// import '../../widgets/animations/animated_text_slide_box_transition.dart';
// import '../../widgets/animations/animated_wave_line.dart';
// import '../../widgets/helper/custom_spacer.dart';
// import '../../widgets/scaffolding/page_wrapper.dart';
// import '../../widgets/scaffolding/simple_footer.dart';
// import 'widgets/next_project.dart';
// import 'widgets/project_item.dart';
//
// class ProjectDetailArguments {
//   final ProjectItemData data;
//   final List<ProjectItemData> dataSource;
//   final int currentIndex;
//   final ProjectItemData? nextProject;
//   final bool hasNextProject;
//
//   ProjectDetailArguments({
//     required this.dataSource,
//     required this.data,
//     required this.currentIndex,
//     required this.hasNextProject,
//     this.nextProject,
//   });
// }
//
// class ProjectDetailPage extends StatefulWidget {
//   static const String projectDetailPageRoute = StringConst.PROJECT_DETAIL_PAGE;
//   const ProjectDetailPage({Key? key}) : super(key: key);
//
//   @override
//   ProjectDetailPageState createState() => ProjectDetailPageState();
// }
//
// class ProjectDetailPageState extends State<ProjectDetailPage> with TickerProviderStateMixin {
//   late AnimationController _controller;
//   late AnimationController _waveController;
//   late AnimationController _aboutProjectController;
//   late AnimationController _projectDataController;
//   late ProjectDetailArguments projectDetails;
//   double waveLineHeight = 100;
//
//   @override
//   void initState() {
//     _waveController = AnimationController(
//       vsync: this,
//       duration: Animations.waveDuration,
//     )..repeat();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Animations.slideAnimationDurationLong,
//     );
//     _aboutProjectController = AnimationController(
//       vsync: this,
//       duration: Animations.slideAnimationDurationShort,
//     );
//     _waveController.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         _waveController.reverse();
//       } else if (status == AnimationStatus.dismissed) {
//         _waveController.forward();
//       }
//     });
//     _projectDataController = AnimationController(
//       vsync: this,
//       duration: Animations.slideAnimationDurationShort,
//     );
//     _waveController.forward();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _waveController.dispose();
//     _aboutProjectController.dispose();
//     _controller.dispose();
//     super.dispose();
//   }
//
//   ProjectDetailArguments getArguments() {
//     projectDetails = ModalRoute.of(context)!.settings.arguments as ProjectDetailArguments;
//     return projectDetails;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     getArguments();
//     final TextTheme textTheme = Theme.of(context).textTheme;
//     final TextStyle? coverTitleStyle = textTheme.headline2?.copyWith(
//       color: AppColors.white,
//       fontSize: 40,
//     );
//     final TextStyle? coverSubtitleStyle = textTheme.bodyText1?.copyWith(
//       color: AppColors.white,
//     );
//     final EdgeInsetsGeometry padding = EdgeInsets.only(
//       left: responsiveSize(
//         context,
//         assignWidth(context, 0.10),
//         assignWidth(context, 0.15),
//       ),
//       right: responsiveSize(
//         context,
//         assignWidth(context, 0.10),
//         assignWidth(context, 0.25),
//       ),
//     );
//     final double contentAreaWidth = responsiveSize(
//       context,
//       assignWidth(context, 0.60),
//       assignWidth(context, 0.80),
//     );
//     return PageWrapper(
//       backgroundColor: AppColors.white,
//       selectedRoute: ProjectDetailPage.projectDetailPageRoute,
//       hasSideTitle: false,
//       selectedPageName: StringConst.PROJECT,
//       navigationBarAnimationController: _controller,
//       navigationBarTitleColor: projectDetails.data.navTitleColor,
//       navigationBarSelectedTitleColor: projectDetails.data.navSelectedTitleColor,
//       appLogoColor: projectDetails.data.appLogoColor,
//       onLoadingAnimationDone: () {
//         _controller.forward();
//       },
//       child: ListView(
//         padding: EdgeInsets.zero,
//         physics: const BouncingScrollPhysics(
//           parent: AlwaysScrollableScrollPhysics(),
//         ),
//         children: <Widget>[
//           SizedBox(
//             width: widthOfScreen(context),
//             height: heightOfScreen(context),
//             child: Stack(
//               children: <Widget>[
//                 Image.asset(
//                   projectDetails.data.coverUrl,
//                   fit: BoxFit.cover,
//                   width: widthOfScreen(context),
//                   height: heightOfScreen(context),
//                 ),
//                 Container(
//                   margin: EdgeInsets.only(bottom: waveLineHeight + 40),
//                   child: Align(
//                     alignment: Alignment.bottomCenter,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: <Widget>[
//                         AnimatedTextSlideBoxTransition(
//                           controller: _controller,
//                           widthFactor: 1.20,
//                           text: "${projectDetails.data.title}.",
//                           coverColor: projectDetails.data.primaryColor,
//                           textStyle: coverTitleStyle,
//                           textAlign: TextAlign.center,
//                         ),
//                         const SpaceH20(),
//                         AnimatedTextSlideBoxTransition(
//                           controller: _controller,
//                           widthFactor: 1.20,
//                           text: projectDetails.data.category,
//                           coverColor: projectDetails.data.primaryColor,
//                           textStyle: coverSubtitleStyle,
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   child: Align(
//                     alignment: Alignment.bottomCenter,
//                     child: AnimatedWaveLine(
//                       height: waveLineHeight,
//                       controller: _waveController,
//                       color: projectDetails.data.primaryColor,
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//           const CustomSpacer(heightFactor: 0.15),
//           VisibilityDetector(
//             key: const Key('about-project'),
//             onVisibilityChanged: (visibilityInfo) {
//               double visiblePercentage = visibilityInfo.visibleFraction * 100;
//               if (visiblePercentage > 40) {
//                 _aboutProjectController.forward();
//               }
//             },
//             child: Padding(
//               padding: padding,
//               child: AboutProject(
//                 projectData: projectDetails.data,
//                 controller: _aboutProjectController,
//                 projectDataController: _projectDataController,
//                 width: contentAreaWidth,
//               ),
//             ),
//           ),
//           const CustomSpacer(heightFactor: 0.15),
//           ..._buildProjectAlbum(projectDetails.data.projectAssets),
//           projectDetails.hasNextProject ? const CustomSpacer(heightFactor: 0.15) : const SizedBox(),
//           projectDetails.hasNextProject
//               ? Padding(
//                   padding: padding,
//                   child: NextProject(
//                     width: contentAreaWidth,
//                     nextProject: projectDetails.nextProject!,
//                     navigateToNextProject: () {
//                       Functions.navigateToProject(
//                         context: context,
//                         dataSource: projectDetails.dataSource,
//                         currentProject: projectDetails.nextProject!,
//                         currentProjectIndex: projectDetails.currentIndex + 1,
//                       );
//                     },
//                   ),
//                 )
//               : const SizedBox(),
//           projectDetails.hasNextProject ? const CustomSpacer(heightFactor: 0.15) : const SizedBox(),
//           const SimpleFooter(),
//         ],
//       ),
//     );
//   }
//
//   List<Widget> _buildProjectAlbum(List<String> data) {
//     List<Widget> items = <Widget>[];
//
//     for (int index = 0; index < data.length; index++) {
//       items.add(
//         Image.asset(
//           data[index],
//           fit: BoxFit.cover,
//         ),
//       );
//     }
//
//     return items;
//   }
// }
