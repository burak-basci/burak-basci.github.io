import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/i18n_strings.dart';
import '../../../../utils/page_transition.dart';
import '../../../../utils/values/values.dart';
import '../../../utils/values/spaces.dart';
import '../../buttons/socials_icon_button.dart';
import 'app_logo.dart';
import 'top_navigation_item.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({
    required this.controller,
    required this.menuList,
    required this.selectedItemRouteName,
    super.key,
  });

  final AnimationController controller;
  final List<TopNavigationItemData> menuList;
  final String selectedItemRouteName;

  @override
  AppDrawerState createState() => AppDrawerState();
}

class AppDrawerState extends State<AppDrawer> with TickerProviderStateMixin {
  static const Duration _initialDelayTime = Duration(milliseconds: 50);
  static const Duration _itemSlideTime = Duration(milliseconds: 400);
  static const Duration _staggerTime = Duration(milliseconds: 50);
  static const Duration _buttonDelayTime = Duration(milliseconds: 100);
  static const Duration _buttonTime = Duration(milliseconds: 400);
  late Duration _animationDuration;

  late AnimationController _staggeredController;
  final List<Interval> _itemSlideIntervals = <Interval>[];

  @override
  void initState() {
    _animationDuration =
        _initialDelayTime + (_staggerTime * widget.menuList.length) + _buttonDelayTime + _buttonTime;
    _createAnimationIntervals();

    _staggeredController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..forward();
    super.initState();
  }

  void _createAnimationIntervals() {
    for (var i = 0; i < widget.menuList.length; ++i) {
      final startTime = _initialDelayTime + (_staggerTime * i);
      final endTime = startTime + _itemSlideTime;
      _itemSlideIntervals.add(
        Interval(
          startTime.inMilliseconds / _animationDuration.inMilliseconds,
          endTime.inMilliseconds / _animationDuration.inMilliseconds,
        ),
      );
    }
  }

  @override
  void dispose() {
    _staggeredController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      height: Get.height,
      child: Drawer(
        backgroundColor: CustomColors.black,
        surfaceTintColor: CustomColors.black,
        shape: const RoundedRectangleBorder(),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(Sizes.PADDING_24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      const AppLogo(
                        fontSize: Sizes.TEXT_SIZE_40,
                        titleColor: CustomColors.accentColor,
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => Get.back(),
                        child: const Icon(
                          Icons.close,
                          size: Sizes.ICON_SIZE_30,
                          color: CustomColors.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Spacer(),
                      ..._buildMenuList(menuList: widget.menuList, context: context),
                      const Spacer(),
                    ],
                  ),
                ),
                Text(
                  Tr.of('footer.copyright2'),
                  style: Get.textTheme.bodyLarge?.copyWith(
                    color: CustomColors.grey500,
                    fontSize: Sizes.TEXT_SIZE_10,
                  ),
                ),
                const SpaceH20(),
              ],
            ),
            Positioned(
              bottom: 0,
              child: Container(
                margin: const EdgeInsets.only(
                  left: 24.0,
                  bottom: 0,
                ),
                child: SocialIconButtonList(
                  socialData: Data.socialData,
                  size: 18,
                  isHorizontal: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMenuList({
    required BuildContext context,
    required List<TopNavigationItemData> menuList,
  }) {
    List<Widget> menuItems = <Widget>[];
    for (int index = 0; index < menuList.length; index++) {
      menuItems.add(
        AnimatedBuilder(
          animation: _staggeredController,
          builder: (context, child) {
            final animationPercent = Curves.easeOut.transform(
              _itemSlideIntervals[index].transform(_staggeredController.value),
            );
            final opacity = animationPercent;
            final slideDistance = (1.0 - animationPercent) * 150;

            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(slideDistance, 0),
                child: child,
              ),
            );
          },
          child: TopNavigationItem(
            controller: widget.controller,
            title: menuList[index].name,
            route: menuList[index].route,
            index: index + 1,
            isMobile: true,
            titleColor: CustomColors.black100,
            isSelected: widget.selectedItemRouteName == menuList[index].route ? true : false,
            onTap: () {
              PageTransition.goTo(context, menuList[index].route);
            },
          ),
        ),
      );
    }
    return menuItems;
  }
}
