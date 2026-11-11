import 'package:flutter/material.dart';

abstract final class ParkomatRadius {
  /// Badges, small tags and plate corners.
  static const sm = 10.0;

  /// Chips, inputs, list cards and the segmented control.
  static const md = 14.0;

  /// The search bar, map buttons and cards.
  static const lg = 18.0;

  /// Bottom sheet top corners and onboarding frames.
  static const xl = 26.0;

  /// Buttons, markers and the location puck.
  static const full = 999.0;
}

/// 4pt spacing scale.
abstract final class ParkomatSpace {
  /// Icon-to-label gap and badge padding.
  static const s1 = 4.0;

  /// Between chips and stacked controls.
  static const s2 = 8.0;

  /// Map overlays from the screen edge; list row vertical padding.
  static const s3 = 12.0;

  /// Sheet and card padding; the standard gutter.
  static const s4 = 16.0;

  /// Sheet top padding below the handle.
  static const s5 = 20.0;

  /// Between sections in a sheet.
  static const s6 = 24.0;

  /// Large sections and onboarding blocks.
  static const s8 = 32.0;

  /// Empty states.
  static const s12 = 48.0;
}

/// Heights of controls. Every touch target is at least [minTouchTarget].
abstract final class ParkomatSize {
  static const minTouchTarget = 48.0;

  /// Primary and secondary buttons.
  static const button = 56.0;
  static const buttonSmall = 48.0;

  /// The search bar, map buttons and text fields.
  static const control = 52.0;

  /// Filter chips, inside a [minTouchTarget] hit area.
  static const chip = 40.0;

  /// The "pay parking" call to action and zone picker tiles.
  static const payAction = 64.0;
}

abstract final class ParkomatShadow {
  /// Floating map controls, the search bar, chips and cards.
  ///
  /// In dark, a faint blue hairline plus a deep shadow, so surfaces still
  /// separate at night.
  static List<BoxShadow> card(Brightness brightness) {
    return brightness == Brightness.dark
        ? const [
            BoxShadow(color: Color(0x1A8FA9FF), spreadRadius: 1),
            BoxShadow(
              color: Color(0x80000000),
              offset: Offset(0, 10),
              blurRadius: 26,
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x140F1730),
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
            BoxShadow(
              color: Color(0x1A0F1730),
              offset: Offset(0, 8),
              blurRadius: 24,
            ),
          ];
  }

  /// The primary button only.
  ///
  /// The dark design also has a 1px inner hairline (white at 14%), which a
  /// box shadow can't draw; the button draws it as a border.
  static List<BoxShadow> button(Brightness brightness) {
    return brightness == Brightness.dark
        ? const [
            BoxShadow(
              color: Color(0x595C7DFF),
              offset: Offset(0, 10),
              blurRadius: 30,
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x592A4FE0),
              offset: Offset(0, 10),
              blurRadius: 24,
            ),
          ];
  }

  /// Bottom sheets and the web side panel, cast upward.
  static List<BoxShadow> sheet(Brightness brightness) {
    return brightness == Brightness.dark
        ? const [
            BoxShadow(color: Color(0x1F8FA9FF), offset: Offset(0, -1)),
            BoxShadow(
              color: Color(0x8C000000),
              offset: Offset(0, -12),
              blurRadius: 34,
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x1F0F1730),
              offset: Offset(0, -10),
              blurRadius: 30,
            ),
          ];
  }
}
