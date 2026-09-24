import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/kineticFriction1D.dart';
import 'package:joyphysics/experiment/dynamics/animations/kineticFrictionIncline1D.dart';

void main() {
  test('標準の傾角では減速して公式どおりに止まる', () {
    const params = KineticFrictionInclineParams(v0: 4, mu: 0.40, muS: 0.55, thetaDeg: 15);
    final a = kineticFrictionInclineAccel(params);
    final th = 15 * math.pi / 180;
    expect(a, closeTo(9.8 * (math.sin(th) - 0.40 * math.cos(th)), 1e-12));
    expect(a, lessThan(0));

    final t = kineticFrictionInclineStopTime(params)!;
    final s = kineticFrictionInclineStopDistance(params)!;
    expect(t, closeTo(4 / -a, 1e-12));
    expect(s, closeTo(16 / (2 * -a), 1e-12));

    final start = kineticFrictionInclineAt(params, 0);
    expect(start.s, closeTo(0, 1e-12));
    expect(start.v, closeTo(4, 1e-12));
    expect(start.a, closeTo(a, 1e-12));
    expect(start.stopped, isFalse);

    final stopped = kineticFrictionInclineAt(params, t + 2);
    expect(stopped.s, closeTo(s, 1e-9));
    expect(stopped.v, closeTo(0, 1e-9));
    expect(stopped.a, closeTo(0, 1e-12));
    expect(stopped.stopped, isTrue);
    expect(stopped.t, closeTo(t, 1e-12));
  });

  test('θ = 0 は水平面の動摩擦力に一致する', () {
    const incline = KineticFrictionInclineParams(v0: 4, mu: 0.20, muS: 0.35, thetaDeg: 0);
    const flat = KineticFrictionParams(v0: 4, mu: 0.20);
    expect(
      kineticFrictionInclineAccel(incline),
      closeTo(-0.20 * 9.8, 1e-12),
    );
    expect(
      kineticFrictionInclineStopTime(incline),
      closeTo(kineticFrictionStopTime(flat)!, 1e-12),
    );
    expect(
      kineticFrictionInclineStopDistance(incline),
      closeTo(kineticFrictionStopDistance(flat)!, 1e-12),
    );
    final mid = kineticFrictionInclineAt(incline, 0.4);
    final flatMid = kineticFrictionAt(flat, 0.4);
    expect(mid.s, closeTo(flatMid.x, 1e-9));
    expect(mid.v, closeTo(flatMid.v, 1e-9));
  });

  test('μ が tanθ より小さいと加速し、等しいと等速、大きいと止まる', () {
    const steep = KineticFrictionInclineParams(v0: 2, mu: 0.20, muS: 0.35, thetaDeg: 30);
    expect(kineticFrictionInclineAccel(steep), greaterThan(0));
    expect(kineticFrictionInclineStopTime(steep), isNull);
    final later = kineticFrictionInclineAt(steep, 1.5);
    expect(later.v, greaterThan(2));
    expect(later.stopped, isFalse);

    final balanceMu = math.tan(25 * math.pi / 180);
    final balance = KineticFrictionInclineParams(
      v0: 3,
      mu: balanceMu,
      muS: balanceMu + 0.15,
      thetaDeg: 25,
    );
    expect(kineticFrictionInclineAccel(balance).abs(), lessThan(1e-9));
    expect(kineticFrictionInclineStopTime(balance), isNull);
    final coast = kineticFrictionInclineAt(balance, 2);
    expect(coast.v, closeTo(3, 1e-8));
    expect(coast.s, closeTo(6, 1e-8));

    const held = KineticFrictionInclineParams(v0: 0, mu: 0.80, muS: 0.95, thetaDeg: 20);
    expect(kineticFrictionInclineStopTime(held), 0);
    final rest = kineticFrictionInclineAt(held, 3);
    expect(rest.s, closeTo(0, 1e-12));
    expect(rest.v, closeTo(0, 1e-12));
    expect(rest.stopped, isTrue);
  });

  test('θ を大きくすると止まりにくく、μ を大きくすると早く止まる', () {
    const mild = KineticFrictionInclineParams(v0: 4, mu: 0.50, muS: 0.65, thetaDeg: 10);
    const steeper = KineticFrictionInclineParams(v0: 4, mu: 0.50, muS: 0.65, thetaDeg: 20);
    const rougher = KineticFrictionInclineParams(v0: 4, mu: 0.80, muS: 0.95, thetaDeg: 20);
    expect(
      kineticFrictionInclineStopTime(steeper)!,
      greaterThan(kineticFrictionInclineStopTime(mild)!),
    );
    expect(
      kineticFrictionInclineStopTime(rougher)!,
      lessThan(kineticFrictionInclineStopTime(steeper)!),
    );
  });

  test('止まるときは力学的エネルギーと熱の和が保存される', () {
    const params = KineticFrictionInclineParams(v0: 4, mu: 0.40, muS: 0.55, thetaDeg: 15);
    final t = kineticFrictionInclineStopTime(params)!;
    final start = kineticFrictionInclineEnergy(params, kineticFrictionInclineAt(params, 0));
    final mid = kineticFrictionInclineEnergy(params, kineticFrictionInclineAt(params, t / 2));
    final end = kineticFrictionInclineEnergy(params, kineticFrictionInclineAt(params, t));
    expect(start.kinetic + start.potential + start.dissipated, closeTo(start.scale, 1e-9));
    expect(mid.kinetic + mid.potential + mid.dissipated, closeTo(start.scale, 1e-6));
    expect(end.kinetic, closeTo(0, 1e-8));
    expect(end.potential, closeTo(0, 1e-8));
    expect(end.dissipated, closeTo(start.scale, 1e-6));
    expect(end.legendPotential, isTrue);
  });

  test('初速 0 で μs が tanθ 以上なら滑らず、足りなければ滑り出す', () {
    const held = KineticFrictionInclineParams(v0: 0, mu: 0.20, muS: 0.70, thetaDeg: 30);
    expect(kineticFrictionInclineHolds(held), isTrue);
    expect(kineticFrictionInclineAccel(held), greaterThan(0));
    expect(kineticFrictionInclineStopTime(held), 0);
    final rest = kineticFrictionInclineAt(held, 2);
    expect(rest.s, closeTo(0, 1e-12));
    expect(rest.v, closeTo(0, 1e-12));
    expect(rest.a, closeTo(0, 1e-12));
    expect(rest.stopped, isTrue);

    const slips = KineticFrictionInclineParams(v0: 0, mu: 0.20, muS: 0.35, thetaDeg: 30);
    expect(kineticFrictionInclineHolds(slips), isFalse);
    expect(kineticFrictionInclineStopTime(slips), isNull);
    final later = kineticFrictionInclineAt(slips, 1);
    expect(later.v, greaterThan(0));
    expect(later.s, greaterThan(0));
    expect(later.stopped, isFalse);
  });

  test('静止摩擦係数は動摩擦係数より 0.15 以上大きい', () {
    final raised = KineticFrictionInclineParams.fromMap({
      'v0': 4,
      'mu': 0.80,
      'muS': 0.85,
      'theta': 15,
    });
    expect(raised.muS, closeTo(0.95, 1e-12));

    final lowered = KineticFrictionInclineParams.fromMap({
      'v0': 4,
      'mu': 0.70,
      'muS': 0.50,
      'theta': 15,
    });
    expect(lowered.muS, closeTo(0.85, 1e-12));
    expect(lowered.muS, greaterThanOrEqualTo(lowered.mu + 0.15 - 1e-12));
  });

  test('摩擦係数を上げると斜面の塗りが薄くなる', () {
    final pale = inclineFrictionSlopeColor(0.9, 1.05);
    final dark = inclineFrictionSlopeColor(0.1, 0.25);
    expect(pale.computeLuminance(), greaterThan(dark.computeLuminance()));
  });

  test('力学の摩擦に斜面上の動摩擦力がある', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final friction = dynamics.subcategories.firstWhere((s) => s.name == '摩擦');
    expect(friction.videos, contains(kineticFrictionIncline1D));
    expect(friction.videos, contains(kineticFriction1D));
  });
}
