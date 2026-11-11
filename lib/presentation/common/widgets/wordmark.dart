import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parkomat/core/l10n/l10n.dart';

/// The `parkomat.ba` wordmark, in the theme's ink.
///
/// Always the supplied artwork, never retyped in a live font.
class Wordmark extends StatelessWidget {
  const Wordmark({this.height = 44, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SvgPicture.asset(
      dark
          ? 'assets/logo/parkomat-wordmark-dark.svg'
          : 'assets/logo/parkomat-wordmark-light.svg',
      height: height,
      semanticsLabel: context.l10n.appTitle,
    );
  }
}
