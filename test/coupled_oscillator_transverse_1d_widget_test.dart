import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/waves/animations/1d/CoupledOscillatorTransverse1D.dart';
import 'package:joyphysics/experiment/waves/animations/1d/coupled_oscillator_transverse_physics.dart';

void main() {
  test('初期は左の質点だけ上に変位している', () {
    final params = CoupledOscillatorTransverse1DSimulation().initialParameters;
    expect(params['n'], kCoupledOscillatorDefaultN);
    expect(params['mode'], 0);
    expect(params['y1']!, greaterThan(0.5));
    expect(params['y2'], 0);
    expect(params['y50'], 0);
    expect(params['y100'], 0);
  });

  testWidgets('デフォルトで Start と N の ± が出て、モードボタンは出ない', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PhysicsSimulationView(
              simulation: CoupledOscillatorTransverse1DSimulation(),
              height: 720,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Start'), findsOneWidget);
    expect(find.text('n=1'), findsNothing);
    expect(find.text('n=2'), findsNothing);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsOneWidget);
  });

  testWidgets('N の + を押すと質点が増える', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PhysicsSimulationView(
              simulation: CoupledOscillatorTransverse1DSimulation(),
              height: 720,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final addButton = find.byIcon(Icons.add);
    await tester.ensureVisible(addButton);
    await tester.pump();
    await tester.tap(addButton);
    await tester.pump();

    expect(find.text('${kCoupledOscillatorDefaultN + 1}'), findsWidgets);
  });
}
