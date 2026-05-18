import 'package:flutter/material.dart';

import 'values.dart';

class AppTheme {
  static const _lightFillColor = Colors.black;

  static final Color _lightFocusColor = Colors.black.withOpacity(0.12);

  static ThemeData lightThemeData = themeData(lightColorScheme, _lightFocusColor);

  static ThemeData themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
      useMaterial3: false,
      colorScheme: colorScheme,
      textTheme: _textTheme.apply(fontSizeDelta: 1.0),
      iconTheme: const IconThemeData(color: CustomColors.white),
      canvasColor: colorScheme.background,
      appBarTheme: const AppBarTheme(
        color: CustomColors.primaryColor,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: CustomColors.black,
        selectionColor: CustomColors.textSelectionColor,
        selectionHandleColor: CustomColors.primaryColor,
      ),
      scaffoldBackgroundColor: colorScheme.background,
      highlightColor: Colors.transparent,
      hintColor: colorScheme.primary,
      focusColor: CustomColors.primaryColor,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static const ColorScheme lightColorScheme = ColorScheme(
    primary: CustomColors.primaryColor,
    secondary: CustomColors.secondaryColor,
    background: CustomColors.primaryColor,
    surface: CustomColors.primaryColor,
    onBackground: Colors.white,
    error: _lightFillColor,
    onError: _lightFillColor,
    onPrimary: _lightFillColor,
    onSecondary: Color(0xFF322942),
    onSurface: Color(0xFF241E30),
    brightness: Brightness.light,
  );

  static const _bold = FontWeight.w700;
  static const _semiBold = FontWeight.w600;
  static const _medium = FontWeight.w500;
  static const _regular = FontWeight.w400;
  static const _light = FontWeight.w300;

  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: StringConst.VISUELT_PRO,
      fontSize: Sizes.TEXT_SIZE_96,
      color: CustomColors.black,
      fontWeight: _bold,
      fontStyle: FontStyle.normal,
    ),
    displayMedium: TextStyle(
      fontFamily: StringConst.VISUELT_PRO,
      fontSize: Sizes.TEXT_SIZE_60,
      color: CustomColors.black,
      fontWeight: _bold,
      fontStyle: FontStyle.normal,
    ),
    displaySmall: TextStyle(
      // Removed GoogleFonts.roboto here
      fontSize: Sizes.TEXT_SIZE_48,
      color: CustomColors.black,
      fontWeight: _bold,
      fontStyle: FontStyle.normal,
    ),
    headlineMedium: TextStyle(
      fontFamily: StringConst.VISUELT_PRO,
      fontSize: Sizes.TEXT_SIZE_34,
      color: CustomColors.black,
      fontWeight: _bold,
      fontStyle: FontStyle.normal,
    ),
    headlineSmall: TextStyle(
      // Removed GoogleFonts.roboto here
      fontSize: Sizes.TEXT_SIZE_24,
      color: CustomColors.black,
      fontWeight: _bold,
      fontStyle: FontStyle.normal,
    ),
    titleLarge: TextStyle(
      fontFamily: StringConst.VISUELT_PRO,
      fontSize: Sizes.TEXT_SIZE_20,
      color: CustomColors.black,
      fontWeight: _bold,
      fontStyle: FontStyle.normal,
    ),
    titleMedium: TextStyle(
      fontFamily: StringConst.INTER,
      fontSize: Sizes.TEXT_SIZE_16,
      color: CustomColors.secondaryColor,
      fontWeight: _semiBold,
      fontStyle: FontStyle.normal,
    ),
    titleSmall: TextStyle(
      // Removed GoogleFonts.roboto here
      fontSize: Sizes.TEXT_SIZE_14,
      color: CustomColors.secondaryColor,
      fontWeight: _semiBold,
      fontStyle: FontStyle.normal,
    ),
    bodyLarge: TextStyle(
      fontFamily: StringConst.INTER,
      fontSize: Sizes.TEXT_SIZE_16,
      color: CustomColors.secondaryColor,
      fontWeight: _light,
      fontStyle: FontStyle.normal,
    ),
    bodyMedium: TextStyle(
      // Removed GoogleFonts.roboto here
      fontSize: Sizes.TEXT_SIZE_14,
      color: CustomColors.secondaryColor,
      fontWeight: _light,
      fontStyle: FontStyle.normal,
    ),
    labelLarge: TextStyle(
      // Removed GoogleFonts.roboto here
      fontSize: Sizes.TEXT_SIZE_14,
      color: CustomColors.secondaryColor,
      fontStyle: FontStyle.normal,
      fontWeight: _medium,
    ),
    bodySmall: TextStyle(
      fontFamily: StringConst.INTER,
      fontSize: Sizes.TEXT_SIZE_12,
      color: CustomColors.white,
      fontWeight: _regular,
      fontStyle: FontStyle.normal,
    ),
  );
}
