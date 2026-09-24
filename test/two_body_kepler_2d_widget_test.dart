import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/twoBodyKepler2D.dart';

void main() {
  Future<void> pumpSimulation(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PhysicsSimulationView(
              simulation: TwoBodyKepler2DSimulation(),
              height: 760,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('再生とWikiの5プリセットが出る', (tester) async {
    await pumpSimulation(tester);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.restore), findsOneWidget);
    expect(find.text('等質量'), findsOneWidget);
    expect(find.text('冥王星-カロン'), findsOneWidget);
    expect(find.text('地球-月'), findsOneWidget);
    expect(find.text('太陽-地球'), findsOneWidget);
    expect(find.text('楕円交差'), findsOneWidget);
  });

  testWidgets('楕円を押すと e が 0.60 になる', (tester) async {
    await pumpSimulation(tester);
    await tester.ensureVisible(find.text('楕円交差'));
    await tester.tap(find.text('楕円交差'));
    await tester.pump();
    expect(find.text('0.600'), findsWidgets);
  });
}
