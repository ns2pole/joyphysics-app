import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/dynamics/GyroscopeExperimentWidget.dart';

void main() {
  testWidgets('ジャイロセンサー画面が落ちずにタイトルを出す', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GyroscopeExperimentWidget(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('ジャイロセンサー'), findsOneWidget);
    expect(find.text('ジャイロセンサーの値'), findsOneWidget);
  });

  testWidgets('埋め込み表示でもカードタイトルが出る', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
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
