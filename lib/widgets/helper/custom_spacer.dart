import 'package:flutter/material.dart';

import '../../../utils/adaptive_layout.dart';

class CustomSpacer extends StatelessWidget {
  const CustomSpacer({
    this.widthFactor,
    this.heightFactor,
    Key? key,
  }) : super(key: key);

  final double? widthFactor;
  final double? heightFactor;

  @override
  Widget build(BuildContext context) {
    final double widthFraction = widthFactor ?? 0;
    final double heightFraction = heightFactor ?? 0;
    return SizedBox(
      width: assignWidth(context, widthFraction),
      height: assignHeight(context, heightFraction),
    );
  }
}
