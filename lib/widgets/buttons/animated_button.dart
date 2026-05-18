import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../../../utils/values/values.dart';
import '../../utils/values/spaces.dart';

class AnimatedButton extends StatefulWidget {
  const AnimatedButton({
    required this.title,
    this.titleStyle,
    this.width = Sizes.WIDTH_120,
    this.height = Sizes.HEIGHT_44,
    this.icon = Icons.send,
    this.showIcon = true,
    this.iconSize = Sizes.ICON_SIZE_16,
    this.backgroundColor = CustomColors.black,
    this.foregroundColor = CustomColors.white,
    this.isLoading = false,
    this.onPressed,
    super.key,
  });

  final String title;
  final TextStyle? titleStyle;
  final double width;
  final double height;
  final IconData icon;
  final bool showIcon;
  final double iconSize;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  AnimatedButtonState createState() => AnimatedButtonState();
}

class AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<Color?> _textAndIconColor;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(vsync: this);
    _textAndIconColor = ColorTween(
      begin: widget.foregroundColor,
      end: widget.backgroundColor,
    ).animate(_backgroundController);

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0.5, 0),
    ).animate(_backgroundController);

    _backgroundController.addListener(() {
      setState(() {});
    });
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
    final TextStyle? defaultTitleTextStyle = Get.textTheme.bodyLarge?.copyWith(
      color: _textAndIconColor.value,
      fontSize: Sizes.TEXT_SIZE_15,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.2,
    );
    final ButtonStyle defaultButtonStyle = ElevatedButton.styleFrom(
      foregroundColor: widget.foregroundColor,
      backgroundColor: widget.foregroundColor,
      padding: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(0)),
        side: BorderSide(
          width: 1,
          color: widget.backgroundColor,
        ),
      ),
    );
    return MouseRegion(
      onEnter: (e) => _mouseEnter(true),
      onExit: (e) => _mouseEnter(false),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: defaultButtonStyle,
          child: Stack(
            children: <Widget>[
              ///  Background animation
              Positioned(
                right: 0,
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  color: widget.backgroundColor,
                )
                    .animate(
                      controller: _backgroundController,
                      autoPlay: false,
                    )
                    .scaleX(
                      alignment: Alignment.centerRight,
                      begin: 1,
                      end: 0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.fastOutSlowIn,
                    ),
              ),

              /// Text and Icon
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 18, // This line centers the Text to the Icon
                      child: Text(
                        widget.title,
                        style: widget.titleStyle ?? defaultTitleTextStyle,
                      ),
                    ),
                    const SpaceW8(),
                    widget.showIcon
                        ? SlideTransition(
                            position: _offsetAnimation,
                            child: widget.isLoading
                                ? SpinKitWanderingCubes(
                                    color: _textAndIconColor.value,
                                    size: widget.iconSize,
                                  )
                                : Icon(
                                    Icons.send,
                                    size: widget.iconSize,
                                    color: _textAndIconColor.value,
                                  ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
