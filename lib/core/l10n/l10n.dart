import 'package:flutter/widgets.dart';
import 'package:parkomat/core/l10n/generated/app_localizations.dart';

export 'package:parkomat/core/l10n/generated/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Languages whose speakers read Bosnian without effort.
const _regionalLanguages = {'bs', 'hr', 'sr', 'sh', 'cnr'};

/// The app's language for a device set to [deviceLocale].
///
/// Bosnian for anyone whose phone is in a language of the region, English
/// for everyone else, so visitors don't land in a language they can't read.
Locale resolveAppLocale(Locale? deviceLocale) {
  return _regionalLanguages.contains(deviceLocale?.languageCode)
      ? const Locale('bs')
      : const Locale('en');
}
