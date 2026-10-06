import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'l10n_test_helpers.dart';

final _jp = RegExp(r'[\u3040-\u30ff\u4e00-\u9fff]');
final _singleQuoted = RegExp(r"'([^'\\]*(?:\\.[^'\\]*)*)'");
final _doubleQuoted = RegExp(r'"([^"\\]*(?:\\.[^"\\]*)*)"');
final _ctorStart = RegExp(r'(?:createWaveVideo|Video)\s*\(');
final _wrapperStart = RegExp(r'\b(?:animL|animUiForLang|animUi)\s*\(');

String _stripLineComments(String text) =>
    text.replaceAll(RegExp(r'//.*?$', multiLine: true), '');

String _maskParenBlock(String text, int openParenIndex) {
  var depth = 0;
  String? inStr;
  var escape = false;
  for (var j = openParenIndex; j < text.length; j++) {
    final ch = text[j];
    if (inStr != null) {
      if (escape) {
        escape = false;
      } else if (ch == r'\') {
        escape = true;
      } else if (ch == inStr) {
        inStr = null;
      }
      continue;
    }
    if (ch == "'" || ch == '"') {
      inStr = ch;
      continue;
    }
    if (ch == '(') {
      depth++;
    } else if (ch == ')') {
      depth--;
      if (depth == 0) {
        return text.substring(0, openParenIndex) +
            (' ' * (j - openParenIndex + 1)) +
            text.substring(j + 1);
      }
    }
  }
  return text;
}

String _stripArticleCtors(String text) {
  var out = text;
  while (true) {
    final m = _ctorStart.firstMatch(out);
    if (m == null) break;
    final open = out.indexOf('(', m.start);
    if (open < 0) break;
    final next = _maskParenBlock(out, open);
    if (identical(next, out) || next == out) break;
    out = next;
  }
  return out;
}

String _maskBilingualWrappers(String text) {
  var out = text;
  while (true) {
    final m = _wrapperStart.firstMatch(out);
    if (m == null) break;
    final open = out.indexOf('(', m.start);
    if (open < 0) break;
    final next = _maskParenBlock(out, open);
    if (identical(next, out) || next == out) break;
    out = next;
  }
  // Article-like HTML companions outside Video ctors.
  out = out.replaceAllMapped(
    RegExp("'[^']*common-box[^']*'|" + r'"[^"]*common-box[^"]*"'),
    (m) => ' ' * m.group(0)!.length,
  );
  out = out.replaceAllMapped(
    RegExp("'[^']*<div[^']*'|" + r'"[^"]*<div[^"]*"', caseSensitive: false),
    (m) => ' ' * m.group(0)!.length,
  );
  return out;
}

Iterable<String> _stringLiterals(String text) sync* {
  for (final match in _singleQuoted.allMatches(text)) {
    yield match.group(1) ?? '';
  }
  for (final match in _doubleQuoted.allMatches(text)) {
    yield match.group(1) ?? '';
  }
}

bool _fileHasUntranslatedJapaneseUi(String path) {
  var text = File(path).readAsStringSync();
  text = _stripLineComments(text);
  text = _stripArticleCtors(text);
  text = _maskBilingualWrappers(text);
  for (final s in _stringLiterals(text)) {
    if (s.isEmpty) continue;
    if (s.startsWith('package:') || s.startsWith('assets/')) continue;
    if (_jp.hasMatch(s)) return true;
  }
  return false;
}

String _normalizePath(String path) => path.replaceAll(r'\', '/');

void main() {
  test('animation files with Japanese UI must be allowlisted', () {
    final allow = loadAllowlist('test/l10n/untranslated_animation_allowlist.txt');
    final root = Directory('lib/experiment');
    expect(root.existsSync(), isTrue);

    final offenders = <String>[];
    for (final entity in root.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final normalized = _normalizePath(entity.path);
      if (!normalized.contains('/animations/')) continue;
      if (!_fileHasUntranslatedJapaneseUi(normalized)) continue;
      if (!allow.contains(normalized)) {
        offenders.add(normalized);
      }
    }
    offenders.sort();

    expect(
      offenders,
      isEmpty,
      reason:
          'Japanese UI literals found outside animation allowlist:\n'
          '${offenders.join('\n')}\n'
          'Wrap with animL/animUi or regenerate allowlists.',
    );
  });

  test('animation allowlist entries still exist', () {
    final allow = loadAllowlist('test/l10n/untranslated_animation_allowlist.txt');
    final missing = allow.where((path) => !File(path).existsSync()).toList()
      ..sort();
    expect(
      missing,
      isEmpty,
      reason: 'Allowlist paths missing on disk:\n${missing.join('\n')}',
    );
  });

  test('shared simulation chrome has no raw Japanese UI', () {
    const files = [
      'lib/experiment/PhysicsAnimationBase.dart',
      'lib/experiment/PhysicsAnimationScaffold.dart',
      'lib/experiment/waves/ToneGeneratorWidget.dart',
      'lib/experiment/waves/BeatExperimentWidget.dart',
      'lib/experiment/sensor_app_store_dialog.dart',
    ];
    final offenders = [
      for (final path in files)
        if (_fileHasUntranslatedJapaneseUi(path)) path,
    ];
    expect(
      offenders,
      isEmpty,
      reason:
          'Japanese UI literals outside animL/animUi:\n${offenders.join('\n')}',
    );
  });

  test('animation allowlist matches inventory', () {
    final inventory =
        inventoryAnimationFiles().map((e) => e['file'] as String).toSet();
    final allow = loadAllowlist('test/l10n/untranslated_animation_allowlist.txt');
    expect(
      allow.difference(inventory),
      isEmpty,
      reason: 'Allowlist has files not in inventory — regenerate checklists.',
    );
  });
}
