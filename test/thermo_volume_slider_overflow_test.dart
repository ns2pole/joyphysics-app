import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/thermoDynamics/animations/AdiabaticProcess.dart';
import 'package:joyphysics/experiment/thermoDynamics/animations/IsothermalProcess.dart';
import 'package:joyphysics/experiment/waves/animations/widgets/wave_slider.dart';

/// アプリの本文は [bodyMedium] 18px。2行ラベル＋Slider は 92px に収まらない。
ThemeData get _appTheme => ThemeData(
      textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 18)),
    );

void main() {
  testWidgets('2行ラベル＋Slider はテーマ 18px で 92px を超える', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: _appTheme,
        home: Scaffold(
          body: Center(
            child: WaveParameterSlider(
              label: 'ピストンの押し引き\n(体積 V [L])',
              maxLines: 2,
              labelAlign: TextAlign.center,
              labelAbove: true,
              value: 1.0,
              min: 0.3,
              max: 2.0,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    final size = tester.getSize(find.byType(WaveParameterSlider));
    expect(size.height, greaterThan(92));
  });

  testWidgets('断熱の操作スライダーは overflow しない', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: _appTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Column(
                children: AdiabaticSimulation().buildControls(
                  context,
                  {'volume': 1.0},
                  (_, __) {},
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(Slider), findsOneWidget);
  });

  testWidgets('等温の操作スライダーは overflow しない', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: _appTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Column(
                children: IsothermalSimulation().buildControls(
                  context,
                  {'volume': 1.0},
                  (_, __) {},
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(Slider), findsOneWidget);
  });
}
