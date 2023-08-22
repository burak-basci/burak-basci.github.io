// import 'package:flutter/material.dart';
//
// import '../../../utils/adaptive_layout.dart';
// import '../../../utils/values/values.dart';
// import '../animated_slide_transition.dart';
//
// class SlidingBanner extends StatefulWidget {
//   const SlidingBanner({Key? key}) : super(key: key);
//
//   @override
//   SlidingBannerState createState() => SlidingBannerState();
// }
//
// class SlidingBannerState extends State<SlidingBanner> with SingleTickerProviderStateMixin {
//   late AnimationController controller;
//
//   @override
//   void initState() {
//     controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 8000),
//     )..repeat();
//     controller.forward();
//     controller.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         controller.reset();
//         controller.forward();
//       }
//     });
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     TextTheme textTheme = Theme.of(context).textTheme;
//     return Container(
//       width: widthOfScreen(context),
//       height: assignHeight(context, 0.5),
//       color: AppColors.black,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           AnimatedSlideTransition(
//             controller: controller,
//             position: Tween<Offset>(
//               begin: Offset.fromDirection(0, 0),
//               end: Offset.fromDirection(1, 5),
//             ).animate(
//               CurvedAnimation(
//                 parent: controller,
//                 curve: Curves.ease,
//               ),
//             ),
//             child: Text(
//               "TITLE",
//               style: textTheme.headline3?.copyWith(
//                 color: AppColors.white,
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
