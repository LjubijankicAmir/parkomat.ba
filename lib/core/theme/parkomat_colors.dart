import 'package:flutter/material.dart';

// Values come from the design system's tokens.json.
//
// Token → Material role mapping (the design system's M3 table):
//   background         → surface (scaffold)
//   surface            → surfaceContainerLow (sheets, cards, list rows)
//   surface-raised     → surfaceContainerHigh (over the map)
//   surface-sunken     → [ParkomatColors.surfaceSunken] (light and dark map
//                        it to different M3 slots, so read it from here)
//   primary-soft       → primaryContainer
//   ink / ink-muted    → onSurface / onSurfaceVariant
//   line / line-strong → outlineVariant / outline
//   warning*           → tertiary*
//   ink on background  → secondaryContainer (the selected filter chip)

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF2A4FE0),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFE2E8FD),
  onPrimaryContainer: Color(0xFF1E3BB0),
  secondary: Color(0xFF4D5874),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFF0F1730),
  onSecondaryContainer: Color(0xFFEEF1F7),
  tertiary: Color(0xFF8A5A00),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFFF1C7),
  onTertiaryContainer: Color(0xFF5C3D00),
  error: Color(0xFFB3261E),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFCE8E6),
  onErrorContainer: Color(0xFF8C1D18),
  surface: Color(0xFFEEF1F7),
  onSurface: Color(0xFF0F1730),
  onSurfaceVariant: Color(0xFF4D5874),
  surfaceDim: Color(0xFFEEF1F7),
  surfaceBright: Color(0xFFFFFFFF),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFFFFFFF),
  surfaceContainer: Color(0xFFEEF1F7),
  surfaceContainerHigh: Color(0xFFFFFFFF),
  surfaceContainerHighest: Color(0xFFE3E8F1),
  outline: Color(0xFF7C87A0),
  outlineVariant: Color(0xFFD9DFEA),
  shadow: Color(0xFF000000),
  scrim: Color(0x660F1730),
  inverseSurface: Color(0xFF0F1730),
  onInverseSurface: Color(0xFFEEF1F7),
  inversePrimary: Color(0xFF8FA9FF),
  surfaceTint: Colors.transparent,
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF8FA9FF),
  onPrimary: Color(0xFF0A1230),
  primaryContainer: Color(0xFF1C2A55),
  onPrimaryContainer: Color(0xFFCAD6FF),
  secondary: Color(0xFF9AA6C6),
  onSecondary: Color(0xFF0B1022),
  secondaryContainer: Color(0xFFEEF2FF),
  onSecondaryContainer: Color(0xFF0B1022),
  tertiary: Color(0xFFFFC94D),
  onTertiary: Color(0xFF2A1E00),
  tertiaryContainer: Color(0xFF2E2410),
  onTertiaryContainer: Color(0xFFFFE3A0),
  error: Color(0xFFFF8A80),
  onError: Color(0xFF3A0508),
  errorContainer: Color(0xFF3A1220),
  onErrorContainer: Color(0xFFFFC9C4),
  surface: Color(0xFF0B1022),
  onSurface: Color(0xFFEEF2FF),
  onSurfaceVariant: Color(0xFF9AA6C6),
  surfaceDim: Color(0xFF0B1022),
  surfaceBright: Color(0xFF1A2442),
  surfaceContainerLowest: Color(0xFF070B18),
  surfaceContainerLow: Color(0xFF121A33),
  surfaceContainer: Color(0xFF121A33),
  surfaceContainerHigh: Color(0xFF1A2442),
  surfaceContainerHighest: Color(0xFF1A2442),
  outline: Color(0xFF6676A6),
  outlineVariant: Color(0xFF243052),
  shadow: Color(0xFF000000),
  scrim: Color(0xA3000000),
  inverseSurface: Color(0xFFEEF2FF),
  onInverseSurface: Color(0xFF0B1022),
  inversePrimary: Color(0xFF2A4FE0),
  surfaceTint: Colors.transparent,
);

/// Parkomat roles that Material's [ColorScheme] has no slot for.
///
/// Read with `Theme.of(context).extension<ParkomatColors>()!`.
@immutable
class ParkomatColors extends ThemeExtension<ParkomatColors> {
  const ParkomatColors({
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.focusRing,
    required this.success,
    required this.onSuccess,
    required this.successSoft,
    required this.onSuccessSoft,
    required this.warning,
    required this.onWarning,
    required this.warningSoft,
    required this.onWarningSoft,
    required this.zone0,
    required this.onZone0,
    required this.zone1,
    required this.onZone1,
    required this.zone2,
    required this.onZone2,
    required this.typeGarage,
    required this.onTypeGarage,
    required this.typeUnderground,
    required this.onTypeUnderground,
    required this.typeLot,
    required this.onTypeLot,
    required this.typeStreet,
    required this.onTypeStreet,
    required this.markerRing,
    required this.cluster,
    required this.onCluster,
    required this.location,
    required this.locationHalo,
    required this.plateEdge,
  });

  /// Anything floating over the map: search, chips, map buttons, price pills.
  final Color surfaceRaised;

  /// Wells: text inputs, the segmented control track.
  final Color surfaceSunken;

  /// 2px outline, offset 2px, on every focusable control.
  final Color focusRing;

  /// "Free right now" and confirmations, always with a check icon and words.
  final Color success;
  final Color onSuccess;

  /// Success banners and the "free right now" state.
  final Color successSoft;
  final Color onSuccessSoft;

  /// Offline and stale-data notices, always with an icon and words.
  final Color warning;
  final Color onWarning;

  /// The "paid right now" state and the offline banner.
  final Color warningSoft;
  final Color onWarningSoft;

  /// Zone 0 line and badge, for cities that have one. Always with the numeral.
  final Color zone0;
  final Color onZone0;

  /// Zone 1 line and badge. Always with the numeral.
  final Color zone1;
  final Color onZone1;

  /// Zone 2 line and badge. Always with the numeral.
  final Color zone2;
  final Color onZone2;

  /// Garage markers (glyph: stacked levels).
  final Color typeGarage;
  final Color onTypeGarage;

  /// Underground garage markers (glyph: arrow below ground).
  final Color typeUnderground;
  final Color onTypeUnderground;

  /// Open lot markers (glyph: parking bays).
  final Color typeLot;
  final Color onTypeLot;

  /// Street parking in lists and filters; on the map it is the zone lines.
  final Color typeStreet;
  final Color onTypeStreet;

  /// Ring around every marker, badge and cluster.
  final Color markerRing;

  /// Cluster marker fill.
  final Color cluster;
  final Color onCluster;

  /// Your position dot.
  final Color location;

  /// Accuracy halo and heading cone.
  final Color locationHalo;

  /// Decorative outer edge around a licence plate.
  final Color plateEdge;

  // Identical in both themes.

  /// The icon and splash ground. Logo only, never a UI surface.
  static const brandNight = Color(0xFF0E1630);

  /// The road in the logo mark. Logo only.
  static const brandRoad = Color(0xFF5C7DFF);

  /// The puck core in the logo mark. Logo only.
  static const brandPuck = Color(0xFFFFC83D);

  /// Ring around your position dot.
  static const locationRing = Color(0xFFFFFFFF);

  /// Licence plates are black on white in both themes.
  static const plateBackground = Color(0xFFFFFFFF);
  static const plateInk = Color(0xFF111318);

  static const light = ParkomatColors(
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFE3E8F1),
    focusRing: Color(0xFF2A4FE0),
    success: Color(0xFF0F6E52),
    onSuccess: Color(0xFFFFFFFF),
    successSoft: Color(0xFFDDF3EA),
    onSuccessSoft: Color(0xFF0B5A42),
    warning: Color(0xFF8A5A00),
    onWarning: Color(0xFFFFFFFF),
    warningSoft: Color(0xFFFFF1C7),
    onWarningSoft: Color(0xFF5C3D00),
    zone0: Color(0xFFA62C99),
    onZone0: Color(0xFFFFFFFF),
    zone1: Color(0xFFD3324A),
    onZone1: Color(0xFFFFFFFF),
    zone2: Color(0xFFE2B100),
    onZone2: Color(0xFF0F1730),
    typeGarage: Color(0xFF2A4FE0),
    onTypeGarage: Color(0xFFFFFFFF),
    typeUnderground: Color(0xFF5B3FCB),
    onTypeUnderground: Color(0xFFFFFFFF),
    typeLot: Color(0xFF0F7D6B),
    onTypeLot: Color(0xFFFFFFFF),
    typeStreet: Color(0xFF4D5874),
    onTypeStreet: Color(0xFFFFFFFF),
    markerRing: Color(0xFFFFFFFF),
    cluster: Color(0xFF0F1730),
    onCluster: Color(0xFFFFFFFF),
    location: Color(0xFF2A4FE0),
    locationHalo: Color(0x2E2A4FE0),
    plateEdge: Color(0xFFC9D0DE),
  );

  static const dark = ParkomatColors(
    surfaceRaised: Color(0xFF1A2442),
    surfaceSunken: Color(0xFF070B18),
    focusRing: Color(0xFFB7C8FF),
    success: Color(0xFF5BD6A8),
    onSuccess: Color(0xFF04281C),
    successSoft: Color(0xFF0E2E28),
    onSuccessSoft: Color(0xFFA8EFD3),
    warning: Color(0xFFFFC94D),
    onWarning: Color(0xFF2A1E00),
    warningSoft: Color(0xFF2E2410),
    onWarningSoft: Color(0xFFFFE3A0),
    zone0: Color(0xFFF27AE0),
    onZone0: Color(0xFF2B0627),
    zone1: Color(0xFFFF6B7A),
    onZone1: Color(0xFF2A060C),
    zone2: Color(0xFFFFD03D),
    onZone2: Color(0xFF1F1800),
    typeGarage: Color(0xFF8FA9FF),
    onTypeGarage: Color(0xFF0A1230),
    typeUnderground: Color(0xFFBBA8FF),
    onTypeUnderground: Color(0xFF1A0F45),
    typeLot: Color(0xFF5DE0C4),
    onTypeLot: Color(0xFF032620),
    typeStreet: Color(0xFF9AA6C6),
    onTypeStreet: Color(0xFF0B1022),
    markerRing: Color(0xFF0B1022),
    cluster: Color(0xFFEEF2FF),
    onCluster: Color(0xFF0B1022),
    location: Color(0xFF8FA9FF),
    locationHalo: Color(0x3D8FA9FF),
    plateEdge: Color(0xFF4F5D88),
  );

  @override
  ParkomatColors copyWith({
    Color? surfaceRaised,
    Color? surfaceSunken,
    Color? focusRing,
    Color? success,
    Color? onSuccess,
    Color? successSoft,
    Color? onSuccessSoft,
    Color? warning,
    Color? onWarning,
    Color? warningSoft,
    Color? onWarningSoft,
    Color? zone0,
    Color? onZone0,
    Color? zone1,
    Color? onZone1,
    Color? zone2,
    Color? onZone2,
    Color? typeGarage,
    Color? onTypeGarage,
    Color? typeUnderground,
    Color? onTypeUnderground,
    Color? typeLot,
    Color? onTypeLot,
    Color? typeStreet,
    Color? onTypeStreet,
    Color? markerRing,
    Color? cluster,
    Color? onCluster,
    Color? location,
    Color? locationHalo,
    Color? plateEdge,
  }) {
    return ParkomatColors(
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      focusRing: focusRing ?? this.focusRing,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successSoft: successSoft ?? this.successSoft,
      onSuccessSoft: onSuccessSoft ?? this.onSuccessSoft,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningSoft: warningSoft ?? this.warningSoft,
      onWarningSoft: onWarningSoft ?? this.onWarningSoft,
      zone0: zone0 ?? this.zone0,
      onZone0: onZone0 ?? this.onZone0,
      zone1: zone1 ?? this.zone1,
      onZone1: onZone1 ?? this.onZone1,
      zone2: zone2 ?? this.zone2,
      onZone2: onZone2 ?? this.onZone2,
      typeGarage: typeGarage ?? this.typeGarage,
      onTypeGarage: onTypeGarage ?? this.onTypeGarage,
      typeUnderground: typeUnderground ?? this.typeUnderground,
      onTypeUnderground: onTypeUnderground ?? this.onTypeUnderground,
      typeLot: typeLot ?? this.typeLot,
      onTypeLot: onTypeLot ?? this.onTypeLot,
      typeStreet: typeStreet ?? this.typeStreet,
      onTypeStreet: onTypeStreet ?? this.onTypeStreet,
      markerRing: markerRing ?? this.markerRing,
      cluster: cluster ?? this.cluster,
      onCluster: onCluster ?? this.onCluster,
      location: location ?? this.location,
      locationHalo: locationHalo ?? this.locationHalo,
      plateEdge: plateEdge ?? this.plateEdge,
    );
  }

  @override
  ParkomatColors lerp(ThemeExtension<ParkomatColors>? other, double t) {
    if (other is! ParkomatColors) return this;
    return ParkomatColors(
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      onSuccessSoft: Color.lerp(onSuccessSoft, other.onSuccessSoft, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      onWarningSoft: Color.lerp(onWarningSoft, other.onWarningSoft, t)!,
      zone0: Color.lerp(zone0, other.zone0, t)!,
      onZone0: Color.lerp(onZone0, other.onZone0, t)!,
      zone1: Color.lerp(zone1, other.zone1, t)!,
      onZone1: Color.lerp(onZone1, other.onZone1, t)!,
      zone2: Color.lerp(zone2, other.zone2, t)!,
      onZone2: Color.lerp(onZone2, other.onZone2, t)!,
      typeGarage: Color.lerp(typeGarage, other.typeGarage, t)!,
      onTypeGarage: Color.lerp(onTypeGarage, other.onTypeGarage, t)!,
      typeUnderground: Color.lerp(typeUnderground, other.typeUnderground, t)!,
      onTypeUnderground: Color.lerp(
        onTypeUnderground,
        other.onTypeUnderground,
        t,
      )!,
      typeLot: Color.lerp(typeLot, other.typeLot, t)!,
      onTypeLot: Color.lerp(onTypeLot, other.onTypeLot, t)!,
      typeStreet: Color.lerp(typeStreet, other.typeStreet, t)!,
      onTypeStreet: Color.lerp(onTypeStreet, other.onTypeStreet, t)!,
      markerRing: Color.lerp(markerRing, other.markerRing, t)!,
      cluster: Color.lerp(cluster, other.cluster, t)!,
      onCluster: Color.lerp(onCluster, other.onCluster, t)!,
      location: Color.lerp(location, other.location, t)!,
      locationHalo: Color.lerp(locationHalo, other.locationHalo, t)!,
      plateEdge: Color.lerp(plateEdge, other.plateEdge, t)!,
    );
  }
}
