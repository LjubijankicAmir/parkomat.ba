import 'package:flutter_test/flutter_test.dart';
import 'package:parkomat/app.dart';
import 'package:parkomat/core/di/injection.dart';
import 'package:parkomat/presentation/map/screens/map_screen.dart';
import 'package:parkomat/presentation/splash/screens/splash_screen.dart';

void main() {
  setUp(configureDependencies);
  tearDown(getIt.reset);

  testWidgets('ParkomatApp opens on the splash, then the map', (tester) async {
    await tester.pumpWidget(const ParkomatApp());
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(MapScreen), findsOneWidget);
  });
}
