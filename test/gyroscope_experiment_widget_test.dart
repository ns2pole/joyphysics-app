import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/dynamics/GyroscopeExperimentWidget.dart';
import 'package:joyphysics/l10n/app_localizations.dart';
import 'package:joyphysics/utils/locale_utils.dart';

Widget _wrap(Widget home, {Locale locale = const Locale('ja')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    localeResolutionCallback: resolveAppLocale,
    home: home,
  );
}

void main() {
  testWidgets('ジャイロセンサー画面が落ちずにタイトルを出す', (tester) async {
    await tester.pumpWidget(
      _wrap(const GyroscopeExperimentWidget()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('ジャイロセンサー'), findsOneWidget);
    expect(find.text('ジャイロセンサーの値'), findsOneWidget);
  });

  testWidgets('埋め込み表示でもカードタイトルが出る', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Scaffold(
          body: GyroscopeExperimentWidget(useScaffold: false),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('ジャイロセンサーの値'), findsOneWidget);
    expect(find.text('ジャイロセンサー'), findsNothing);
  });
}
