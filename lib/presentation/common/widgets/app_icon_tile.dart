import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The app icon as a rounded tile, as on the splash screen.
class AppIconTile extends StatelessWidget {
  const AppIconTile({this.size = 112, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    // The design's 26pt corner on a 112pt tile.
    final radius = BorderRadius.circular(size * 26 / 112);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: dark
            // On brand-night the tile is the same color as the ground, so a
            // faint blue hairline keeps it from sinking.
            ? const [
                BoxShadow(color: Color(0x388FA9FF), spreadRadius: 1),
                BoxShadow(
                  color: Color(0x66000000),
                  offset: Offset(0, 12),
                  blurRadius: 30,
                ),
              ]
            : const [
                BoxShadow(
                  color: Color(0x470E1630),
                  offset: Offset(0, 12),
                  blurRadius: 30,
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: SvgPicture.asset(
          'assets/app_icon/parkomat-ios-1024.svg',
          width: size,
          height: size,
        ),
      ),
    );
  }
}
