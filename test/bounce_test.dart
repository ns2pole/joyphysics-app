import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/dynamics/animations/bounce.dart';

void main() {
  test('自由落下の次の高さは e²H', () {
    const h = 3.0;
    const e = 0.5;
    final legs = bounce1DLegs(Bounce1DKind.freeFall, h, 8, e);
    final impactVy = legs.first.vy0 - kBounceG * legs.first.dt;
    expect(impactVy, closeTo(-math.sqrt(2 * kBounceG * h), 1e-9));

    final rebound = bounceAt(legs, legs.first.t1 + 1e-4);
    expect(rebound.bounces, 1);
    expect(rebound.vy, closeTo(e * impactVy.abs(), 0.02));

    final nextApexT = legs[1].t0 + legs[1].vy0 / kBounceG;
    final apex = bounceAt(legs, nextApexT);
    expect(apex.y, closeTo(e * e * h, 1e-6));
    expect(apex.vy.abs(), lessThan(1e-6));
  });

  test('投げ上げは地面からではなく高さ H から上向き', () {
    final legs = bounce1DLegs(Bounce1DKind.throwUp, 2, 6, 0.8);
    final start = bounceAt(legs, 0);
    expect(start.y, closeTo(2, 1e-12));
    expect(start.vy, closeTo(6, 1e-12));
  });

  test('投げ下げは下向きの初速度', () {
    final legs = bounce1DLegs(Bounce1DKind.throwDown, 3, 4, 0);
    final start = bounceAt(legs, 0);
    expect(start.vy, closeTo(-4, 1e-12));
    final end = bounceAt(legs, bounceDuration(legs));
    expect(end.resting, isTrue);
    expect(end.y, closeTo(0, 1e-9));
    expect(legs.length, 1);
  });

  test('斜方投射は着地で vx が残し vy だけ e 倍', () {
    final legs = bounce2DLegs(45, 10, 0.5);
    final landed = bounceAt(legs, legs.first.t1 - 1e-5);
    final after = bounceAt(legs, legs.first.t1 + 1e-4);
    expect(after.vx, closeTo(landed.vx, 1e-9));
    expect(after.vy, closeTo(-0.5 * landed.vy, 0.02));
    expect(after.vy, greaterThan(0));
    final flat = 10 * 10 / kBounceG;
    final firstRange = legs.first.vx * legs.first.dt;
    expect(firstRange, closeTo(flat, 1e-6));

    final down = bounce2DLegs(-40, 10, 0.6, h: 4);
    expect(bounceAt(down, 0).vy, lessThan(0));
    expect(down.first.dt, greaterThan(0.05));
    final afterDown = bounceAt(down, down.first.t1 + 1e-4);
    expect(afterDown.vy, greaterThan(0));
    expect(afterDown.vx, closeTo(down.first.vx, 1e-9));
    expect(afterDown.y, closeTo(0, 0.02));

    final cliff = bounce2DLegs(45, 10, 0.5, h: 3);
    expect(bounceAt(cliff, 0).y, closeTo(3, 1e-12));
    expect(cliff.first.dt, greaterThan(legs.first.dt));
  });
}
