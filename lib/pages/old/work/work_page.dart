// import 'package:flutter/material.dart';
// import 'package:responsive_builder/responsive_builder.dart';
//
// import '../../../utils/adaptive_layout.dart';
// import '../../../utils/functions.dart';
// import '../../../utils/values/values.dart';
// import '../../widgets/helper/custom_spacer.dart';
// import '../../widgets/scaffolding/animated_footer.dart';
// import '../../widgets/scaffolding/default_page_header.dart';
// import '../../widgets/scaffolding/page_wrapper.dart';
// import '../project_detail/widgets/project_item.dart';
// import 'widgets/noteworthy_projects.dart';
//
// class WorksPage extends StatefulWidget {
//   static const String worksPageRoute = StringConst.WORK_PAGE;
//   const WorksPage({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   WorksPageState createState() => WorksPageState();
// }
//
// class WorksPageState extends State<WorksPage> with TickerProviderStateMixin {
//   final ScrollController _scrollController = ScrollController();
//
//   late AnimationController _controller;
//   late AnimationController _headingTextController;
//
//   @override
//   void initState() {
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 200),
//     );
//     _headingTextController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     );
//
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _headingTextController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final double projectItemHeight = assignHeight(context, 0.4);
//     final double subHeight = (3 / 4) * projectItemHeight;
//     final double extra = projectItemHeight - subHeight;
//
//     final EdgeInsetsGeometry padding = EdgeInsets.only(
//       left: responsiveSize(
//         context,
//         assignWidth(context, 0.10),
//         assignWidth(context, 0.15),
//       ),
//       right: responsiveSize(
//         context,
//         assignWidth(context, 0.10),
//         assignWidth(context, 0.10),
//       ),
//     );
//     return PageWrapper(
//       selectedRoute: WorksPage.worksPageRoute,
//       selectedPageName: StringConst.WORK,
//       navigationBarAnimationController: _headingTextController,
//       hasSideTitle: false,
//       onLoadingAnimationDone: () {
//         _headingTextController.forward();
//       },
//       child: ListView(
//         controller: _scrollController,
//         padding: EdgeInsets.zero,
//         physics: const BouncingScrollPhysics(
//           parent: AlwaysScrollableScrollPhysics(),
//         ),
//         children: <Widget>[
//           DefaultPageHeader(
//             scrollController: _scrollController,
//             headingText: StringConst.WORK,
//             headingTextController: _headingTextController,
//           ),
//           ResponsiveBuilder(
//             builder: (context, sizingInformation) {
//               double screenWidth = sizingInformation.screenSize.width;
//
//               if (screenWidth <= const RefinedBreakpoints().tabletSmall) {
//                 return Column(
//                   children: _buildProjectsForMobile(
//                     data: Data.projects,
//                     projectHeight: projectItemHeight.toInt(),
//                     subHeight: subHeight.toInt(),
//                   ),
//                 );
//               } else {
//                 return SizedBox(
//                   height: (subHeight * (Data.projects.length)) + extra,
//                   child: Stack(
//                     children: _buildProjects(
//                       data: Data.projects,
//                       projectHeight: projectItemHeight.toInt(),
//                       subHeight: subHeight.toInt(),
//                     ),
//                   ),
//                 );
//               }
//             },
//           ),
//           const CustomSpacer(heightFactor: 0.1),
//           Padding(
//             padding: padding,
//             child: const NoteWorthyProjects(),
//           ),
//           const CustomSpacer(heightFactor: 0.15),
//           const AnimatedFooter(),
//         ],
//       ),
//     );
//   }
//
//   List<Widget> _buildProjects({
//     required List<ProjectItemData> data,
//     required int projectHeight,
//     required int subHeight,
//   }) {
//     List<Widget> items = <Widget>[];
//     int margin = subHeight * (data.length - 1);
//
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
// }
