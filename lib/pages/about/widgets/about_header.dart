import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../utils/adaptive_layout.dart';
import '../../../../utils/values/values.dart';
import '../../../utils/values/spaces.dart';
import 'about_header_description.dart';

class AboutHeader extends StatelessWidget {
  const AboutHeader({
    required this.width,
    required this.controller,
    Key? key,
  }) : super(key: key);

  final double width;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final double spacing = responsiveSize(
      context,
      width * 0.15,
      width * 0.15,
      medium: width * 0.05,
    );
    final double imageWidthLarge = responsiveSize(
      context,
      width * 0.3,
      width * 0.3,
      medium: width * 0.4,
    );
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        final double screenWidth = sizingInformation.screenSize.width;
        if (screenWidth <= const RefinedBreakpoints().tabletSmall) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AboutHeaderDescription(
                controller: controller,
                width: widthOfScreen(context),
              ),
              const SpaceH30(),
              ClipRRect(
                borderRadius: BorderRadius.circular(80),
                child: Image.asset(
                  ImagePath.DEV,
                  fit: BoxFit.cover,
                  width: widthOfScreen(context),
                  height: assignHeight(context, 0.45),
                ),
              ),
            ],
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              AboutHeaderDescription(
                controller: controller,
                width: width * 0.55,
              ),
              SizedBox(
                width: spacing,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(80.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: imageWidthLarge,
                    minWidth: imageWidthLarge,
                    maxHeight: assignHeight(context, 0.55),
                  ),
                  child: Image.asset(
                    ImagePath.DEV,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
