import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/dynamics/animations/verticalMotion1D.dart';

void main() {
  test('g は 9.8 m/s²', () {
    expect(kVerticalG, 9.8);
  });

  test('高さ 3 m の自由落下は約 0.78 s で着地する', () {
    const params = VerticalMotionParams(h: 3, v0: 8);
    final t = verticalFlightDuration(VerticalMotionKind.freeFall, params);
    final expected = math.sqrt(2 * 3 / 9.8);
    expect(t, closeTo(expected, 1e-12));
    expect(t, inInclusiveRange(0.7, 0.9));

    final landed = verticalMotionAt(VerticalMotionKind.freeFall, params, t);
    expect(landed.y, closeTo(0, 1e-9));
    expect(landed.v, closeTo(-math.sqrt(2 * 9.8 * 3), 1e-9));
  });

  test('自由落下の途中は地面より上', () {
    const params = VerticalMotionParams(h: 3, v0: 8);
    final t = verticalFlightDuration(VerticalMotionKind.freeFall, params);
    for (var i = 0; i < 8; i++) {
      final s = verticalMotionAt(VerticalMotionKind.freeFall, params, t * i / 8);
      expect(s.y, greaterThan(-1e-9));
      expect(s.v, closeTo(-9.8 * s.t, 1e-12));
    }
    final mid = verticalMotionAt(VerticalMotionKind.freeFall, params, t / 2);
    expect(mid.y, closeTo(3 * 0.75, 1e-9));
  });

  test('鉛直投げ上げは初速の 2 倍を g で割った時間でもとに戻る', () {
    const params = VerticalMotionParams(h: 3, v0: 8);
    final t = verticalFlightDuration(VerticalMotionKind.throwUp, params);
    expect(t, closeTo(2 * 8 / 9.8, 1e-12));
    expect(t, inInclusiveRange(1.4, 1.8));

    final apex = verticalMotionAt(VerticalMotionKind.throwUp, params, t / 2);
    expect(apex.v, closeTo(0, 1e-9));
    expect(apex.y, closeTo(8 * 8 / (2 * 9.8), 1e-9));

    final landed = verticalMotionAt(VerticalMotionKind.throwUp, params, t);
    expect(landed.y, closeTo(0, 1e-9));
    expect(landed.v, closeTo(-8, 1e-9));
  });

  test('投げ下げは同じ高さの自由落下より早く着く', () {
    const params = VerticalMotionParams(h: 3, v0: 4);
    final fall = verticalFlightDuration(VerticalMotionKind.freeFall, params);
    final down = verticalFlightDuration(VerticalMotionKind.throwDown, params);
    expect(down, lessThan(fall));
    expect(down, inInclusiveRange(0.3, fall));

    final landed = verticalMotionAt(VerticalMotionKind.throwDown, params, down);
    expect(landed.y, closeTo(0, 1e-9));
    expect(landed.v.abs(), closeTo(math.sqrt(16 + 2 * 9.8 * 3), 1e-9));
  });
}
