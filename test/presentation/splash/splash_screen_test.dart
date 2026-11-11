import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkomat/core/di/injection.dart';
import 'package:parkomat/core/l10n/l10n.dart';
import 'package:parkomat/core/routing/app_router.dart';
import 'package:parkomat/presentation/common/widgets/app_icon_tile.dart';
import 'package:parkomat/presentation/common/widgets/wordmark.dart';
import 'package:parkomat/presentation/map/screens/map_screen.dart';

void main() {
  setUp(configureDependencies);
  tearDown(getIt.reset);

  Widget app({bool reduceMotion = false}) {
    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: getIt<AppRouter>().config(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: child!,
      ),
    );
  }

  double opacityOf(WidgetTester tester, Type logo) => tester
      .widget<Opacity>(
        find.ancestor(of: find.byType(logo), matching: find.byType(Opacity)),
      )
      .opacity;

  testWidgets('the logo starts hidden and is fully in after the entrance', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pump();

    expect(opacityOf(tester, AppIconTile), 0);
    expect(opacityOf(tester, Wordmark), 0);

    await tester.pump(const Duration(milliseconds: 1000));

    expect(opacityOf(tester, AppIconTile), 1);
    expect(opacityOf(tester, Wordmark), 1);
    expect(find.byType(MapScreen), findsNothing);
  });

  testWidgets('with Reduce Motion the logo is there from the first frame', (
    tester,
  ) async {
    await tester.pumpWidget(app(reduceMotion: true));
    await tester.pump();

    expect(opacityOf(tester, AppIconTile), 1);
    expect(opacityOf(tester, Wordmark), 1);

    await tester.pumpAndSettle();

    expect(find.byType(MapScreen), findsOneWidget);
  });
}
