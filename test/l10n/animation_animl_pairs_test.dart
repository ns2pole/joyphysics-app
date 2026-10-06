import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/l10n/anim_ui.dart';

/// Source pairs of `animL(ja, en)` in animation UI files.
List<(String ja, String en, String file)> animationAnimLPairs() {
  final root = Directory('lib/experiment');
  final pairs = <(String, String, String)>[];
  for (final entity in root.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final normalized = entity.path.replaceAll(r'\', '/');
    if (!normalized.contains('/animations/')) continue;
    pairs.addAll(_pairsIn(entity.readAsStringSync(), normalized));
  }
  return pairs;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('animL pairs stay English when Japanese is only a secondary locale', () {
    final dispatcher = TestWidgetsFlutterBinding.instance.platformDispatcher;
    dispatcher.localeTestValue = const Locale('en', 'US');
    dispatcher.localesTestValue = const [
      Locale('en', 'US'),
      Locale('ja', 'JP'),
    ];
    addTearDown(() {
      dispatcher.clearLocaleTestValue();
      dispatcher.clearLocalesTestValue();
    });

    final pairs = animationAnimLPairs();
    expect(pairs.length, greaterThan(1000), reason: 'animL pair scan missed calls');

    final japanese = <String>[];
    for (final pair in pairs) {
      final shown = animL(pair.$1, pair.$2);
      if (shown != pair.$2) {
        japanese.add('${pair.$3}: ${pair.$2}');
        if (japanese.length >= 8) break;
      }
    }
    expect(
      japanese,
      isEmpty,
      reason: 'animL returned Japanese under en-US,ja-JP:\n${japanese.join('\n')}',
    );
  });
}

List<(String, String, String)> _pairsIn(String source, String file) {
  final scan = _Scan(source, file);
  final pairs = <(String, String, String)>[];
  while (scan.i < scan.s.length) {
    scan.skipWsAndComments();
    if (scan.i >= scan.s.length) break;
    if (scan.s.startsWith('animL', scan.i) && scan._atAnimL()) {
      scan.i += 'animL'.length;
      scan.skipWsAndComments();
      if (scan.i >= scan.s.length || scan.s[scan.i] != '(') {
        continue;
      }
      scan.i++;
      final ja = scan.readConcatenatedString();
      scan.skipWsAndComments();
      scan.expect(',');
      final en = scan.readConcatenatedString();
      scan.skipWsAndComments();
      if (scan.s.startsWith(',', scan.i)) {
        scan.i++;
        scan.skipWsAndComments();
      }
      if (!scan.s.startsWith(')', scan.i)) {
        final snippet = scan.s.substring(scan.i, (scan.i + 24).clamp(0, scan.s.length));
        fail('$file: expected ) at ${scan.i} near $snippet\nja=$ja\nen=$en');
      }
      scan.i++;
      pairs.add((ja, en, file));
      continue;
    }
    if (scan.s[scan.i] == "'" || scan.s[scan.i] == '"') {
      scan.readOneString();
      continue;
    }
    scan.i++;
  }
  return pairs;
}

class _Scan {
  _Scan(this.s, this.file);

  final String s;
  final String file;
  int i = 0;

  bool _atAnimL() {
    final before = i == 0 ? '' : s[i - 1];
    if (before.isNotEmpty && RegExp(r'[A-Za-z0-9_]').hasMatch(before)) {
      return false;
    }
    final after = i + 'animL'.length;
    if (after < s.length && RegExp(r'[A-Za-z0-9_]').hasMatch(s[after])) {
      return false;
    }
    return true;
  }

  void skipWsAndComments() {
    while (i < s.length) {
      final ch = s[i];
      if (ch == ' ' || ch == '\n' || ch == '\r' || ch == '\t') {
        i++;
        continue;
      }
      if (ch == '/' && i + 1 < s.length && s[i + 1] == '/') {
        i += 2;
        while (i < s.length && s[i] != '\n') {
          i++;
        }
        continue;
      }
      if (ch == '/' && i + 1 < s.length && s[i + 1] == '*') {
        i += 2;
        while (i + 1 < s.length && !(s[i] == '*' && s[i + 1] == '/')) {
          i++;
        }
        i = (i + 2).clamp(0, s.length);
        continue;
      }
      break;
    }
  }

  void expect(String token) {
    if (!s.startsWith(token, i)) {
      final snippet = s.substring(i, (i + 40).clamp(0, s.length));
      fail('$file: expected $token at $i near $snippet');
    }
    i += token.length;
  }

  String readConcatenatedString() {
    skipWsAndComments();
    final buf = StringBuffer(readOneString());
    while (true) {
      final save = i;
      skipWsAndComments();
      if (i < s.length && (s[i] == "'" || s[i] == '"')) {
        buf.write(readOneString());
      } else {
        i = save;
        break;
      }
    }
    return buf.toString();
  }

  String readOneString() {
    if (i >= s.length || (s[i] != "'" && s[i] != '"')) {
      final snippet = s.substring(i, (i + 40).clamp(0, s.length));
      fail('$file: expected string at $i near $snippet');
    }
    final quote = s[i];
    i++;
    final buf = StringBuffer();
    while (i < s.length) {
      final ch = s[i];
      if (ch == r'\') {
        if (i + 1 >= s.length) break;
        final esc = s[i + 1];
        i += 2;
        buf.write(switch (esc) {
          'n' => '\n',
          't' => '\t',
          'r' => '\r',
          "'" => "'",
          '"' => '"',
          r'\' => r'\',
          '\$' => '\$',
          _ => esc,
        });
        continue;
      }
      if (ch == quote) {
        i++;
        return buf.toString();
      }
      if (ch == r'$' && i + 1 < s.length && s[i + 1] == '{') {
        buf.write(r'${');
        i += 2;
        var depth = 1;
        while (i < s.length && depth > 0) {
          final c = s[i];
          if (c == "'" || c == '"') {
            final nested = readOneString();
            buf.write(c);
            buf.write(nested);
            buf.write(c);
            continue;
          }
          if (c == '{') depth++;
          if (c == '}') depth--;
          buf.write(c);
          i++;
        }
        continue;
      }
      buf.write(ch);
      i++;
    }
    fail('$file: unterminated string');
  }
}
