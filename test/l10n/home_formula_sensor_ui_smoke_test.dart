import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/ExperimentView.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/sensorListView.dart';
import 'package:joyphysics/l10n/app_localizations.dart';
import 'package:joyphysics/main.dart';
import 'package:joyphysics/utils/locale_utils.dart';

Widget _wrap(Widget home, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    localeResolutionCallback: resolveAppLocale,
    home: home,
  );
}

void main() {
  testWidgets('English locale shows English home chrome buttons', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _wrap(Scaffold(body: CategoryList(categories: categoriesData))),
    );
    await tester.pump();

    expect(find.text('Use Sensors!'), findsOneWidget);
    expect(find.text('Physics Formulas'), findsOneWidget);
    expect(find.textContaining('Mechanics'), findsOneWidget);
    expect(find.textContaining('Electromagnetism'), findsOneWidget);
    expect(find.textContaining('Waves'), findsOneWidget);
    expect(find.textContaining('Thermodynamics'), findsOneWidget);

    expect(find.text('センサーを使う！'), findsNothing);
    expect(find.text('物理公式集'), findsNothing);
  });

  testWidgets('English locale shows English unit/formula toggle', (tester) async {
    final mechanics = categoriesData.firstWhere((c) => c.name == '力学');
    await tester.pumpWidget(_wrap(VideoListView(category: mechanics)));
    await tester.pump();

    expect(find.text('Unit list'), findsOneWidget);
    expect(find.text('Formula list'), findsOneWidget);
    expect(find.text('単元一覧'), findsNothing);
    expect(find.text('公式一覧'), findsNothing);
  });

  testWidgets('English formula list localizes category and article titles',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final electromagnetism =
        categoriesData.firstWhere((c) => c.name == '電磁気学');
    await tester.pumpWidget(_wrap(VideoListView(category: electromagnetism)));
    await tester.pump();

    await tester.tap(find.text('Formula list'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Electromagnetic Force / Lorentz Force'), findsWidgets);
    expect(find.text('電磁力・ローレンツ力'), findsNothing);
    // TitleWithPhysicsBadge embeds a WidgetSpan, so exact find.text may include U+FFFC.
    expect(find.textContaining('Lorentz force'), findsWidgets);
    expect(find.textContaining('ローレンツ力'), findsNothing);
  });

  testWidgets('English sensor list shows localized chrome and names',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_wrap(const SensorListView()));
    await tester.pump();

    expect(find.text('Use Sensors'), findsOneWidget);
    expect(find.text('センサーを使う'), findsNothing);

    expect(find.textContaining('Accelerometer'), findsWidgets);
    expect(find.textContaining('Gyroscope'), findsWidgets);
    expect(find.textContaining('Barometer'), findsWidgets);
    expect(find.textContaining('Magnetic Sensor'), findsWidgets);
    expect(find.textContaining('Frequency Sensor'), findsWidgets);

    expect(find.textContaining('加速度センサー'), findsNothing);
    expect(find.textContaining('ジャイロセンサー'), findsNothing);

    expect(find.text('Sensor experiment articles'), findsOneWidget);
    expect(find.textContaining('センサー実験'), findsNothing);
  });
}
