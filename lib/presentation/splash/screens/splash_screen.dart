import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parkomat/core/routing/app_router.gr.dart';
import 'package:parkomat/core/theme/parkomat_colors.dart';
import 'package:parkomat/core/theme/parkomat_text.dart';
import 'package:parkomat/presentation/common/widgets/app_icon_tile.dart';
import 'package:parkomat/presentation/common/widgets/wordmark.dart';

/// The logo animating in, then the map.
///
/// The native splash shows only the background color, and this screen
/// starts on exactly that color, so the hand-off is invisible and the
/// animation is the first thing anyone sees.
@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// The whole splash: the entrance, then a short hold.
  static const duration = Duration(milliseconds: 1500);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Fractions of [SplashScreen.duration].
  static const _tile = Interval(0, 0.4, curve: Curves.easeOutCubic);
  static const _wordmark = Interval(0.13, 0.53, curve: Curves.easeOutCubic);
  static const _city = Interval(0.33, 0.67, curve: Curves.easeOut);

  /// Where the entrance ends and the hold begins.
  static const _entranceEnd = 0.67;

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: SplashScreen.duration)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) {
            unawaited(context.router.replace(const MapRoute()));
          }
        });

  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // With Reduce Motion on, the logo is simply there; only the hold runs.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = _entranceEnd;
    }
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return AnnotatedRegion(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        // The native splash colors: background in light, brand-night in dark.
        backgroundColor: dark
            ? ParkomatColors.brandNight
            : theme.colorScheme.surface,
        body: Stack(
          children: [
            Center(
              child: Transform.translate(
                // The design sits the logo a little above center.
                offset: const Offset(0, -20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Entrance(
                      animation: CurvedAnimation(
                        parent: _controller,
                        curve: _tile,
                      ),
                      offset: 28,
                      fromScale: 0.9,
                      child: const AppIconTile(),
                    ),
                    const SizedBox(height: 22),
                    _Entrance(
                      animation: CurvedAnimation(
                        parent: _controller,
                        curve: _wordmark,
                      ),
                      offset: 20,
                      child: const Wordmark(),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 56,
              child: FadeTransition(
                opacity: CurvedAnimation(parent: _controller, curve: _city),
                child: Text(
                  // The first city. Later this comes from the chosen city.
                  'SARAJEVO',
                  textAlign: TextAlign.center,
                  style: ParkomatText.labelSm.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: dark
                        ? const Color(0xFF9AA6C6)
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fades [child] in while it slides up by [offset] and grows from
/// [fromScale].
class _Entrance extends StatelessWidget {
  const _Entrance({
    required this.animation,
    required this.offset,
    required this.child,
    this.fromScale = 1,
  });

  final Animation<double> animation;
  final double offset;
  final double fromScale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = animation.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, offset * (1 - t)),
            child: Transform.scale(
              scale: fromScale + (1 - fromScale) * t,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
