import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/l10n/app_localizations.dart';
import 'package:joyphysics/search/article_search_page.dart';
import 'package:joyphysics/utils/locale_utils.dart';

void main() {
  testWidgets('English locale shows English search chrome', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        localeResolutionCallback: resolveAppLocale,
        home: const Scaffold(body: HomeArticleSearchBox()),
      ),
    );

    expect(find.text('Keyword search'), findsOneWidget);
    expect(find.text('キーワード検索'), findsNothing);
  });

  testWidgets('Japanese locale keeps Japanese search chrome', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ja'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        localeResolutionCallback: resolveAppLocale,
        home: const Scaffold(body: HomeArticleSearchBox()),
      ),
    );

    expect(find.text('キーワード検索'), findsOneWidget);
    expect(find.text('Keyword search'), findsNothing);
  });
}
