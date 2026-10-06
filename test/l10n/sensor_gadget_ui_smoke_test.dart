import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/dynamics/AccelerometerExperimentWidget.dart';
import 'package:joyphysics/experiment/dynamics/BarometerExperimentWidget.dart';
import 'package:joyphysics/experiment/dynamics/GyroscopeExperimentWidget.dart';
import 'package:joyphysics/experiment/electroMagnetism/MagnetometerExperimentWidget.dart';
import 'package:joyphysics/experiment/sensor_gadget_l10n.dart';
import 'package:joyphysics/experiment/waves/FrequencyMeasureWidget.dart';
import 'package:joyphysics/experiment/waves/LuxMeasurementWidget.dart';
import 'package:joyphysics/l10n/app_localizations.dart';
import 'package:joyphysics/utils/locale_utils.dart';

Widget _wrap(Widget home, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    localeResolutionCallback: resolveAppLocale,
    home: Scaffold(body: home),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.joyphysics/sensor_check');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    messenger.setMockMethodCallHandler(channel, (call) async => true);
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  Future<void> pumpGadget(WidgetTester tester, Widget gadget) async {
    await tester.pumpWidget(_wrap(gadget));
    // allow async availability check to complete
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('English accelerometer gadget uses English labels', (tester) async {
    await pumpGadget(
      tester,
      const AccelerometerExperimentWidget(useScaffold: false, height: 320),
    );

    expect(find.text('Accelerometer readings'), findsOneWidget);
    expect(find.text('Resultant acceleration'), findsOneWidget);
    expect(find.text('加速度センサーの値'), findsNothing);
    expect(find.text('合成加速度'), findsNothing);
  });

  testWidgets('English gyroscope gadget uses English labels', (tester) async {
    await pumpGadget(
      tester,
      const GyroscopeExperimentWidget(useScaffold: false, height: 320),
    );

    expect(find.text('Gyroscope readings'), findsOneWidget);
    expect(find.text('Resultant angular velocity'), findsOneWidget);
    expect(find.text('ジャイロセンサーの値'), findsNothing);
    expect(find.text('合成角速度'), findsNothing);
  });

  testWidgets('English barometer gadget uses English labels', (tester) async {
    await pumpGadget(
      tester,
      const BarometerExperimentWidget(useScaffold: false, height: 320),
    );

    expect(find.text('Current atmospheric pressure'), findsOneWidget);
    expect(find.text('現在の大気圧'), findsNothing);
  });

  testWidgets('English magnetometer gadget uses English labels', (tester) async {
    await pumpGadget(
      tester,
      const MagnetometerExperimentWidget(
        useScaffold: false,
        height: 320,
        promptBaselineOnStart: false,
      ),
    );

    expect(find.text('Current magnetic field'), findsOneWidget);
    expect(find.textContaining('Resultant field:'), findsOneWidget);
    expect(find.text('Zero at current baseline'), findsOneWidget);
    expect(
      find.text('Magnetic field is within the normal range.'),
      findsOneWidget,
    );
    expect(find.text('現在の磁場強度'), findsNothing);
    expect(find.textContaining('合成磁場'), findsNothing);
    expect(find.textContaining('磁場は正常範囲内'), findsNothing);
  });

  testWidgets('magnetometer baseline prompt and toggle switch modes',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _wrap(
        const MagnetometerExperimentWidget(
          useScaffold: true,
          height: 400,
          promptBaselineOnStart: true,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Use zero baseline?'), findsOneWidget);
    expect(find.text('Set zero baseline'), findsOneWidget);
    expect(find.text('Keep absolute'), findsOneWidget);

    await tester.tap(find.text('Set zero baseline'));
    await tester.pumpAndSettle();

    expect(find.text('Use zero baseline?'), findsNothing);
    final toggle = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(toggle.value, isTrue);
    expect(
      find.text('Relative to captured environment offset'),
      findsOneWidget,
    );

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
    expect(find.text('Sensor absolute values (μT)'), findsOneWidget);
  });

  testWidgets('English magnetometer alert levels cover strong-field warnings',
      (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(
      magnetometerWarningText(ctx, 0),
      'Magnetic field is within the normal range.',
    );
    expect(
      magnetometerWarningText(ctx, 250),
      'A somewhat strong magnetic field was detected.',
    );
    expect(magnetometerWarningText(ctx, 800), 'Strong magnetic field.');
    expect(
      magnetometerWarningText(ctx, 2500),
      'Very strong magnetic field! Be careful of effects on the device.',
    );

    expect(magnetometerAlertColor(0), Colors.green);
    expect(magnetometerAlertColor(250), Colors.yellow.shade700);
    expect(magnetometerAlertColor(800), Colors.orange);
    expect(magnetometerAlertColor(2500), Colors.red);

    // Japanese locale still returns Japanese alerts.
    late BuildContext jaCtx;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            jaCtx = context;
            return const SizedBox.shrink();
          },
        ),
        locale: const Locale('ja'),
      ),
    );
    expect(magnetometerWarningText(jaCtx, 2500), contains('非常に強い磁場'));
  });

  testWidgets('English lux gadget uses English labels', (tester) async {
    await pumpGadget(
      tester,
      const LuxMeasurementWidget(useScaffold: false, height: 320),
    );

    expect(find.text('Current illuminance'), findsOneWidget);
    expect(find.text('現在の照度'), findsNothing);
  });

  testWidgets('English frequency gadget uses English labels', (tester) async {
    await pumpGadget(
      tester,
      const FrequencyMeasureWidget(useScaffold: false, height: 320),
    );

    expect(find.text('Current frequency'), findsOneWidget);
    expect(find.text('現在の周波数'), findsNothing);
  });
}
