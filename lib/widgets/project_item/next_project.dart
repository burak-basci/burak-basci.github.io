import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../utils/adaptive_layout.dart';
import '../../utils/i18n_strings.dart';
import '../../utils/lang.dart';
import '../../utils/values/values.dart';
import '../../utils/values/spaces.dart';
import '../buttons/animated_bubble_button.dart';
import 'project_item.dart';

class NextProject extends StatefulWidget {
  const NextProject({
    required this.width,
    required this.nextProject,
    this.navigateToNextProject,
    Key? key,
  }) : super(key: key);

  final ProjectItemData nextProject;
  final double width;
  final VoidCallback? navigateToNextProject;

  @override
  NextProjectState createState() => NextProjectState();
}

class NextProjectState extends State<NextProject> with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: Animations.switcherDuration,
    );
    scaleAnimation = Tween(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.fastOutSlowIn,
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _mouseEnter(bool hovering) {
    if (hovering) {
      setState(() {
        _isHovering = hovering;
        controller.forward();
      });
    } else {
      setState(() {
        _isHovering = hovering;
        controller.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLang lang = LangController.to.lang;
    final String nextTitle = widget.nextProject.titleFor(lang);
    TextTheme textTheme = Theme.of(context).textTheme;
    const EdgeInsetsGeometry marginLeft = EdgeInsets.only(left: 16);
    double projectTitleFontSize = responsiveValue(context, 28, 48, medium: 40, small: 36);
    BorderRadiusGeometry borderRadius = const BorderRadius.all(
      Radius.circular(100.0),
    );
    TextStyle? buttonStyle = textTheme.bodyLarge?.copyWith(
      color: CustomColors.black,
      fontSize: responsiveValue(
      context,
        Sizes.TEXT_SIZE_14,
        Sizes.TEXT_SIZE_16,
        small: Sizes.TEXT_SIZE_15,
      ),
      fontWeight: FontWeight.w500,
    );
    TextStyle? projectTitleStyle = textTheme.titleMedium?.copyWith(
      color: CustomColors.black,
      fontSize: projectTitleFontSize,
    );
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        double screenWidth = sizingInformation.screenSize.width;

        if (screenWidth <= const RefinedBreakpoints().tabletSmall) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                Tr.of('btn.next_project'),
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: responsiveValue(context, 11, Sizes.TEXT_SIZE_12),
                  letterSpacing: 2,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SpaceH20(),
              Text(
                nextTitle,
                textAlign: TextAlign.center,
                style: projectTitleStyle,
              ),
              const SpaceH20(),
              SizedBox(
                width: widthOfScreen(context),
                height: assignHeight(context, 0.3),
                child: Image.asset(
                  widget.nextProject.coverFor(lang),
                  fit: BoxFit.cover,
                ),
              ),
              const SpaceH30(),
              AnimatedBubbleButton(
                title: Tr.of('btn.view_project'),
                color: CustomColors.grey100,
                imageColor: CustomColors.black,
                startBorderRadius: borderRadius,
                titleStyle: buttonStyle,
                startOffset: const Offset(0, 0),
                targetOffset: const Offset(0.1, 0),
                onTap: () {
                  if (widget.navigateToNextProject != null) {
                    widget.navigateToNextProject!();
                  }
                },
              ),
            ],
          );
        } else {
          return ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: assignHeight(context, 0.3),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MouseRegion(
                    onEnter: (e) => _mouseEnter(true),
                    onExit: (e) => _mouseEnter(false),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          margin: marginLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                Tr.of('btn.next_project'),
                                style: textTheme.bodyLarge?.copyWith(
                                  fontSize: responsiveValue(
      context,
                                    11,
                                    Sizes.TEXT_SIZE_12,
                                  ),
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SpaceH20(),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: isDisplayMobileOrTablet(context)
                                    ? Text(
                                        nextTitle,
                                        textAlign: TextAlign.center,
                                        style: projectTitleStyle,
                                      )
                                    : AnimatedSwitcher(
                                        duration: Animations.switcherDuration,
                                        child: _isHovering
                                            ? Text(
                                                nextTitle,
                                                textAlign: TextAlign.center,
                                                style: projectTitleStyle,
                                              )
                                            : Stack(
                                                children: <Widget>[
                                                  Text(
                                                    nextTitle,
                                                    textAlign: TextAlign.center,
                                                    style: projectTitleStyle,
                                                  ),
                                                  Text(
                                                    nextTitle,
                                                    textAlign: TextAlign.center,
                                                    style: projectTitleStyle?.copyWith(
                                                      color: CustomColors.white,
                                                      fontSize: projectTitleFontSize - 0.25,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        const SpaceH20(),
                        AnimatedBubbleButton(
                          title: Tr.of('btn.view_project'),
                          color: CustomColors.grey100,
                          imageColor: CustomColors.black,
                          startBorderRadius: borderRadius,
                          titleStyle: buttonStyle,
                          startOffset: const Offset(0, 0),
                          targetOffset: const Offset(0.1, 0),
                          onTap: () {
                            if (widget.navigateToNextProject != null) {
                              widget.navigateToNextProject!();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: widget.width * 0.15),
                  Expanded(
                    child: SizedBox(
                      width: widget.width * 0.55,
                      height: assignHeight(context, 0.3),
                      child: ScaleTransition(
                        scale: scaleAnimation,
                        child: Image.asset(
                          widget.nextProject.coverFor(lang),
                          fit: BoxFit.cover,
                          color: _isHovering ? Colors.transparent : Colors.grey,
                          colorBlendMode: _isHovering ? BlendMode.color : BlendMode.saturation,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
