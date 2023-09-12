// import 'package:flutter/material.dart';
// import 'package:responsive_builder/responsive_builder.dart';
//
// import '../../../../utils/adaptive_layout.dart';
// import '../../../../utils/values/values.dart';
// import '../../../utils/values/spaces.dart';
// import '../../../widgets/animations/animated_bubble_button.dart';
// import 'project_item.dart';
//
// class NextProject extends StatefulWidget {
//   const NextProject({
//     required this.width,
//     required this.nextProject,
//     this.navigateToNextProject,
//     Key? key,
//   }) : super(key: key);
//
//   final ProjectItemData nextProject;
//   final double width;
//   final VoidCallback? navigateToNextProject;
//
//   @override
//   NextProjectState createState() => NextProjectState();
// }
//
// class NextProjectState extends State<NextProject> with SingleTickerProviderStateMixin {
//   bool _isHovering = false;
//   late AnimationController controller;
//   late Animation<double> scaleAnimation;
//   @override
//   void initState() {
//     controller = AnimationController(
//       vsync: this,
//       duration: Animations.switcherDuration,
//     );
//     scaleAnimation = Tween(begin: 0.90, end: 1.0).animate(
//       CurvedAnimation(
//         parent: controller,
//         curve: Curves.fastOutSlowIn,
//       ),
//     );
//
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
//
//   void _mouseEnter(bool hovering) {
//     if (hovering) {
//       setState(() {
//         _isHovering = hovering;
//         controller.forward();
//       });
//     } else {
//       setState(() {
//         _isHovering = hovering;
//         controller.reverse();
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     TextTheme textTheme = Theme.of(context).textTheme;
//     const EdgeInsetsGeometry marginLeft = EdgeInsets.only(left: 16);
//     double projectTitleFontSize = responsiveSize(context, 28, 48, medium: 40, small: 36);
//     BorderRadiusGeometry borderRadius = const BorderRadius.all(
//       Radius.circular(100.0),
//     );
//     TextStyle? buttonStyle = textTheme.bodyText1?.copyWith(
//       color: AppColors.black,
//       fontSize: responsiveSize(
//         context,
//         Sizes.TEXT_SIZE_14,
//         Sizes.TEXT_SIZE_16,
//         small: Sizes.TEXT_SIZE_15,
//       ),
//       fontWeight: FontWeight.w500,
//     );
//     TextStyle? projectTitleStyle = textTheme.subtitle1?.copyWith(
//       color: AppColors.black,
//       fontSize: projectTitleFontSize,
//     );
//     return ResponsiveBuilder(
//       builder: (context, sizingInformation) {
//         double screenWidth = sizingInformation.screenSize.width;
//
//         if (screenWidth <= const RefinedBreakpoints().tabletSmall) {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               Text(
//                 StringConst.NEXT_PROJECT,
//                 style: textTheme.bodyText1?.copyWith(
//                   fontSize: responsiveSize(context, 11, Sizes.TEXT_SIZE_12),
//                   letterSpacing: 2,
//                   fontWeight: FontWeight.w300,
//                 ),
//               ),
//               const SpaceH20(),
//               Text(
//                 widget.nextProject.title,
//                 textAlign: TextAlign.center,
//                 style: projectTitleStyle,
//               ),
//               const SpaceH20(),
//               SizedBox(
//                 width: widthOfScreen(context),
//                 height: assignHeight(context, 0.3),
//                 child: Image.asset(
//                   widget.nextProject.coverUrl,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               const SpaceH30(),
//               AnimatedBubbleButton(
//                 title: StringConst.VIEW_PROJECT,
//                 color: AppColors.grey100,
//                 imageColor: AppColors.black,
//                 startBorderRadius: borderRadius,
//                 titleStyle: buttonStyle,
//                 startOffset: const Offset(0, 0),
//                 targetOffset: const Offset(0.1, 0),
//                 onTap: () {
//                   if (widget.navigateToNextProject != null) {
//                     widget.navigateToNextProject!();
//                   }
//                 },
//               ),
//             ],
//           );
//         } else {
//           return SizedBox(
//             height: assignHeight(context, 0.3),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 MouseRegion(
//                   onEnter: (e) => _mouseEnter(true),
//                   onExit: (e) => _mouseEnter(false),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     mainAxisSize: MainAxisSize.min,
//                     children: <Widget>[
//                       Container(
//                         margin: marginLeft,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           mainAxisSize: MainAxisSize.min,
//                           children: <Widget>[
//                             Text(
//                               StringConst.NEXT_PROJECT,
//                               style: textTheme.bodyText1?.copyWith(
//                                 fontSize: responsiveSize(
//                                   context,
//                                   11,
//                                   Sizes.TEXT_SIZE_12,
//                                 ),
//                                 letterSpacing: 2,
//                                 fontWeight: FontWeight.w300,
//                               ),
//                             ),
//                             const SpaceH20(),
//                             isDisplayMobileOrTablet(context)
//                                 ? Text(
//                                     widget.nextProject.title,
//                                     textAlign: TextAlign.center,
//                                     style: projectTitleStyle,
//                                   )
//                                 : AnimatedSwitcher(
//                                     duration: Animations.switcherDuration,
//                                     child: _isHovering
//                                         ? Text(
//                                             widget.nextProject.title,
//                                             textAlign: TextAlign.center,
//                                             style: projectTitleStyle,
//                                           )
//                                         : Stack(
//                                             children: <Widget>[
//                                               Text(
//                                                 widget.nextProject.title,
//                                                 textAlign: TextAlign.center,
//                                                 style: projectTitleStyle,
//                                               ),
//                                               Text(
//                                                 widget.nextProject.title,
//                                                 textAlign: TextAlign.center,
//                                                 style: projectTitleStyle?.copyWith(
//                                                   color: AppColors.white,
//                                                   fontSize: projectTitleFontSize - 0.25,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                   ),
//                           ],
//                         ),
//                       ),
//                       const SpaceH20(),
//                       AnimatedBubbleButton(
//                         title: StringConst.VIEW_PROJECT,
//                         color: AppColors.grey100,
//                         imageColor: AppColors.black,
//                         startBorderRadius: borderRadius,
//                         titleStyle: buttonStyle,
//                         startOffset: const Offset(0, 0),
//                         targetOffset: const Offset(0.1, 0),
//                         onTap: () {
//                           if (widget.navigateToNextProject != null) {
//                             widget.navigateToNextProject!();
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: widget.width * 0.15),
//                 Expanded(
//                   child: SizedBox(
//                     width: widget.width * 0.55,
//                     height: assignHeight(context, 0.3),
//                     child: ScaleTransition(
//                       scale: scaleAnimation,
//                       child: Image.asset(
//                         widget.nextProject.coverUrl,
//                         fit: BoxFit.cover,
//                         color: _isHovering ? Colors.transparent : Colors.grey,
//                         colorBlendMode: _isHovering ? BlendMode.color : BlendMode.saturation,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//       },
//     );
//   }
// }
