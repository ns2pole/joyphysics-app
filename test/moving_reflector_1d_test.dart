import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/waves/animations/1d/MovingReflector1D.dart';
import 'package:joyphysics/experiment/waves/animations/fields/wave_fields.dart';
import 'package:joyphysics/experiment/waves/animations/painters/wave_line_painter.dart';

void main() {
  test('入射軸は上、反射軸は下で、振幅 0.6 でも重ならない', () {
    expect(kMovingReflectorIncidentAxisY, greaterThan(0));
    expect(kMovingReflectorReflectedAxisY, lessThan(0));
    const amplitude = 0.6;
    expect(
      kMovingReflectorIncidentAxisY - amplitude,
      greaterThan(kMovingReflectorReflectedAxisY + amplitude),
    );
    expect(
      WaveLinePainter.plotY(0.2, 'incident', kMovingReflectorAxisOffsets),
      closeTo(kMovingReflectorIncidentAxisY + 0.2, 1e-12),
    );
    expect(
      WaveLinePainter.plotY(-0.3, 'reflected', kMovingReflectorAxisOffsets),
      closeTo(kMovingReflectorReflectedAxisY - 0.3, 1e-12),
    );
  });

  test('観測点パラメータは持たず、壁の初期位置 x0 を持つ', () {
    final params = MovingReflector1DSimulation().initialParameters;
    expect(params.containsKey('obsX'), isFalse);
    expect(params.containsKey('obsY'), isFalse);
    expect(params['x0'], 2.0);
  });

  test('入射波は左端の外から入り、先にはまだ届かない', () {
    const field = MovingReflectorField(
      lambda: 2.0,
      periodT: 1.0,
      v: 0.0,
      x0: 2.0,
      isFixedEnd: true,
      amplitude: 0.6,
    );
    expect(MovingReflectorField.sourceX, -7.5);
    expect(field.z(-5.0, 0, 0), 0);
    expect(field.z(0.0, 0, 0), 0);

    // t=2 で波面は x = -7.5 + 2*2 = -3.5。x=-4 は到達済み、x=0 は未到達。
    expect(field.z(-4.0, 0, 2.0), closeTo(0.6, 1e-9));
    expect(field.z(0.0, 0, 2.0), 0);
    expect(
      field.getComponents(-4.0, 0, 2.0, {'reflected'}).single.value,
      0,
    );
  });

  test('静止した固定端は1次元固定端反射と同じ', () {
    const moving = MovingReflectorField(
      lambda: 2.0,
      periodT: 1.0,
      v: 0.0,
      x0: 5.0,
      isFixedEnd: true,
      amplitude: 0.6,
    );
    const fixed = OneDimensionReflectionField(
      lambda: 2.0,
      periodT: 1.0,
      mode: ReflectionMode.combined,
      isFixedEnd: true,
      boundaryX: 5.0,
      amplitude: 0.6,
    );
    for (final t in [0.0, 2.0, 6.0, 8.0]) {
      for (final x in [-5.0, -2.0, 0.0, 3.0, 5.0]) {
        expect(
          moving.z(x, 0, t),
          closeTo(fixed.z(x, 0, t), 1e-9),
          reason: 'x=$x t=$t',
        );
      }
    }
  });

  testWidgets('動く物体による反射は入射・反射を別軸で描き、観測点は出ない', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PhysicsSimulationView(
              simulation: MovingReflector1DSimulation(),
              height: 640,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('入射波'), findsOneWidget);
    expect(find.text('反射波'), findsOneWidget);
    expect(find.textContaining('観測点'), findsNothing);
    expect(find.text('初期位置 x₀'), findsOneWidget);

    final x0Slider = find.descendant(
      of: find.ancestor(
        of: find.text('初期位置 x₀'),
        matching: find.byType(Row),
      ).first,
      matching: find.byType(Slider),
    );
    expect(tester.widget<Slider>(x0Slider).value, 2.0);
    expect(tester.widget<Slider>(x0Slider).min, -5.0);
    expect(tester.widget<Slider>(x0Slider).max, 5.0);

    final painter = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((w) => w.painter)
        .whereType<WaveLinePainter>()
        .first;
    expect(painter.componentAxisOffsets['incident'],
        kMovingReflectorIncidentAxisY);
    expect(painter.componentAxisOffsets['reflected'],
        kMovingReflectorReflectedAxisY);
    expect(painter.componentAxisLabels['incident'], '入射');
    expect(painter.componentAxisLabels['reflected'], '反射');
    expect(painter.markers, isEmpty);
  });
}
