import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../utils/functions.dart';
import '../../../../utils/i18n_strings.dart';
import '../../../../utils/page_transition.dart';
import '../../../../utils/values/values.dart';
import '../../../utils/adaptive_layout.dart';
import '../../../utils/values/spaces.dart';
import '../../buttons/animated_underline_text_button.dart';
import '../../buttons/socials_icon_button.dart';

class BottomPartFooter extends StatelessWidget {
  const BottomPartFooter({
    this.height,
    super.key,
  });

  /// Caller-supplied fixed height. The home page computes this once from
  /// the cached viewport and threads it through [FullFooter] so the dark
  /// bottom band never recomputes its own height from `Get.height` during
  /// scroll — that re-read used to jitter by 1 px and propagated up
  /// through the Column → ListView → maxScrollExtent, making the
  /// scrollbar thumb resize/jump at the cascade → footer transition.
  /// Falls back to the legacy `max(175, Get.height * 0.2)` when null.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final TextStyle? textStyle = Get.textTheme.bodyLarge?.copyWith(
      fontFamily: StringConst.INTER,
      color: CustomColors.accentColor,
      fontSize: Sizes.TEXT_SIZE_14,
      fontWeight: FontWeight.w300,
    );

    final double resolvedHeight =
        height ?? (Get.height * 0.2).clamp(175.0, double.infinity);
    return Container(
      width: Get.width,
      height: resolvedHeight,
      color: CustomColors.black,
      child: Center(
        child: Column(
          children: <Widget>[
            const Spacer(flex: 2),
            const SpaceH16(),

            /// Socials
            SocialIconButtonList(socialData: Data.socialData),
            const Spacer(),
            const SpaceH16(),

            /// Privacy Policy
            AnimatedUnderlineTextButton(
              text: Tr.of('footer.privacy_policy'),
              underlineColor: CustomColors.white,
              underlineBottomOffset: 0.0,
              textStyle: textStyle?.copyWith(
                decoration: TextDecoration.underline,
              ),
              onTap: () {
                PageTransition.goTo(context, StringConst.PRIVACY_POLICY_PAGE);
              },
            ),
            const SpaceH8(),

            LayoutBuilder(
              builder: (context, constraints) {
                if (Get.width > refinedBreakpoints.tablet) {
                  return Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            Tr.of('footer.copyright'),
                            style: textStyle,
                          ),

                          /// Julius Links
                          CreditTextButtons(style: textStyle)
                        ],
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: <Widget>[
                      Text(
                        Tr.of('footer.copyright'),
                        style: textStyle,
                      ),

                      /// Julius Links
                      CreditTextButtons(style: textStyle),
                    ],
                  );
                }
              },
            ),

            const SpaceH8(),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Text(
                  Tr.of('footer.built_with'),
                  style: textStyle,
                ),
                const FlutterLogo(size: 14),
                Text(
                  Tr.of('footer.built_with_love'),
                  style: textStyle,
                ),
                const Icon(
                  FontAwesomeIcons.solidHeart,
                  size: 14,
                  color: CustomColors.errorRed,
                )
              ],
            ),
            const SpaceH8(),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class CreditTextButtons extends StatelessWidget {
  const CreditTextButtons({
    required this.style,
    super.key,
  });

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          Tr.of('footer.based_on'),
          style: style,
        ),
        AnimatedUnderlineTextButton(
          text: StringConst.DESIGNED_BY,
          underlineColor: Colors.white,
          underlineBottomOffset: 0.0,
          textStyle: style?.copyWith(
            decoration: TextDecoration.underline,
          ),
          onTap: () {
            Functions.launchUrl(StringConst.DESIGN_LINK);
          },
        ),
      ],
    );
  }
}

class BuiltWithFlutterText extends StatelessWidget {
  const BuiltWithFlutterText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Get.textTheme.bodyLarge?.copyWith(
      fontFamily: StringConst.INTER,
      color: CustomColors.accentColor,
      fontSize: Sizes.TEXT_SIZE_14,
      fontWeight: FontWeight.w300,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Text(
          Tr.of('footer.built_with'),
          style: style,
        ),
        const FlutterLogo(size: 14),
        Text(
          Tr.of('footer.built_with_love'),
          style: style,
        ),
        const Icon(
          FontAwesomeIcons.solidHeart,
          size: 14,
          color: CustomColors.errorRed,
        )
      ],
    );
  }
}
