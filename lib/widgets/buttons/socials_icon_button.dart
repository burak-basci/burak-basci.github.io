import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../utils/functions.dart';
import '../../../utils/values/values.dart';
import '../../utils/values/spaces.dart';

class SocialData {
  final IconData iconData;
  final String url;
  final String name;
  final Color? color;

  SocialData({
    required this.name,
    required this.iconData,
    required this.url,
    this.color = CustomColors.white,
  });
}

class SocialIconButtonList extends StatefulWidget {
  const SocialIconButtonList({
    required this.socialData,
    this.size = 24.0,
    this.color = CustomColors.white,
    this.spacing = 32.0,
    this.runSpacing = 16.0,
    this.isHorizontal = true,
    super.key,
  }) : assert(socialData.length > 0);

  final List<SocialData> socialData;
  final double size;
  final Color color;
  final double spacing;
  final double runSpacing;
  final bool isHorizontal;

  @override
  State<SocialIconButtonList> createState() => _SocialIconButtonListState();
}

class _SocialIconButtonListState extends State<SocialIconButtonList> {
  List<Widget> _buildSocialIcons() {
    List<Widget> items = <Widget>[];

    for (int index = 0; index < widget.socialData.length; index++) {
      items.add(
        AnimatedSocialIconButton(
          socialData: widget.socialData,
          index: index,
          size: widget.size,
          color: widget.color,
        ),
      );

      // if it is vertical, add spaces
      if (!widget.isHorizontal) {
        items.add(const SpaceH32());
      }
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isHorizontal) {
      return Wrap(
        spacing: widget.spacing,
        runSpacing: widget.runSpacing,
        children: _buildSocialIcons(),
      );
    } else {
      return Column(
        children: _buildSocialIcons(),
      );
    }
  }
}

class AnimatedSocialIconButton extends StatefulWidget {
  const AnimatedSocialIconButton({
    required this.socialData,
    required this.index,
    this.size = Sizes.ICON_SIZE_18,
    this.color = CustomColors.white,
    super.key,
  });

  final List<SocialData> socialData;
  final int index;
  final double size;
  final Color color;

  @override
  State<AnimatedSocialIconButton> createState() => _AnimatedSocialIconButtonState();
}

class _AnimatedSocialIconButtonState extends State<AnimatedSocialIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _backgroundController;

  @override
  void initState() {
    _backgroundController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  void _mouseEnter(bool hovering) {
    if (hovering) {
      _backgroundController.forward();
    } else {
      _backgroundController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => _mouseEnter(true),
      onExit: (e) => _mouseEnter(false),
      child: InkWell(
        onTap: () => Functions.launchUrl(widget.socialData[widget.index].url),
        child: Icon(
          widget.socialData[widget.index].iconData,
          color: widget.socialData[widget.index].color ?? widget.color,
          size: widget.size,
        )
            .animate(
              controller: _backgroundController,
              autoPlay: false,
            )
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.2, 1.2),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeIn,
            ),
      ),
    );
  }
}
