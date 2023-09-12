import 'package:flutter/material.dart';
import 'package:layout/layout.dart';
import 'package:responsive_builder/responsive_builder.dart';

enum DisplayType {
  desktop,
  mobile,
  tablet,
}

const _desktopPortraitBreakpoint = 700.0;
const _desktopLandscapeBreakpoint = 1000.0;
const ipadProBreakpoint = 1000.0;

/// Returns the [DisplayType] for the current screen. This app only supports
/// mobile and desktop layouts, and as such we only have one breakpoint.
DisplayType displayTypeOf(BuildContext context) {
  final orientation = MediaQuery.of(context).orientation;
  final width = MediaQuery.of(context).size.width;

  if ((orientation == Orientation.landscape && width > _desktopLandscapeBreakpoint) ||
      (orientation == Orientation.portrait && width > _desktopPortraitBreakpoint)) {
    return DisplayType.desktop;
  } else {
    return DisplayType.mobile;
  }
}

/// Returns a boolean if we are in a display of [DisplayType.desktop]. Used to
/// build adaptive and responsive layouts.
bool isDisplayDesktop(BuildContext context) {
  return displayTypeOf(context) == DisplayType.desktop;
}

/// Returns a boolean if we are in a display of [DisplayType.mobile]. Used to
/// build adaptive and responsive layouts.
bool isDisplayMobile(BuildContext context) {
  return MediaQuery.of(context).size.width <= const RefinedBreakpoints().tabletSmall;
}

/// Returns a boolean if we are in a display of [DisplayType.mobile] or [DisplayType.tablet]. Used to
/// build adaptive and responsive layouts.
bool isDisplayMobileOrTablet(BuildContext context) {
  return MediaQuery.of(context).size.width <= const RefinedBreakpoints().tabletNormal;
}

/// Returns a boolean if we are in a display of [DisplayType.desktop] but less
/// than [_desktopLandscapeBreakpoint] width. Used to build adaptive and responsive layouts.
bool isDisplaySmallDesktop(BuildContext context) {
  return isDisplayDesktop(context) && MediaQuery.of(context).size.width < _desktopLandscapeBreakpoint;
}

bool isDisplaySmallDesktopOrIpadPro(BuildContext context) {
  return isDisplaySmallDesktop(context) ||
      (MediaQuery.of(context).size.width > ipadProBreakpoint &&
          MediaQuery.of(context).size.width < 1170);
}

double widthOfScreen(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double heightOfScreen(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double assignHeight(
  BuildContext context,
  double fraction, {
  double additions = 0,
  double subs = 0,
}) {
  return (heightOfScreen(context) - (subs) + (additions)) * fraction;
}

//
double assignWidth(
  BuildContext context,
  double fraction, {
  double additions = 0,
  double subs = 0,
}) {
  return (widthOfScreen(context) - (subs) + (additions)) * fraction;
}

double asd = 200.0;

double responsiveSize(
  BuildContext context,
  double verySmall,
  double large, {
  double? small,
  double? medium,
  double? verLarge,
}) {
  return context.layout.value(
    xs: verySmall,
    sm: small ??
        (medium ?? verySmall), //assign medium to small if it is not null, if null assign verySmall
    md: medium ?? large,
    lg: large,
    xl: verLarge ?? large,
  );
}

int responsiveSizeInt(
  BuildContext context,
  int verySmall,
  int large, {
  int? small,
  int? medium,
  int? verLarge,
}) {
  return context.layout.value(
    xs: verySmall,
    sm: small ??
        (medium ?? verySmall), //assign medium to small if it is not null, if null assign verySmall
    md: medium ?? large,
    lg: large,
    xl: verLarge ?? large,
  );
}

Color responsiveColor(
  BuildContext context,
  Color verySmall,
  Color large, {
  Color? small,
  Color? medium,
  Color? veryLarge,
}) {
  return context.layout.value(
    xs: verySmall,
    sm: small ??
        (medium ?? verySmall), //assign medium to small if it is not null, if null assign verySmall
    md: medium ?? large,
    lg: large,
    xl: veryLarge ?? large,
  );
}

double getSidePadding(BuildContext context) {
  double sidePadding = assignWidth(context, 0.05);
  return responsiveSize(context, 30, sidePadding, medium: sidePadding);
}
