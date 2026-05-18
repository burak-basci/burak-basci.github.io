import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../../utils/i18n_strings.dart';
import '../../../../utils/values/values.dart';
import '../../buttons/animated_underline_text_button.dart';

class TopNavigationItemData {
  final String name;
  final String route;

  TopNavigationItemData({
    required this.name,
    required this.route,
  });
}

class TopNavigationItem extends StatefulWidget {
  const TopNavigationItem({
    required this.controller,
    required this.title,
    required this.route,
    required this.index,
    required this.isMobile,
    this.titleColor = CustomColors.grey600,
    this.isSelected = false,
    this.onTap,
    super.key,
  });

  final AnimationController controller;
  final String title;
  final String route;
  final int index;
  final bool isMobile;
  final Color titleColor;
  final bool isSelected;
  final GestureTapCallback? onTap;

  @override
  TopNavigationItemState createState() => TopNavigationItemState();
}

class TopNavigationItemState extends State<TopNavigationItem> with TickerProviderStateMixin {
  late AnimationController _hoverController;

  @override
  void initState() {
    _hoverController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the whole build tree in Obx so the underlying Tr.navLabel call
    // (which reads LangController.to.lang) rebuilds the nav item when
    // the user switches language.
    return Obx(() => _build(context));
  }

  Widget _build(BuildContext context) {
    if (widget.isMobile) {
      const double indexTextSize = 80;
      const double selectedTextSize = 36;
      const double unselectedTextSize = 36;

      void onMouseEnter(bool hovering) {
        if (hovering) {
          _hoverController.forward();
        } else {
          _hoverController.reverse();
        }
      }

      Widget buildMobileNavigationItemIndex({
        required int index,
        double? indexTextSize,
      }) {
        return Align(
          alignment: Alignment.center,
          child: Text(
            '0$index',
            style: Get.textTheme.displayMedium?.copyWith(
              fontSize: indexTextSize,
              color: CustomColors.grey800,
            ),
          ),
        );
      }

      return MouseRegion(
        onEnter: (e) => onMouseEnter(true),
        onExit: (e) => onMouseEnter(false),
        child: InkWell(
          onTap: widget.onTap,
          child: widget.isSelected

              /// Selected Mobile Navigation Button
              ? Stack(
                  children: <Widget>[
                    /// Selected Navigation Index
                    buildMobileNavigationItemIndex(
                      index: widget.index,
                      indexTextSize: indexTextSize,
                    ),

                    /// Selected Navigation Route Text
                    Container(
                      margin: const EdgeInsets.only(top: (indexTextSize - selectedTextSize) / 3),
                      child: Align(
                        alignment: Alignment.center,
                        child: AnimatedUnderlineText(
                          animationController: _hoverController,
                          underlineColor: CustomColors.white,
                          hoverTextColor: CustomColors.accentColor,
                          text: Tr.navLabel(widget.title).toLowerCase(),
                          textStyle: Get.textTheme.titleLarge?.copyWith(
                            fontSize: selectedTextSize,
                            color: CustomColors.accentColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                )

              /// Unselected Mobile Navigation Button
              : Stack(
                  children: <Widget>[
                    /// Unselected Navigation Index
                    buildMobileNavigationItemIndex(
                      index: widget.index,
                      indexTextSize: indexTextSize,
                    )
                        .animate(
                          controller: _hoverController,
                          autoPlay: false,
                        )
                        .fade(
                          begin: 0,
                          end: 1,
                          curve: Curves.easeOut,
                          duration: const Duration(milliseconds: 300),
                        ),

                    /// Unselected Navigation Route Text
                    Padding(
                      padding: const EdgeInsets.only(top: (indexTextSize - selectedTextSize) / 3),
                      child: Align(
                        alignment: Alignment.center,
                        child: AnimatedUnderlineText(
                          animationController: _hoverController,
                          underlineColor: CustomColors.white,
                          hoverTextColor: CustomColors.accentColor,
                          text: Tr.navLabel(widget.title).toLowerCase(),
                          textStyle: Get.textTheme.bodyLarge?.copyWith(
                            fontSize: unselectedTextSize,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      );

      /// Web Navigation Button
    } else {
      if (widget.isSelected) {
        return AnimatedUnderlineTextButton(
          text: Tr.navLabel(widget.title),
          hasSlideBoxAnimation: true,
          slideBoxController: widget.controller,
          textStyle: Get.textTheme.bodyLarge?.copyWith(
            fontSize: Sizes.TEXT_SIZE_16,
            color: CustomColors.black,
            fontWeight: FontWeight.w400,
          ),
          onTap: widget.onTap,
        );
      } else {
        return AnimatedUnderlineTextButton(
          text: Tr.navLabel(widget.title),
          hoverTextColor: CustomColors.black,
          textStyle: Get.textTheme.bodyLarge?.copyWith(
            fontSize: Sizes.TEXT_SIZE_16,
            color: widget.titleColor,
            fontWeight: FontWeight.w400,
          ),
          onTap: widget.onTap,
        );
      }
    }
  }
}
