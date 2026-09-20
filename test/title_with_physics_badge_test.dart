import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/shared_components.dart';

void main() {
  testWidgets('2行タイトルでも実験バッジは末尾直後に付く', (tester) async {
    // Ahem は 1 文字 = fontSize。16px × 20 文字 = 320px なので、
    // これより狭い幅ならタイトルが折れて、最終行の直後にバッジが乗る。
    const width = 250.0;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: width,
            child: TitleWithPhysicsBadge(
              title: '浮力(食塩水・普通の水・油での比較)',
              badge: PhysicsBadge(isExperiment: true),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(PhysicsBadge), findsOneWidget);

    final blockRect = tester.getRect(find.byType(TitleWithPhysicsBadge));
    final badgeRect = tester.getRect(find.byType(PhysicsBadge));

    expect(blockRect.height, greaterThan(24), reason: 'タイトルは2行に折れる');
    expect(
      badgeRect.top,
      greaterThan(blockRect.top),
      reason: '実験バッジは最終行の文字の後ろ',
    );
    expect(
      badgeRect.right,
      lessThan(width - 8),
      reason: 'バッジは行の右端ではなくタイトル末尾の直後',
    );
  });

  testWidgets('短いタイトルではバッジは右端ではなく直後', (tester) async {
    const width = 320.0;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: width,
            child: TitleWithPhysicsBadge(
              title: 'コイル',
              badge: PhysicsBadge(isExperiment: true),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final badgeRect = tester.getRect(find.byType(PhysicsBadge));
    expect(
      badgeRect.left,
      lessThan(120),
      reason: '短いタイトルでもバッジを右端に寄せない',
    );
  });
}
