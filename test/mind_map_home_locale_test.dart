import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/ExperimentView.dart';
import 'package:joyphysics/l10n/app_localizations.dart';
import 'package:joyphysics/model.dart';
import 'package:joyphysics/theory/TheoryView.dart';
import 'package:joyphysics/utils/locale_utils.dart';

Widget _wrap(Widget home, {required Locale locale}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    localeResolutionCallback: resolveAppLocale,
    home: home,
  );
}

String? _assetName(Image image) {
  final provider = image.image;
  if (provider is AssetImage) return provider.assetName;
  return null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final homes = <String, String>{
    '力学': 'assets/mindMap/en/dynamicsLandScope.jpeg',
    '電磁気学': 'assets/mindMap/en/emTheoryLandScope.jpeg',
    '熱力学': 'assets/mindMap/en/thermoDynamicsLandScope.jpeg',
    '波動': 'assets/mindMap/en/waveLandScope.jpeg',
  };

  for (final entry in homes.entries) {
    testWidgets('english experiment home shows ${entry.key} overview', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          VideoListView(
            category: Category(
              name: entry.key,
              gifUrl: '',
              subcategories: [],
            ),
          ),
          locale: const Locale('en'),
        ),
      );
      await tester.pump();

      final assets = tester
          .widgetList<Image>(find.byType(Image))
          .map(_assetName)
          .whereType<String>()
          .toList();
      expect(assets, contains(entry.value));
      expect(assets, isNot(contains(entry.value.replaceAll('/en/', '/'))));
    });
  }

  testWidgets('japanese experiment home keeps the japanese overview', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        VideoListView(
          category: Category(name: '力学', gifUrl: '', subcategories: []),
        ),
        locale: const Locale('ja'),
      ),
    );
    await tester.pump();

    final assets = tester
        .widgetList<Image>(find.byType(Image))
        .map(_assetName)
        .whereType<String>()
        .toList();
    expect(assets, contains('assets/mindMap/dynamicsLandScope.jpeg'));
    expect(assets, isNot(contains('assets/mindMap/en/dynamicsLandScope.jpeg')));
  });

  testWidgets('english theory home shows the english mechanics overview', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TheoryListView(categoryName: '力学理論'),
        locale: const Locale('en'),
      ),
    );
    await tester.pump();

    final assets = tester
        .widgetList<Image>(find.byType(Image))
        .map(_assetName)
        .whereType<String>()
        .toList();
    expect(assets, contains('assets/mindMap/en/dynamicsLandScope.jpeg'));
    expect(assets, isNot(contains('assets/mindMap/dynamicsLandScope.jpeg')));
  });
}
