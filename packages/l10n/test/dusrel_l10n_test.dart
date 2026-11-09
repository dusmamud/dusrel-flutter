import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('supports en_US and hi_IN, with en_US first (default)', () {
    // Base locales (en, hi) also exist: gen-l10n requires them as
    // fallbacks for the region locales (en_US, hi_IN).
    expect(
      AppLocalizations.supportedLocales,
      containsAll([
        const Locale('en', 'US'),
        const Locale('en'),
        const Locale('hi'),
        const Locale('hi', 'IN'),
      ]),
    );
    expect(AppLocalizations.supportedLocales.first, const Locale('en', 'US'));
    expect(AppLocalizations.supportedLocales.length, 4);
  });
}
