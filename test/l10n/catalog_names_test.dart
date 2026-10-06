import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/formulaListData.dart';
import 'package:joyphysics/experiment/sensorArticlesData.dart';
import 'package:joyphysics/l10n/catalog_name_localizations.dart';
import 'package:joyphysics/l10n/catalog_names_en.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('major category names have English mappings', () {
    for (final name in [
      '力学',
      '電磁気学',
      '波動',
      '熱力学',
      'センサー',
      '物理のための数学',
      '力学理論',
    ]) {
      expect(kCatalogNamesEn.containsKey(name), isTrue, reason: name);
      expect(localizeCatalogNameForLang('en', name), isNot(name));
      expect(localizeCatalogNameForLang('ja', name), name);
    }
  });

  test('all formulaListData category names have English mappings', () {
    final names = formulaListData.map((f) => f.categoryName).toSet();
    final missing = names.where((n) => !kCatalogNamesEn.containsKey(n)).toList()
      ..sort();
    expect(
      missing,
      isEmpty,
      reason: 'Add English mappings for formula categories:\n${missing.join('\n')}',
    );
    for (final name in names) {
      expect(localizeCatalogNameForLang('en', name), isNot(name), reason: name);
    }
  });

  test('sensor category and type names have English mappings', () {
    final names = <String>{
      kSensorCategoryName,
      ...sensorArticlesByCategory.keys,
      '加速度センサー',
      'ジャイロセンサー',
      '気圧センサー',
      '磁気センサー',
      '周波数センサー',
      '周波数センサー(音波)',
      '光センサー',
    };
    final missing = names.where((n) => !kCatalogNamesEn.containsKey(n)).toList()
      ..sort();
    expect(
      missing,
      isEmpty,
      reason: 'Add English mappings for sensor names:\n${missing.join('\n')}',
    );
    for (final name in names) {
      expect(localizeCatalogNameForLang('en', name), isNot(name), reason: name);
    }
  });
}
