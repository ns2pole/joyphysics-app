import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/thermoDynamics/animations/common.dart';

void main() {
  testWidgets('定積・定圧: Auto・断熱・冷却・加熱が1行', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: buildThermoInsulationHeatControls(
              activeIds: const {},
              updateActiveIds: (_) {},
              atMaxTemp: false,
              atMinTemp: false,
              coolingRequiresUninsulated: true,
              heatingRequiresInsulation: true,
              autoOn: false,
              onAutoChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    final centers = [
      tester.getCenter(find.text('Auto')),
      tester.getCenter(find.widgetWithText(FilterChip, '断熱')),
      tester.getCenter(find.widgetWithText(FilterChip, '冷却')),
      tester.getCenter(find.widgetWithText(FilterChip, '加熱')),
    ];
    for (final c in centers.skip(1)) {
      expect((c.dy - centers.first.dy).abs(), lessThan(1.0));
    }
  });

  testWidgets('熱サイクル: Auto・断熱・加熱が1行（冷却なし）', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: buildThermoInsulationHeatControls(
              activeIds: const {'insulated'},
              updateActiveIds: (_) {},
              atMaxTemp: false,
              atMinTemp: false,
              showCooling: false,
              heatingRequiresInsulation: true,
              autoOn: false,
              onAutoChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.widgetWithText(FilterChip, '冷却'), findsNothing);
    final centers = [
      tester.getCenter(find.text('Auto')),
      tester.getCenter(find.widgetWithText(FilterChip, '断熱')),
      tester.getCenter(find.widgetWithText(FilterChip, '加熱')),
    ];
    for (final c in centers.skip(1)) {
      expect((c.dy - centers.first.dy).abs(), lessThan(1.0));
    }
  });
}
