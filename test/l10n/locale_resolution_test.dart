import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/l10n/anim_ui.dart';
import 'package:joyphysics/utils/locale_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('normalizeAppLocale', () {
    test('ja and ja_JP become ja', () {
      expect(normalizeAppLocale(const Locale('ja')), const Locale('ja'));
      expect(normalizeAppLocale(const Locale('ja', 'JP')), const Locale('ja'));
    });

    test('non-Japanese becomes en', () {
      expect(normalizeAppLocale(const Locale('en')), const Locale('en'));
      expect(normalizeAppLocale(const Locale('en', 'US')), const Locale('en'));
      expect(normalizeAppLocale(const Locale('fr')), const Locale('en'));
      expect(normalizeAppLocale(null), const Locale('en'));
    });
  });

  group('resolveAppLocale', () {
    const supported = [Locale('ja'), Locale('en')];

    test('prefers Japanese when device is ja', () {
      expect(
        resolveAppLocale(const Locale('ja', 'JP'), supported),
        const Locale('ja'),
      );
    });

    test('falls back to English otherwise', () {
      expect(
        resolveAppLocale(const Locale('de'), supported),
        const Locale('en'),
      );
    });
  });

  group('animL follows the primary locale', () {
    void setLocales(Locale primary, List<Locale> all) {
      final dispatcher = TestWidgetsFlutterBinding.instance.platformDispatcher;
      dispatcher.localeTestValue = primary;
      dispatcher.localesTestValue = all;
    }

    tearDown(() {
      final dispatcher = TestWidgetsFlutterBinding.instance.platformDispatcher;
      dispatcher.clearLocaleTestValue();
      dispatcher.clearLocalesTestValue();
    });

    test('English primary stays English when Japanese is also installed', () {
      setLocales(
        const Locale('en', 'US'),
        const [Locale('en', 'US'), Locale('ja', 'JP')],
      );
      expect(
        animL('合成波の観測点', 'Observation point of resultant wave'),
        'Observation point of resultant wave',
      );
      expect(animL('圧縮中', 'Compressing'), 'Compressing');
      expect(animL('摩擦', 'Friction'), 'Friction');
    });

    test('Japanese primary stays Japanese', () {
      setLocales(
        const Locale('ja', 'JP'),
        const [Locale('ja', 'JP'), Locale('en', 'US')],
      );
      expect(
        animL('合成波の観測点', 'Observation point of resultant wave'),
        '合成波の観測点',
      );
    });

    test('any non-Japanese primary is English', () {
      setLocales(
        const Locale('fr'),
        const [Locale('fr'), Locale('ja', 'JP')],
      );
      expect(animL('摩擦', 'Friction'), 'Friction');
    });
  });
}
