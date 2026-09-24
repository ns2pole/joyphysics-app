import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/movablePulley1D.dart';

void main() {
  test('m=2 kg、M=2 kg では動滑車が上がり、加速度と張力は公式どおり', () {
    const params = MovablePulleyParams(m: 2, M: 2);
    final alpha = (4 - 2) * 9.8 / (2 + 8);
    final tension = 3 * 2 * 2 * 9.8 / 10;
    expect(params.alpha, closeTo(alpha, 1e-12));
    expect(params.beta, closeTo(2 * alpha, 1e-12));
    expect(params.tension, closeTo(tension, 1e-12));
    expect(params.pulleyRises, isTrue);

    final t = movablePulleyStopTime(params)!;
    expect(t, closeTo(math.sqrt(2 * kMovablePulleyTravel / alpha), 1e-12));

    final start = movablePulleyAt(params, 0);
    expect(start.sPulleyUp, closeTo(0, 1e-12));
    expect(start.sLoadDown, closeTo(0, 1e-12));
    expect(start.stopped, isFalse);

    final mid = movablePulleyAt(params, t / 2);
    expect(mid.sPulleyUp, closeTo(0.5 * alpha * (t / 2) * (t / 2), 1e-9));
    expect(mid.sLoadDown, closeTo(2 * mid.sPulleyUp, 1e-12));
    expect(mid.vLoadDown, closeTo(2 * mid.vPulleyUp, 1e-12));
  });

  test('区間の端で止まり、速さは残る', () {
    const params = MovablePulleyParams(m: 2, M: 2);
    final t = movablePulleyStopTime(params)!;
    final done = movablePulleyAt(params, t);
    expect(done.sPulleyUp, closeTo(kMovablePulleyTravel, 1e-9));
    expect(done.sLoadDown, closeTo(2 * kMovablePulleyTravel, 1e-9));
    expect(done.vPulleyUp, greaterThan(0));
    expect(done.stopped, isTrue);
    expect(done.tension, closeTo(params.tension, 1e-12));

    final later = movablePulleyAt(params, t + 5);
    expect(later.sPulleyUp, closeTo(done.sPulleyUp, 1e-12));
    expect(later.t, closeTo(t, 1e-12));
  });

  test('m > 2M では動滑車が下がる', () {
    const params = MovablePulleyParams(m: 4, M: 1);
    expect(params.alpha, lessThan(0));
    expect(params.beta, closeTo(2 * params.alpha, 1e-12));
    final t = movablePulleyStopTime(params)!;
    final done = movablePulleyAt(params, t);
    expect(done.sPulleyUp, closeTo(-kMovablePulleyTravel, 1e-9));
    expect(done.sLoadDown, closeTo(-2 * kMovablePulleyTravel, 1e-9));
    expect(done.vLoadDown, lessThan(0));
  });

  test('2M = m なら動かない', () {
    const params = MovablePulleyParams(m: 2, M: 1);
    expect(params.balanced, isTrue);
    expect(movablePulleyStopTime(params), isNull);
    expect(params.tension, closeTo(0.5 * 2 * 9.8, 1e-12));
    final later = movablePulleyAt(params, 4);
    expect(later.sPulleyUp, closeTo(0, 1e-12));
    expect(later.stopped, isFalse);
  });

  test('運動中は力学的エネルギーが保存される', () {
    const rising = MovablePulleyParams(m: 2, M: 2);
    const falling = MovablePulleyParams(m: 4, M: 1);
    for (final params in [rising, falling]) {
      final t = movablePulleyStopTime(params)!;
      final start = movablePulleyEnergy(params, movablePulleyAt(params, 0));
      final total0 = start.kinetic + start.potential;
      for (var i = 0; i <= 8; i++) {
        final e = movablePulleyEnergy(params, movablePulleyAt(params, t * i / 8));
        expect(e.kinetic + e.potential, closeTo(total0, 1e-6));
        expect(e.dissipated, closeTo(0, 1e-12));
      }
    }
  });

  test('上がるとき、落ちるおもりが少し高く、定滑車に触れない', () {
    const params = MovablePulleyParams(m: 2, M: 2);
    final start = _scene(params, 0);
    final end = _scene(params, kMovablePulleyTravel);
    expect(start.risingLayout, isTrue);
    expect(start.loadY0, lessThan(start.bobY0 - 20));
    expect(end.axleTop, greaterThan(end.fixedBottom + 20));
    expect(end.loadTop, greaterThan(end.fixedBottom + 16));
    expect((end.loadY - end.loadY0).abs(), closeTo(2 * (end.axleY - end.axleY0).abs(), 0.5));
    expect(end.bobY + end.bobR, lessThan(end.groundY - 8));
    expect(end.loadY + end.loadR, lessThan(end.groundY - 8));
  });

  test('下がるとき、動滑車側が少し高く、上がるおもりが定滑車に触れない', () {
    const params = MovablePulleyParams(m: 4, M: 1);
    final start = _scene(params, 0);
    final end = _scene(params, -kMovablePulleyTravel);
    expect(start.risingLayout, isFalse);
    expect(start.bobY0, lessThan(start.loadY0 - 20));
    expect(start.axleTop, greaterThan(start.fixedBottom + 20));
    expect(end.loadTop, greaterThan(end.fixedBottom + 16));
    expect(end.axleTop, greaterThan(end.fixedBottom + 20));
    expect(end.bobY + end.bobR, lessThan(end.groundY - 8));
    expect(end.loadY + end.loadR, lessThan(end.groundY - 8));
  });

  test('力学の滑車に動滑車がある', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final pulley = dynamics.subcategories.firstWhere((s) => s.name == '滑車');
    expect(pulley.videos, contains(movablePulley1D));
    expect(movablePulley1D.title, '動滑車');
  });
}

MovablePulleyLayout _scene(MovablePulleyParams params, double sPulleyUp) {
  return layoutMovablePulley(
    width: 360,
    height: 600,
    hudBottom: 140,
    params: params,
    sPulleyUp: sPulleyUp,
  );
}
