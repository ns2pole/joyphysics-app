import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/high_pitch_sound_warning.dart';
import 'package:joyphysics/l10n/anim_ui.dart';
import 'package:joyphysics/experiment/waves/ToneGeneratorWidget.dart';
import 'package:joyphysics/experiment/waves/dopplerMovingWall.dart';
import 'package:joyphysics/shared_components.dart';

String get _warnTitle =>
    animL(highPitchSoundWarningTitle, 'A high-pitched sound will play');
String get _warnMessage => animL(
      highPitchSoundWarningMessage,
      'The YouTube video plays a high-pitched sound. Please be careful if that is hard to listen to.',
    );
String get _back => animL('戻る', 'Back');

void main() {
  test('動く壁の記事はタップ警告なし・高音警告あり', () {
    expect(dopplerMovingWall.playsSound, isFalse);
    expect(dopplerMovingWall.warnsHighPitchSound, isTrue);
    final tone = dopplerMovingWall.experimentWidgets!
        .whereType<ToneGeneratorWidget>()
        .single;
    expect(tone.initialFreq, 11074);
    expect(tone.warnHighPitchSound, isTrue);
  });

  testWidgets('確認ダイアログは戻ると false、OK で true', (tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await confirmHighPitchSound(context);
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text(_warnTitle), findsOneWidget);
    expect(find.text(_warnMessage), findsOneWidget);

    await tester.tap(find.text(_back));
    await tester.pumpAndSettle();
    expect(result, isFalse);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('HighPitchPlayGate は戻ると再生せず、OK で解除する', (tester) async {
    var confirmedCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 120,
            child: HighPitchPlayGate(
              onConfirmed: () async {
                confirmedCount++;
              },
              child: const ColoredBox(
                key: Key('gated-child'),
                color: Colors.red,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('gated-child')), findsNothing);

    await tester.tap(find.byIcon(Icons.play_circle_fill));
    await tester.pumpAndSettle();
    expect(find.text(_warnTitle), findsOneWidget);

    await tester.tap(find.text(_back));
    await tester.pumpAndSettle();
    expect(confirmedCount, 0);
    expect(find.byIcon(Icons.play_circle_fill), findsOneWidget);
    expect(find.byKey(const Key('gated-child')), findsNothing);

    await tester.tap(find.byIcon(Icons.play_circle_fill));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(confirmedCount, 1);
    expect(find.byIcon(Icons.play_circle_fill), findsNothing);
    expect(find.text(_warnTitle), findsNothing);
    expect(find.byKey(const Key('gated-child')), findsOneWidget);
  });

  testWidgets('11074Hz 再生ボタンで高音注意を出す', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ToneGeneratorWidget(
            initialFreq: 11074,
            minFreq: 8000,
            maxFreq: 13000,
            height: 180,
            warnHighPitchSound: true,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text(animL('再生', 'Play')));
    await tester.pumpAndSettle();
    expect(find.text(_warnTitle), findsOneWidget);
    expect(find.text(_warnMessage), findsOneWidget);

    await tester.tap(find.text(_back));
    await tester.pumpAndSettle();
    expect(find.text(animL('再生', 'Play')), findsOneWidget);
    expect(find.text(animL('再生中', 'Playing')), findsNothing);
  });

  testWidgets('高音警告のYouTubeは確認前にプレイヤーを出さない', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PhysicsYouTubePlayer(
            videoURL: 'C6Mq7apCUcU',
            warnHighPitchSound: true,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.play_circle_fill), findsOneWidget);
    await tester.tap(find.byIcon(Icons.play_circle_fill));
    await tester.pumpAndSettle();
    expect(find.text(_warnTitle), findsOneWidget);

    await tester.tap(find.text(_back));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.play_circle_fill), findsOneWidget);
  });
}
