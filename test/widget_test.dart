// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:joyphysics/main.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(JoyPhysicsApp());
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    // At least the app should mount without throwing.
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Home shows version under the title', (WidgetTester tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'joyphysics',
      packageName: 'com.joyphysics',
      version: '7.0.0',
      buildNumber: '107',
      buildSignature: '',
    );

    await tester.pumpWidget(JoyPhysicsApp());
    await tester.pump();

    expect(find.text('高校物理'), findsOneWidget);
    expect(find.text('ver 7.0.0'), findsOneWidget);
    expect(find.text('update 2026-09-24'), findsOneWidget);
  });
}
