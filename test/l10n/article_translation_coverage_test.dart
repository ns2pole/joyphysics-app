import 'package:flutter_test/flutter_test.dart';

import 'l10n_test_helpers.dart';

void main() {
  test('incomplete listed articles must stay on the allowlist', () {
    final allow = loadAllowlist('test/l10n/untranslated_allowlist.txt');
    final articles = inventoryArticles();

    final incomplete = articles.where((a) => a['complete'] != true).toList();
    final missingFromAllowlist = incomplete
        .map((a) => a['id'] as String)
        .where((id) => !allow.contains(id))
        .toList()
      ..sort();

    expect(
      missingFromAllowlist,
      isEmpty,
      reason:
          'These articles lack English fields but are not allowlisted. '
          'Either finish the translation or regenerate allowlists:\n'
          '${missingFromAllowlist.join('\n')}',
    );
  });

  test('allowlisted-complete mismatch is not silently ignored', () {
    final allow = loadAllowlist('test/l10n/untranslated_allowlist.txt');
    final articles = inventoryArticles();
    final byId = {for (final a in articles) a['id'] as String: a};

    final unknown = allow.where((id) => !byId.containsKey(id)).toList()..sort();
    expect(
      unknown,
      isEmpty,
      reason: 'Allowlist has unknown article IDs:\n${unknown.join('\n')}',
    );

    // Articles marked complete in inventory should not remain on the allowlist.
    final stale = allow
        .where((id) => byId[id]?['complete'] == true)
        .toList()
      ..sort();
    expect(
      stale,
      isEmpty,
      reason:
          'These IDs are already complete — remove them from '
          'untranslated_allowlist.txt (or regenerate):\n${stale.join('\n')}',
    );
  });
}
