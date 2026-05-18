import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSpacer extends StatelessWidget {
  const CustomSpacer({
    this.heightFactor,
    this.widthFactor,
    super.key,
  });

  final double? heightFactor;
  final double? widthFactor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height * (heightFactor ?? 0),
      width: Get.width * (widthFactor ?? 0),
    );
  }
}
