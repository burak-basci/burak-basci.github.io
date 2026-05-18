import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/adaptive_layout.dart';
import '../../../../utils/values/values.dart';
import '../../../widgets/buttons/scroll_down_button.dart';
import 'about_header_description.dart';

class AboutHeader extends StatelessWidget {
  const AboutHeader({
    required this.scrollController,
    required this.controller,
    super.key,
  });

  final ScrollController scrollController;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      height: Get.height,
      child: Stack(
        children: <Widget>[
          LayoutBuilder(
            builder: (context, constraints) {
              /// Mobile View
              if (constraints.maxWidth < refinedBreakpoints.tabletSmall) {
                return Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(40.0, 120.0, 40.0, 0.0),
                        child: AboutHeaderDescription(
                          controller: controller,
                          width: constraints.maxWidth - 80.0,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 120.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth * 0.5 - 80,
                              maxHeight: constraints.maxHeight * 0.6 - 120,
                            ),
                            child: Image.asset(
                              ImagePath.DEV,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              /// Tablet and Desktop View
              else {
                return Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 80.0),
                        child: AboutHeaderDescription(
                          controller: controller,
                          width: constraints.maxWidth * 0.5 - 100,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 80.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth * 0.25 - 100,
                              maxWidth: constraints.maxWidth * 0.5 - 100,
                              maxHeight: constraints.maxHeight * 0.6,
                            ),
                            child: Image.asset(
                              ImagePath.DEV,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ScrollDownButton(scrollController: scrollController),
          ),
        ],
      ),
    );
  }
}
