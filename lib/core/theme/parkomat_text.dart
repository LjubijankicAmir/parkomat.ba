import 'package:flutter/material.dart';

/// Parkomat type scale.
///
/// Bricolage Grotesque is the display face (the splash, onboarding headlines
/// and sheet titles), never below 20px. Onest is the UI face for everything
/// else. Every price, time, distance, SMS number and plate uses one of the
/// numeric styles or [plate], which turn on tabular figures.
abstract final class ParkomatText {
  static const _tabularFigures = [FontFeature.tabularFigures()];

  static TextStyle _bricolage(double size, double lineHeight, double tracking) {
    return TextStyle(
      fontFamily: 'Bricolage Grotesque',
      fontSize: size,
      height: lineHeight / size,
      fontWeight: FontWeight.w700,
      letterSpacing: tracking * size,
    );
  }

  static TextStyle _onest(
    double size,
    double lineHeight,
    FontWeight weight, [
    double tracking = 0,
  ]) {
    return TextStyle(
      fontFamily: 'Onest',
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      letterSpacing: tracking * size,
    );
  }

  /// Splash and onboarding headlines.
  static final TextStyle display = _bricolage(40, 44, -0.025);

  /// Screen titles.
  static final TextStyle titleLg = _bricolage(28, 32, -0.02);

  /// Sheet titles: place names, zones.
  static final TextStyle title = _bricolage(22, 28, -0.015);

  /// Section headers inside sheets.
  static final TextStyle titleSm = _onest(17, 22, FontWeight.w600);

  /// Onboarding body and important explanations.
  static final TextStyle bodyLg = _onest(17, 24, FontWeight.w400);
  static final TextStyle body = _onest(15, 22, FontWeight.w400);

  /// Captions and footnotes.
  static final TextStyle bodySm = _onest(13, 18, FontWeight.w400);

  /// Buttons.
  static final TextStyle labelLg = _onest(17, 22, FontWeight.w700);

  /// Chips, tabs and list labels.
  static final TextStyle label = _onest(14, 18, FontWeight.w600);

  /// Overlines. Uppercase the text where it's used.
  static final TextStyle labelSm = _onest(12, 16, FontWeight.w700, 0.08);

  /// The price in a sheet header.
  static final TextStyle numericXl = _onest(
    34,
    38,
    FontWeight.w700,
    -0.01,
  ).copyWith(fontFeatures: _tabularFigures);

  /// Prices and times in tables.
  static final TextStyle numeric = _onest(
    17,
    22,
    FontWeight.w600,
  ).copyWith(fontFeatures: _tabularFigures);

  /// Price pills on the map and distances.
  static final TextStyle numericSm = _onest(
    13,
    16,
    FontWeight.w700,
  ).copyWith(fontFeatures: _tabularFigures);

  /// Licence plate characters.
  static final TextStyle plate = _onest(
    26,
    30,
    FontWeight.w700,
    0.04,
  ).copyWith(fontFeatures: _tabularFigures);

  static TextTheme textTheme(Color ink) {
    return TextTheme(
      displayLarge: display,
      headlineMedium: titleLg,
      titleLarge: title,
      titleMedium: titleSm,
      bodyLarge: bodyLg,
      bodyMedium: body,
      bodySmall: bodySm,
      labelLarge: labelLg,
      labelMedium: label,
      labelSmall: labelSm,
    ).apply(bodyColor: ink, displayColor: ink);
  }
}
