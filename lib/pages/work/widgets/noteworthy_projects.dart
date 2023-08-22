import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../utils/adaptive_layout.dart';
import '../../../../utils/functions.dart';
import '../../../../utils/values/values.dart';
import '../../../utils/values/spaces.dart';
import '../../../widgets/animated_line_through_text.dart';
import '../../../widgets/animations/animated_positioned_text.dart';
import '../../../widgets/animations/animated_text_slide_box_transition.dart';

class NoteWorthyProjects extends StatefulWidget {
  const NoteWorthyProjects({Key? key}) : super(key: key);

  @override
  NoteWorthyProjectsState createState() => NoteWorthyProjectsState();
}

class NoteWorthyProjectsState extends State<NoteWorthyProjects> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    TextStyle? titleStyle = textTheme.subtitle1?.copyWith(
      color: AppColors.black,
      fontSize: responsiveSize(
        context,
        Sizes.TEXT_SIZE_20,
        Sizes.TEXT_SIZE_30,
      ),
    );
    TextStyle? bodyText1Style = textTheme.bodyText1?.copyWith(
      fontSize: responsiveSize(
        context,
        Sizes.TEXT_SIZE_16,
        Sizes.TEXT_SIZE_18,
      ),
      color: AppColors.grey750,
      fontWeight: FontWeight.w400,
      height: 2.0,
      // letterSpacing: 2,
    );

    return VisibilityDetector(
      key: const Key('noteworthy-projects'),
      onVisibilityChanged: (visibilityInfo) {
        double visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage > 25) {
          _controller.forward();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AnimatedTextSlideBoxTransition(
            heightFactor: 1.5,
            controller: _controller,
            text: StringConst.NOTE_WORTHY_PROJECTS,
            textStyle: titleStyle,
          ),
          const SpaceH16(),
          AnimatedPositionedText(
            controller: CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.6, 1.0, curve: Curves.fastOutSlowIn),
            ),
            text: StringConst.NOTE_WORTHY_PROJECTS_DESC,
            textStyle: bodyText1Style,
          ),
          const SpaceH40(),
          ..._buildNoteworthyProjects(Data.noteworthyProjects),
        ],
      ),
    );
  }

  List<Widget> _buildNoteworthyProjects(List<NoteWorthyProjectDetails> data) {
    List<Widget> items = <Widget>[];

    for (int index = 0; index < data.length; index++) {
      items.add(
        NoteWorthyProjectItem(
          controller: _controller,
          number: index + 1 > 9 ? "/${index + 1}" : "/0${index + 1}",
          projectName: data[index].projectName,
          onSourceTap: data[index].isPublic
              ? () {
                  Functions.launchUrl(data[index].gitHubUrl!);
                }
              : null,
          onProjectNameTap: data[index].isLive
              ? () {
                  data[index].isWeb
                      ? Functions.launchUrl(data[index].webUrl!)
                      : Functions.launchUrl(data[index].playStoreUrl!);
                }
              : (data[index].isPublic
                  ? () {
                      Functions.launchUrl(data[index].gitHubUrl!);
                    }
                  : null),
        ),
      );
      items.add(const SpaceH40());
    }

    return items;
  }
}

class NoteWorthyProjectItem extends StatelessWidget {
  const NoteWorthyProjectItem({
    required this.number,
    required this.projectName,
    required this.controller,
    this.source = "<src/>",
    this.numberStyle,
    this.projectNameStyle,
    this.sourceStyle,
    this.onSourceTap,
    this.onProjectNameTap,
    Key? key,
  }) : super(key: key);

  final String number;
  final String source;
  final String projectName;
  final AnimationController controller;
  final TextStyle? numberStyle;
  final TextStyle? sourceStyle;
  final TextStyle? projectNameStyle;
  final GestureTapCallback? onSourceTap;
  final GestureTapCallback? onProjectNameTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? defaultNumberStyle = textTheme.subtitle1?.copyWith(
      fontSize: Sizes.TEXT_SIZE_16,
      color: AppColors.grey550,
      fontWeight: FontWeight.w400,
    );
    final TextStyle? defaultSourceStyle = textTheme.subtitle1?.copyWith(
      fontSize: Sizes.TEXT_SIZE_16,
      color: AppColors.grey700,
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.underline,
    );
    final TextStyle? defaultProjectNameStyle = textTheme.subtitle1?.copyWith(
      fontSize: responsiveSize(
        context,
        Sizes.TEXT_SIZE_16,
        Sizes.TEXT_SIZE_20,
        small: Sizes.TEXT_SIZE_18,
      ),
      color: AppColors.black,
      fontWeight: FontWeight.w500,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AnimatedTextSlideBoxTransition(
          controller: controller,
          text: number,
          textStyle: numberStyle ?? defaultNumberStyle,
        ),
        const SpaceW20(),
        InkWell(
          onTap: onSourceTap,
          hoverColor: Colors.transparent,
          child: AnimatedTextSlideBoxTransition(
            controller: controller,
            text: source,
            textStyle: sourceStyle ?? defaultSourceStyle,
          ),
        ),
        const SpaceW20(),
        Flexible(
          child: AnimatedLineThroughText(
            maxLines: 3,
            width: assignWidth(context, 0.5),
            hasSlideBoxAnimation: true,
            controller: controller,
            text: projectName,
            onTap: onProjectNameTap,
            textStyle: projectNameStyle ?? defaultProjectNameStyle,
            isUnderlinedOnHover: false,
            isUnderlinedByDefault: true,
          ),
        ),
      ],
    );
  }
}
