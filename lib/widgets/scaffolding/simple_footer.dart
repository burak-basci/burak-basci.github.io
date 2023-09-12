import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../utils/adaptive_layout.dart';
import '../../../utils/functions.dart';
import '../../../utils/values/values.dart';
import '../../utils/values/spaces.dart';
import '../animated_line_through_text.dart';
import '../buttons/socials_icon_button.dart';

class SimpleFooter extends StatelessWidget {
  const SimpleFooter({
    Key? key,
    this.height,
    this.width,
    this.backgroundColor = AppColors.black,
  }) : super(key: key);

  final double? width;
  final double? height;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? widthOfScreen(context),
      height: height ?? assignHeight(context, 0.16),
      color: backgroundColor,
      child: Center(
        child: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            if (sizingInformation.isMobile) {
              return const Column(
                children: <Widget>[
                  Spacer(flex: 2),
                  SimpleFooterSmall(),
                  Spacer(),
                ],
              );
            } else {
              return const Column(
                children: <Widget>[
                  Spacer(),
                  SimpleFooterLarge(),
                  Spacer(),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class SimpleFooterSmall extends StatelessWidget {
  const SimpleFooterSmall({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? style = textTheme.bodyText1?.copyWith(
      color: AppColors.accentColor,
      fontSize: Sizes.TEXT_SIZE_14,
    );
    return Column(
      children: <Widget>[
        /// Socials
        SocialsIconButton(socialData: Data.socialData),
        const SpaceH30(),

        /// Privacy Policy
        PrivacyPolicyTextButton(style: style),
        const SpaceH12(),

        /// Copyright
        Text(
          StringConst.COPYRIGHT,
          style: style,
        ),
        const SpaceH2(),

        /// David and Julius Links
        CreditTextButtons(style: style),
        const SpaceH12(),

        const BuiltWithFlutterText(),
      ],
    );
  }
}

class SimpleFooterLarge extends StatefulWidget {
  const SimpleFooterLarge({
    Key? key,
  }) : super(key: key);

  @override
  State<SimpleFooterLarge> createState() => _SimpleFooterLargeState();
}

class _SimpleFooterLargeState extends State<SimpleFooterLarge> with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? style = textTheme.bodyText1?.copyWith(
      color: AppColors.accentColor,
      fontSize: Sizes.TEXT_SIZE_14,
    );
    return Column(
      children: <Widget>[
        /// Socials
        SocialsIconButton(socialData: Data.socialData),
        const SpaceH20(),

        /// Privacy Policy
        PrivacyPolicyTextButton(style: style),
        const SpaceH12(),

        /// David and Julius Links
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              StringConst.COPYRIGHT,
              style: style,
            ),
            const SpaceW8(),
            CreditTextButtons(style: style),
          ],
        ),

        const SpaceH12(),
        const BuiltWithFlutterText(),
      ],
    );
  }
}

class PrivacyPolicyTextButton extends StatelessWidget {
  const PrivacyPolicyTextButton({
    super.key,
    required this.style,
  });

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(StringConst.PRIVACY_POLICY_PAGE);
      },
      child: AnimatedLineThroughText(
        text: StringConst.PRIVACY_POLICY,
        isUnderlinedByDefault: true,
        isUnderlinedOnHover: false,
        hoverColor: AppColors.white,
        coverColor: AppColors.black,
        textStyle: style?.copyWith(
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

class CreditTextButtons extends StatelessWidget {
  const CreditTextButtons({
    super.key,
    required this.style,
  });

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        InkWell(
          onTap: () {
            Functions.launchUrl(StringConst.BASED_ON_LINK);
          },
          child: AnimatedLineThroughText(
            text: StringConst.BASED_ON,
            isUnderlinedByDefault: true,
            isUnderlinedOnHover: false,
            hoverColor: AppColors.white,
            coverColor: AppColors.black,
            textStyle: style?.copyWith(
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SpaceW8(),
        InkWell(
          onTap: () {
            Functions.launchUrl(StringConst.DESIGN_LINK);
          },
          child: AnimatedLineThroughText(
            text: StringConst.DESIGNED_BY,
            isUnderlinedByDefault: true,
            isUnderlinedOnHover: false,
            hoverColor: AppColors.white,
            coverColor: AppColors.black,
            textStyle: style?.copyWith(
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

class BuiltWithFlutterText extends StatelessWidget {
  const BuiltWithFlutterText({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? style = textTheme.bodyText1?.copyWith(
      color: AppColors.accentColor,
      fontSize: Sizes.TEXT_SIZE_14,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Text(
          StringConst.BUILT_WITH_FLUTTER,
          style: style,
        ),
        const FlutterLogo(size: 14),
        Text(
          " with ",
          style: style,
        ),
        const Icon(
          FontAwesomeIcons.solidHeart,
          size: 14,
          color: AppColors.errorRed,
        )
      ],
    );
  }
}
