import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Set<String> loadAllowlist(String path) {
  final file = File(path);
  expect(file.existsSync(), isTrue, reason: 'missing $path — run scripts/generate_i18n_checklist.py');
  return file
      .readAsLinesSync()
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty && !line.startsWith('#'))
      .toSet();
}

Map<String, dynamic> loadInventory() {
  final file = File('test/l10n/article_inventory.json');
  expect(
    file.existsSync(),
    isTrue,
    reason: 'missing article_inventory.json — run scripts/generate_i18n_checklist.py',
  );
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

List<Map<String, dynamic>> inventoryArticles() {
  final raw = loadInventory()['articles'];
  expect(raw, isA<List>());
  return (raw as List).cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
}

List<Map<String, dynamic>> inventoryAnimationFiles() {
  final raw = loadInventory()['animationFiles'];
  expect(raw, isA<List>());
  return (raw as List).cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
}
