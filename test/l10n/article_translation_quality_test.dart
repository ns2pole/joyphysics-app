import 'package:flutter_test/flutter_test.dart';

import 'l10n_test_helpers.dart';

final _jpSectionHeaders = RegExp(
  r'(ポイント|問題設定|理論|答え|解説|注意|実験道具)',
);

void main() {
  test('translated articles pass basic English quality checks', () {
    final allow = loadAllowlist('test/l10n/untranslated_allowlist.txt');
    final translated = inventoryArticles()
        .where((a) => a['complete'] == true && !allow.contains(a['id']))
        .toList();

    final problems = <String>[];
    for (final a in translated) {
      final id = a['id'] as String;
      final title = (a['title'] as String?) ?? '';
      final titleEn = (a['titleEn'] as String?) ?? '';
      final latexEn = (a['latexEn'] as String?) ?? '';
      final needsBody = a['needsBody'] == true;
      final mathJa = (a['mathJa'] as num?)?.toInt() ?? 0;
      final mathEn = (a['mathEn'] as num?)?.toInt() ?? 0;

      if (titleEn.isEmpty) {
        problems.add('$id: empty titleEn');
        continue;
      }
      if (titleEn == title && _looksJapanese(title)) {
        problems.add('$id: titleEn equals Japanese title');
      }
      if (needsBody) {
        if (latexEn.trim().isEmpty) {
          problems.add('$id: empty latexEn');
        } else if (_jpSectionHeaders.hasMatch(latexEn)) {
          problems.add('$id: Japanese section header left in latexEn');
        }
        // Allow modest drops: EN prose sometimes unwraps trivial $x$ tokens.
        if (mathJa >= 8 && mathEn < (mathJa * 0.85).floor()) {
          problems.add(
            '$id: math delimiters dropped (ja=$mathJa, en=$mathEn)',
          );
        }
      }
    }

    expect(
      problems,
      isEmpty,
      reason: 'Quality issues:\n${problems.join('\n')}',
    );
  });
}

bool _looksJapanese(String s) =>
    RegExp(r'[\u3040-\u30ff\u4e00-\u9fff]').hasMatch(s);
