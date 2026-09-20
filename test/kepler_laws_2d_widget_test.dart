import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/keplerLaws2D.dart';

void main() {
  Future<void> pumpSimulation(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PhysicsSimulationView(
              simulation: KeplerLaws2DSimulation(),
              height: 760,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('再生と3法則ボタンだけが出る', (tester) async {
    await pumpSimulation(tester);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('リセット'), findsOneWidget);
    expect(find.text('第1法則'), findsOneWidget);
    expect(find.text('第2法則'), findsOneWidget);
    expect(find.text('第3法則'), findsOneWidget);
    expect(
      find.text('1秒ごとに面積を塗っています。'),
      findsNothing,
    );
    expect(
      find.text('外側は a を2倍。周期は 2√2 倍なので、内側が3周いかないうちに外側が1周します。'),
      findsNothing,
    );
    expect(find.text('円軌道'), findsNothing);
    expect(find.text('扁平（面積速度）'), findsNothing);
    expect(find.text('周期が2倍'), findsNothing);
    expect(find.text('第1 空の焦点'), findsNothing);
    expect(find.text('第2 等時間の扇形'), findsNothing);
    expect(find.text('第3 周期2倍の軌道'), findsNothing);
    expect(find.text('全パラメータ初期化'), findsNothing);
  });

  testWidgets('第3法則のあと第2法則で扁平に戻る', (tester) async {
    await pumpSimulation(tester);
    await tester.ensureVisible(find.text('第3法則'));
    await tester.tap(find.text('第3法則'));
    await tester.pump();
    expect(find.text('0.40'), findsWidgets);
    expect(
      find.text('外側は a を2倍。周期は 2√2 倍なので、内側が3周いかないうちに外側が1周します。'),
      findsOneWidget,
    );
    await tester.tap(find.text('第2法則'));
    await tester.pump();
    expect(find.text(kKeplerDefaultE.toStringAsFixed(2)), findsWidgets);
    expect(
      find.text('1秒ごとに面積を塗っています。'),
      findsOneWidget,
    );
  });
}
