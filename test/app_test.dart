import 'package:flutter_test/flutter_test.dart';
import 'package:parkomat/app.dart';
import 'package:parkomat/core/di/injection.dart';

void main() {
  setUp(configureDependencies);
  tearDown(getIt.reset);

  testWidgets('ParkomatApp opens on the map screen', (tester) async {
    await tester.pumpWidget(const ParkomatApp());
    await tester.pumpAndSettle();

    expect(find.text('Parkomat.ba'), findsOneWidget);
  });
}
