import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/twoBodySpring1D.dart';

void main() {
  Future<void> pumpSimulation(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PhysicsSimulationView(
              simulation: TwoBodySpring1DSimulation(),
              height: 820,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('初期条件プリセットの4ボタンが出る', (tester) async {
    await pumpSimulation(tester);
    expect(find.text('遠ざけて配置'), findsOneWidget);
    expect(find.text('近づけて配置'), findsOneWidget);
    expect(find.text('右のみ初速あり'), findsOneWidget);
    expect(find.text('左のみ初速あり'), findsOneWidget);
  });

  testWidgets('遠ざけて配置を押すと間隔が自然長より広がる', (tester) async {
    await pumpSimulation(tester);
    await tester.ensureVisible(find.text('遠ざけて配置'));
    await tester.tap(find.text('遠ざけて配置'));
    await tester.pump();
    expect(find.text('-3.00'), findsWidgets);
    expect(find.text('3.00'), findsWidgets);
  });
}
