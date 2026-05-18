import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/values/values.dart';
import '../../../utils/adaptive_layout.dart';
import '../../../utils/values/spaces.dart';
import '../../text/slide_box_transitioning_text.dart';
import 'app_logo.dart';
import 'language_switch.dart';
import 'top_navigation_item.dart';

class TopNavigationBar extends StatelessWidget {
  const TopNavigationBar({
    required this.controller,
    required this.selectedRouteTitle,
    required this.selectedRouteName,
    required this.onNavItemWebTap,
    this.hasSideTitle = true,
    this.onMenuTap,
    super.key,
  });

  final AnimationController controller;
  final String selectedRouteTitle;
  final String selectedRouteName;
  final bool hasSideTitle;
  final GestureTapCallback? onMenuTap;

  /// this handles navigation when on desktops
  final Function(String) onNavItemWebTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (Get.width < refinedBreakpoints.mobile) {
        /// Mobile Navigation Bar
        return Container(
          width: constraints.maxWidth,
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: <Widget>[
              const AppLogo(
                fontSize: Sizes.TEXT_SIZE_40,
              ),
              const Spacer(),
              InkWell(
                onTap: onMenuTap,
                child: const Icon(
                  Icons.menu,
                  size: Sizes.TEXT_SIZE_32,
                  color: CustomColors.black,
                ),
              ),
            ],
          ),
        );
      } else {
        /// Desktop Navigation Bar
        List<Widget> buildNavigationItems() {
          List<Widget> items = <Widget>[];
          for (int index = 0; index < Data.menuItems.length; index++) {
            items.add(
              TopNavigationItem(
                controller: controller,
                title: Data.menuItems[index].name,
                route: Data.menuItems[index].route,
                index: index + 1,
                isMobile: false,
                isSelected: Data.menuItems[index].route == selectedRouteName ? true : false,
                onTap: () {
                  onNavItemWebTap(Data.menuItems[index].route);
                },
              ),
            );
            items.add(const SpaceW16());
          }
          return items;
        }

        return Container(
          width: constraints.maxWidth,
          height: constraints.maxWidth,
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.PADDING_32,
            vertical: Sizes.PADDING_24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const AppLogo(),
                  const Spacer(),
                  ...buildNavigationItems(),
                  const LanguageSwitch(),
                  // DevButton(
                  //   height: Sizes.HEIGHT_36,
                  //   hasIcon: false,
                  //   width: 80,
                  //   buttonColor: AppColors.white,
                  //   borderColor: appLogoColor,
                  //   onHoverColor: appLogoColor,
                  //   title: StringConst.RESUME.toUpperCase(),
                  //   onPressed: () {
                  //     Functions.launchUrl(DocumentPath.CV);
                  //   },
                  // ),
                ],
              ),
              const Spacer(),
              hasSideTitle
                  ? RotatedBox(
                      quarterTurns: 3,
                      child: AnimatedSlideBoxTransitionText(
                        controller: controller,
                        text: selectedRouteTitle.toUpperCase(),
                        textStyle: Get.textTheme.bodyLarge?.copyWith(
                          color: CustomColors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: Sizes.TEXT_SIZE_12,
                        ),
                      ),
                    )
                  : const SizedBox(),
              const Spacer(),
            ],
          ),
        );
      }
    });
  }
}
