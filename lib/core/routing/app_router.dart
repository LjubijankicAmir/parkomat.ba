import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import 'package:parkomat/core/routing/app_router.gr.dart';

@lazySingleton
@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [AutoRoute(page: MapRoute.page, initial: true)];
}
