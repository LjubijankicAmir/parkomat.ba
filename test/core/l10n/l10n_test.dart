import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkomat/core/l10n/l10n.dart';

void main() {
  group('resolveAppLocale', () {
    test('picks Bosnian for languages of the region', () {
      for (final code in ['bs', 'hr', 'sr', 'sh', 'cnr']) {
        expect(
          resolveAppLocale(Locale(code)),
          const Locale('bs'),
          reason: code,
        );
      }
    });

    test('keeps the script and country out of the decision', () {
      expect(
        resolveAppLocale(
          const Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Cyrl'),
        ),
        const Locale('bs'),
      );
      expect(resolveAppLocale(const Locale('hr', 'HR')), const Locale('bs'));
    });

    test('picks English for everyone else', () {
      expect(resolveAppLocale(const Locale('en', 'US')), const Locale('en'));
      expect(resolveAppLocale(const Locale('de')), const Locale('en'));
      expect(resolveAppLocale(null), const Locale('en'));
    });
  });
}
