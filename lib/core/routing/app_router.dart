import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import 'package:parkomat/core/routing/app_router.gr.dart';

@lazySingleton
@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),
    // Fades in over the splash, which replaces itself with the map.
    CustomRoute<void>(
      page: MapRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      duration: const Duration(milliseconds: 300),
    ),
  ];
}
