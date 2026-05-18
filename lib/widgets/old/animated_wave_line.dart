// import 'package:flutter/material.dart';
//
// import '../../../utils/values/values.dart';
//
// class AnimatedWaveLine extends AnimatedWidget {
//   const AnimatedWaveLine({
//     required this.controller,
//     required this.height,
//     this.width = 1.5,
//     this.animation,
//     this.color = CustomColors.errorRed,
//     this.curve = Curves.fastOutSlowIn,
//     super.key,
//   }) : super(
//           listenable: controller,
//         );
//
//   final AnimationController controller;
//   final double height;
//   final double width;
//   final Color color;
//   final Curve curve;
//   final Animation<double>? animation;
//
//   Animation<double> get visibleAnimation =>
//       animation ??
//       Tween<double>(begin: 0, end: height).animate(
//         CurvedAnimation(
//           parent: controller,
//           curve: Interval(0.2, 0.8, curve: curve),
//         ),
//       );
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: width,
//       height: visibleAnimation.value,
//       color: color,
//     );
//   }
// }
