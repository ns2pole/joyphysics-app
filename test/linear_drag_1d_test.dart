import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/linearDrag1D.dart';

void main() {
  test('g は 9.8 m/s² で、k は g/vt', () {
    expect(kLinearDragG, 9.8);
    expect(linearDragK(5), closeTo(9.8 / 5, 1e-12));
  });

  test('静かに放すと速さは終端速度に近づき、超えない', () {
    const params = LinearDragParams(h: 40, v0: 8, vt: 5);
    final k = linearDragK(5);
    final early = linearDragUnbounded(LinearDragKind.drop, params, 0.4);
    expect(early.v, closeTo(-5 * (1 - math.exp(-k * 0.4)), 1e-9));
    expect(early.a, closeTo(-9.8 * math.exp(-k * 0.4), 1e-9));
    expect(early.y, lessThan(40));
    expect(early.v.abs(), lessThan(5));

    final late = linearDragUnbounded(LinearDragKind.drop, params, 8);
    expect(late.v, closeTo(-5, 1e-3));
    expect(late.a.abs(), lessThan(1e-3));
  });

  test('落下は抵抗なしより着地が遅く、着地の速さは終端速度以下', () {
    const params = LinearDragParams(h: 15, v0: 8, vt: 5);
    final dragT = linearDragFlightDuration(LinearDragKind.drop, params);
    final vacuum = linearDragVacuumAt(LinearDragKind.drop, params, 1e9);
    expect(dragT, greaterThan(vacuum.t));

    final landed = linearDragAt(LinearDragKind.drop, params, dragT);
    expect(landed.y, closeTo(0, 1e-6));
    expect(landed.landed, isTrue);
    expect(landed.v, lessThan(0));
    expect(landed.v.abs(), lessThan(5));
    expect(landed.v.abs(), lessThan(vacuum.v.abs()));

    final later = linearDragAt(LinearDragKind.drop, params, dragT + 4);
    expect(later.t, closeTo(dragT, 1e-9));
    expect(later.y, closeTo(0, 1e-9));
  });

  test('投げ上げの最高点は抵抗なしより低く、戻りは初速より遅い', () {
    const params = LinearDragParams(h: 15, v0: 8, vt: 5);
    final tApex = linearDragApexTime(params);
    final apex = linearDragUnbounded(LinearDragKind.throwUp, params, tApex);
    expect(apex.v, closeTo(0, 1e-9));
    final vacuumH = 64 / (2 * 9.8);
    expect(apex.y, lessThan(vacuumH));
    expect(apex.y, greaterThan(0.5));
    expect(linearDragApexHeight(params), closeTo(apex.y, 1e-9));

    final duration = linearDragFlightDuration(LinearDragKind.throwUp, params);
    expect(duration, greaterThan(tApex));
    final landed = linearDragAt(LinearDragKind.throwUp, params, duration);
    expect(landed.y, closeTo(0, 1e-6));
    expect(landed.v, greaterThan(-8));
    expect(landed.v, lessThan(0));
  });

  test('終端速度より速く投げ下げると加速度は上向きで、速さは減る', () {
    const params = LinearDragParams(h: 20, v0: 10, vt: 4);
    final start = linearDragUnbounded(LinearDragKind.throwDown, params, 0);
    expect(start.v, closeTo(-10, 1e-12));
    expect(start.a, greaterThan(0));
    expect(start.a, closeTo(-9.8 - linearDragK(4) * (-10), 1e-9));

    final later = linearDragUnbounded(LinearDragKind.throwDown, params, 0.6);
    expect(later.v.abs(), lessThan(10));
    expect(later.v.abs(), greaterThan(4));

    final landed = linearDragAt(
      LinearDragKind.throwDown,
      params,
      linearDragFlightDuration(LinearDragKind.throwDown, params),
    );
    expect(landed.v.abs(), lessThan(10));
    expect(landed.v.abs(), greaterThan(4));
  });

  test('点の間隔は落下の後半でほぼ一定になる', () {
    const params = LinearDragParams(h: 30, v0: 8, vt: 4);
    final duration = linearDragFlightDuration(LinearDragKind.drop, params);
    final strobes = linearDragStrobe(LinearDragKind.drop, params, duration);
    expect(strobes.length, greaterThan(6));
    final gaps = <double>[
      for (var i = 1; i < strobes.length; i++) strobes[i - 1].y - strobes[i].y,
    ];
    expect(gaps.first, lessThan(gaps[gaps.length ~/ 2]));
    final tail = gaps.sublist(gaps.length - 3);
    expect((tail.last - tail.first).abs(), lessThan(0.15));
  });

  test('力学の落下運動に速度比例の空気抵抗がある', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final falling = dynamics.subcategories.firstWhere((s) => s.name == '落下運動');
    expect(falling.videos, contains(linearDrag1D));
  });
}
