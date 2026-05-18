import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScrollDownButton extends StatefulWidget {
  const HomeScrollDownButton({
    required this.scrollController,
    super.key,
  });

  final ScrollController scrollController;

  @override
  State<HomeScrollDownButton> createState() => _HomeScrollDownButtonState();
}

class _HomeScrollDownButtonState extends State<HomeScrollDownButton>
    with SingleTickerProviderStateMixin {
  late AnimationController scrollDownButtonController;

  @override
  void initState() {
    scrollDownButtonController = AnimationController(vsync: this);

    super.initState();
  }

  @override
  void dispose() {
    scrollDownButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => scrollDownButtonController.forward(),
      onExit: (e) => scrollDownButtonController.reverse(),
      child: HomeScrollDownButton(
        scrollController: widget.scrollController,
      )
          .animate(
            controller: scrollDownButtonController,
            autoPlay: false,
          )
          .slideY(
            begin: 0,
            end: 0.1,
            curve: Curves.ease,
            duration: const Duration(milliseconds: 300),
          ),
    );
  }
}
