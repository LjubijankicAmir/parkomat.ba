import 'package:flutter/material.dart';
import 'package:parkomat/core/di/injection.dart';
import 'package:parkomat/core/l10n/l10n.dart';
import 'package:parkomat/core/routing/app_router.dart';
import 'package:parkomat/core/theme/parkomat_theme.dart';

class ParkomatApp extends StatelessWidget {
  const ParkomatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      theme: ParkomatTheme.light,
      darkTheme: ParkomatTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, _) => resolveAppLocale(locale),
      routerConfig: getIt<AppRouter>().config(),
    );
  }
}
