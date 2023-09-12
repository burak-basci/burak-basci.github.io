import 'package:flutter/material.dart';

import '../../../utils/adaptive_layout.dart';
import '../../../utils/values/values.dart';
import '../animated_line_through_text.dart';

const double indicatorWidth = Sizes.WIDTH_60;

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
    required this.title,
    required this.route,
    required this.index,
    required this.controller,
    this.titleColor = AppColors.black100,
    this.selectedColor = AppColors.black,
    this.isSelected = false,
    this.isMobile = false,
    this.titleStyle,
    this.onTap,
    Key? key,
  }) : super(key: key);

  final String title;
  // final AnimationController controller;
  final int index;
  final String route;
  final TextStyle? titleStyle;
  final Color titleColor;
  final Color selectedColor;
  final bool isSelected;
  final bool isMobile;
  final AnimationController controller;
  final GestureTapCallback? onTap;

  @override
  TopNavigationItemState createState() => TopNavigationItemState();
}

class TopNavigationItemState extends State<TopNavigationItem> {
  bool _hovering = false;
  bool _hoveringUnselectedNavigationItemMobile = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => _mouseEnter(true),
      onExit: (e) => _mouseEnter(false),
      child: InkWell(
        onTap: widget.onTap,
        hoverColor: Colors.transparent,
        child: _buildNavigationItem(),
      ),
    );
  }

  void _mouseEnter(bool hovering) {
    setState(() {
      _hovering = hovering;
    });
  }

  void _onMouseEnterUnselectedNavigationItemMobile(bool hovering) {
    setState(() {
      _hoveringUnselectedNavigationItemMobile = hovering;
    });
  }

  Widget _buildNavigationItem() {
    return widget.isMobile ? mobileText() : desktopText();
  }

  Widget mobileText() {
    final TextTheme textTheme = Theme.of(context).textTheme;
    const double indexTextSize = 80;
    const double selectedTextSize = 36;
    const double unselectedTextSize = 36;
    return widget.isSelected
        ? Stack(
            children: <Widget>[
              _buildNavigationItemIndex(
                index: widget.index,
                indexTextSize: indexTextSize,
              ),
              Container(
                margin: const EdgeInsets.only(top: (indexTextSize - selectedTextSize) / 3),
                child: Align(
                  alignment: Alignment.center,
                  child: AnimatedLineThroughText(
                    text: widget.title.toLowerCase(),
                    isUnderlinedOnHover: false,
                    textStyle: widget.titleStyle ??
                        widget.titleStyle ??
                        textTheme.headline6?.copyWith(
                          fontSize: selectedTextSize,
                          color: AppColors.accentColor,
                          fontWeight: FontWeight.w400,
                        ),
                    hoverColor: AppColors.accentColor,
                    coverColor: AppColors.black,
                    lineThickness: 4,
                    onHoverTextStyle: textTheme.headline6?.copyWith(
                      fontSize: selectedTextSize,
                      color: AppColors.accentColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          )
        : MouseRegion(
            onEnter: (e) => _onMouseEnterUnselectedNavigationItemMobile(true),
            onExit: (e) => _onMouseEnterUnselectedNavigationItemMobile(false),
            child: Stack(
              children: <Widget>[
                AnimatedOpacity(
                  opacity: _hoveringUnselectedNavigationItemMobile ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.ease,
                  child: _buildNavigationItemIndex(
                    index: widget.index,
                    indexTextSize: indexTextSize,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: (indexTextSize - selectedTextSize) / 3),
                  child: Align(
                    alignment: Alignment.center,
                    child: AnimatedLineThroughText(
                      text: widget.title.toLowerCase(),
                      isUnderlinedOnHover: false,
                      textStyle: widget.titleStyle ??
                          textTheme.bodyText1?.copyWith(
                            fontSize: unselectedTextSize,
                            fontWeight: FontWeight.w400,
                          ),
                      hoverColor: AppColors.accentColor,
                      coverColor: AppColors.black,
                      lineThickness: 4,
                      onHoverTextStyle: textTheme.bodyText1?.copyWith(
                        fontSize: unselectedTextSize,
                        color: AppColors.accentColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget desktopText() {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double textSize = responsiveSize(
      context,
      Sizes.TEXT_SIZE_14,
      Sizes.TEXT_SIZE_16,
      medium: Sizes.TEXT_SIZE_15,
    );
    final TextStyle? defaultSelectedItemStyle = textTheme.bodyText1?.copyWith(
      fontSize: textSize,
      color: widget.selectedColor,
      fontWeight: FontWeight.w400,
    );
    final TextStyle? defaultUnselectedItemStyle = textTheme.bodyText1?.copyWith(
      fontSize: textSize,
      color: widget.titleColor,
    );

    return widget.isSelected
        ? AnimatedLineThroughText(
            text: widget.title,
            isUnderlinedOnHover: false,
            hasOffsetAnimation: true,
            hasSlideBoxAnimation: true,
            controller: widget.controller,
            textStyle: widget.titleStyle ?? defaultSelectedItemStyle,
          )
        : AnimatedLineThroughText(
            text: widget.title,
            isUnderlinedOnHover: false,
            hasOffsetAnimation: true,
            textStyle: widget.titleStyle ?? defaultUnselectedItemStyle,
            onHoverTextStyle: defaultUnselectedItemStyle?.copyWith(
              color: widget.selectedColor,
              fontWeight: FontWeight.w400,
            ),
          );
  }

  Widget _buildNavigationItemIndex({
    required int index,
    double? indexTextSize,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.center,
      child: Text(
        '0$index',
        style: widget.titleStyle ??
            textTheme.headline2?.copyWith(
              fontSize: indexTextSize,
              color: AppColors.grey800,
              // fontWeight: FontWeight.w400,
            ),
      ),
    );
  }
}
