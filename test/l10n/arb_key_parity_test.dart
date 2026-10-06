import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _loadArb(String path) {
  final file = File(path);
  expect(file.existsSync(), isTrue, reason: 'missing $path');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

Set<String> _messageKeys(Map<String, dynamic> arb) {
  return arb.keys
      .where((k) => !k.startsWith('@') && k != '@@locale')
      .toSet();
}

void main() {
  test('app_ja.arb and app_en.arb have the same message keys', () {
    final ja = _loadArb('lib/l10n/app_ja.arb');
    final en = _loadArb('lib/l10n/app_en.arb');

    final jaKeys = _messageKeys(ja);
    final enKeys = _messageKeys(en);

    expect(enKeys.difference(jaKeys), isEmpty, reason: 'keys only in en');
    expect(jaKeys.difference(enKeys), isEmpty, reason: 'keys only in ja');

    for (final key in jaKeys) {
      final jaValue = ja[key];
      final enValue = en[key];
      expect(jaValue, isA<String>());
      expect(enValue, isA<String>());
      expect((jaValue as String).trim(), isNotEmpty, reason: 'empty ja:$key');
      expect((enValue as String).trim(), isNotEmpty, reason: 'empty en:$key');

      final jaMeta = ja['@$key'];
      final enMeta = en['@$key'];
      if (jaMeta is Map || enMeta is Map) {
        final jaPlaceholders =
            (jaMeta is Map ? jaMeta['placeholders'] as Map? : null)?.keys.toSet() ??
                {};
        final enPlaceholders =
            (enMeta is Map ? enMeta['placeholders'] as Map? : null)?.keys.toSet() ??
                {};
        expect(
          enPlaceholders,
          jaPlaceholders,
          reason: 'placeholder mismatch for $key',
        );
      }
    }
  });
}
