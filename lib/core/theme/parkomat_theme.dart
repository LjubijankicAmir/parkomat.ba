import 'package:flutter/material.dart';
import 'package:parkomat/core/theme/parkomat_colors.dart';
import 'package:parkomat/core/theme/parkomat_text.dart';
import 'package:parkomat/core/theme/parkomat_tokens.dart';

abstract final class ParkomatTheme {
  static final ThemeData light = _build(lightColorScheme, ParkomatColors.light);
  static final ThemeData dark = _build(darkColorScheme, ParkomatColors.dark);

  static ThemeData _build(ColorScheme scheme, ParkomatColors colors) {
    final fieldRadius = BorderRadius.circular(ParkomatRadius.md);
    final fieldBorder = BorderSide(color: scheme.outline, width: 1.5);

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: 'Onest',
      textTheme: ParkomatText.textTheme(scheme.onSurface),
      extensions: [colors],
      focusColor: colors.focusRing,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, ParkomatSize.button),
          padding: const EdgeInsets.symmetric(horizontal: ParkomatSpace.s6),
          shape: const StadiumBorder(),
          textStyle: ParkomatText.labelLg,
          disabledBackgroundColor: colors.surfaceSunken,
          disabledForegroundColor: scheme.onSurfaceVariant,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, ParkomatSize.button),
          padding: const EdgeInsets.symmetric(horizontal: ParkomatSpace.s6),
          shape: const StadiumBorder(),
          side: fieldBorder,
          foregroundColor: scheme.onSurface,
          textStyle: ParkomatText.labelLg,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(
            ParkomatSize.minTouchTarget,
            ParkomatSize.buttonSmall,
          ),
          shape: const StadiumBorder(),
          foregroundColor: scheme.primary,
          textStyle: ParkomatText.labelLg,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(ParkomatSize.minTouchTarget),
          foregroundColor: scheme.onSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceSunken,
        constraints: const BoxConstraints(minHeight: ParkomatSize.control),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ParkomatSpace.s4,
          vertical: 15,
        ),
        hintStyle: ParkomatText.body.copyWith(color: scheme.onSurfaceVariant),
        labelStyle: ParkomatText.label.copyWith(color: scheme.onSurfaceVariant),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: fieldBorder,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: fieldBorder,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        errorStyle: ParkomatText.bodySm.copyWith(color: scheme.error),
      ),
      // Chips in forms are outlined; over the map they float on
      // surface-raised, which the map's own chip widget sets. Selected is
      // inverted: ink on background.
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ParkomatRadius.md),
        ),
        side: fieldBorder,
        backgroundColor: Colors.transparent,
        selectedColor: scheme.secondaryContainer,
        labelStyle: ParkomatText.label.copyWith(color: scheme.onSurface),
        secondaryLabelStyle: ParkomatText.label.copyWith(
          color: scheme.onSecondaryContainer,
        ),
        checkmarkColor: scheme.onSecondaryContainer,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: colors.surfaceSunken,
          selectedBackgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onSurfaceVariant,
          selectedForegroundColor: scheme.onPrimaryContainer,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ParkomatRadius.md),
          ),
          textStyle: ParkomatText.label,
        ),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : colors.surfaceSunken,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : scheme.outline,
        ),
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.outline,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ParkomatRadius.lg),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: scheme.scrim,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ParkomatRadius.xl),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: scheme.outline,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: colors.surfaceSunken,
      ),
    );
  }
}
