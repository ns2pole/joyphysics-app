import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/dynamics/animations/bounce.dart';
import 'package:joyphysics/experiment/dynamics/animations/energy_gauge.dart';
import 'package:joyphysics/experiment/dynamics/animations/kepler_ellipse.dart';
import 'package:joyphysics/experiment/dynamics/animations/kineticFriction1D.dart';
import 'package:joyphysics/experiment/dynamics/animations/linearDrag1D.dart';
import 'package:joyphysics/experiment/dynamics/animations/movableWedge1D.dart';
import 'package:joyphysics/experiment/dynamics/animations/projectileMotion2D.dart';
import 'package:joyphysics/experiment/dynamics/animations/springOscillator1D.dart';
import 'package:joyphysics/experiment/dynamics/animations/twoBodyKepler2D.dart';
import 'package:joyphysics/experiment/dynamics/animations/twoBodySpring1D.dart';
import 'package:joyphysics/experiment/dynamics/animations/uniformCircularMotion2D.dart';
import 'package:joyphysics/experiment/dynamics/animations/verticalLoop2D.dart';
import 'package:joyphysics/experiment/dynamics/animations/verticalMotion1D.dart';

void main() {
  test('正規化は負を捨て、枠が 0 なら空、超過分は枠に収める', () {
    final dirty = const EnergyLedger(
      kinetic: -1,
      potential: double.nan,
      dissipated: 2,
      scale: 4,
    ).normalize();
    expect(dirty.kinetic, 0);
    expect(dirty.potential, 0);
    expect(dirty.dissipated, 2);
    expect(dirty.scale, 4);

    final empty = const EnergyLedger(
      kinetic: 3,
      potential: 1,
      dissipated: 0,
      scale: 0,
    ).normalize();
    expect(empty.kinetic, 0);
    expect(empty.scale, 0);

    final clipped = const EnergyLedger(
      kinetic: 6,
      potential: 6,
      dissipated: 0,
      scale: 6,
    ).normalize();
    expect(clipped.kinetic + clipped.potential, closeTo(6, 1e-9));
    expect(clipped.kinetic, closeTo(clipped.potential, 1e-9));
  });

  test('ばねは運動と位置が入れ替わっても合計は初期のまま', () {
    const params = HorizontalSpringParams(m: 0.2, k: 16, v0: 0);
    final start = horizontalSpringEnergy(params, horizontalSpringAt(params, 0));
    final quarter = horizontalSpringEnergy(
      params,
      horizontalSpringAt(params, params.period / 4),
    );
    expect(start.potentialLabel, kLabelElastic);
    expect(start.potential, greaterThan(start.kinetic));
    expect(quarter.kinetic, greaterThan(quarter.potential));
    expect(
      start.kinetic + start.potential,
      closeTo(start.scale, 1e-9),
    );
    expect(
      quarter.kinetic + quarter.potential,
      closeTo(start.scale, 1e-9),
    );

    const vertical = VerticalSpringParams(m: 0.2, k: 16, g: 9.8, v0: 0.4);
    final v0 = verticalSpringEnergy(vertical, verticalSpringAt(vertical, 0));
    final v1 = verticalSpringEnergy(
      vertical,
      verticalSpringAt(vertical, vertical.period / 3),
    );
    expect(v0.kinetic + v0.potential, closeTo(v0.scale, 1e-9));
    expect(v1.kinetic + v1.potential, closeTo(v0.scale, 1e-9));
  });

  test('2体ばねの合計は初期エネルギーのまま', () {
    const ics = TwoBodySpring1DIcs(
      x1: 0,
      x2: 1.5,
      v1: 0,
      v2: 0.4,
      m1: 1,
      m2: 1,
      k: 4,
      ell: 1,
    );
    final start = twoBodySpringEnergy(ics, evolveTwoBodySpring1D(ics, 0));
    final later = twoBodySpringEnergy(ics, evolveTwoBodySpring1D(ics, 0.7));
    expect(start.kinetic + start.potential, closeTo(start.scale, 1e-9));
    expect(later.kinetic + later.potential, closeTo(start.scale, 1e-6));
    expect(later.kineticPortions, hasLength(2));
    expect(
      later.kineticPortions[0].value + later.kineticPortions[1].value,
      closeTo(later.kinetic, 1e-9),
    );
    final snap = evolveTwoBodySpring1D(ics, 0.7);
    expect(
      later.kineticPortions[0].value,
      closeTo(0.5 * ics.m1 * snap.v1 * snap.v1, 1e-9),
    );
    expect(
      later.kineticPortions[1].value,
      closeTo(0.5 * ics.m2 * snap.v2 * snap.v2, 1e-9),
    );
  });

  test('放物と鉛直投げは着地まで保存する', () {
    const projectile = ProjectileParams(v0: 12, deg: 45, h: 6, g: 9.8);
    final duration = projectileFlightDuration(projectile);
    final atStart = projectileEnergy(projectile, projectileAt(projectile, 0));
    final mid = projectileEnergy(projectile, projectileAt(projectile, duration / 2));
    expect(atStart.kinetic + atStart.potential, closeTo(atStart.scale, 1e-9));
    expect(mid.kinetic + mid.potential, closeTo(atStart.scale, 1e-6));

    const params = VerticalMotionParams(h: 3, v0: 8);
    final up0 = verticalMotionEnergy(
      VerticalMotionKind.throwUp,
      params,
      verticalMotionAt(VerticalMotionKind.throwUp, params, 0),
    );
    final up1 = verticalMotionEnergy(
      VerticalMotionKind.throwUp,
      params,
      verticalMotionAt(VerticalMotionKind.throwUp, params, 0.3),
    );
    expect(up0.kinetic + up0.potential, closeTo(up0.scale, 1e-9));
    expect(up1.kinetic + up1.potential, closeTo(up0.scale, 1e-6));
  });

  test('摩擦は止まったとき運動エネルギーが 0 で熱が枠を満たす', () {
    const params = KineticFrictionParams(v0: 4, mu: 0.2);
    final stop = kineticFrictionStopTime(params)!;
    final moving = kineticFrictionEnergy(params, kineticFrictionAt(params, stop / 2));
    final stopped = kineticFrictionEnergy(params, kineticFrictionAt(params, stop));
    expect(moving.kinetic, greaterThan(0));
    expect(moving.dissipated, greaterThan(0));
    expect(moving.kinetic + moving.dissipated, closeTo(moving.scale, 1e-9));
    expect(stopped.kinetic, closeTo(0, 1e-9));
    expect(stopped.dissipated, closeTo(stopped.scale, 1e-9));
    expect(stopped.legendHeat, isTrue);
    expect(stopped.legendPotential, isFalse);

    const coast = KineticFrictionParams(v0: 4, mu: 0);
    final coasting = kineticFrictionEnergy(coast, kineticFrictionAt(coast, 3));
    expect(coasting.kinetic, closeTo(coasting.scale, 1e-9));
    expect(coasting.dissipated, closeTo(0, 1e-9));
  });

  test('跳ね返りは衝突の直後に熱が増え、e=1 では増えない', () {
    final legs = bounce1DLegs(Bounce1DKind.freeFall, 3, 8, 0.8);
    final initial = bounceMechanical(3, 0, 0);
    final impact = legs.first.t1;
    final before = bounceAt(legs, impact - 1e-4);
    final after = bounceAt(legs, impact + 1e-4);
    final heatBefore = bounceEnergy(
      y: before.y,
      vx: before.vx,
      vy: before.vy,
      initial: initial,
    ).dissipated;
    final heatAfter = bounceEnergy(
      y: after.y,
      vx: after.vx,
      vy: after.vy,
      initial: initial,
    ).dissipated;
    expect(heatBefore, closeTo(0, 1e-3));
    expect(heatAfter, greaterThan(heatBefore + 1));

    final elastic = bounce2DLegs(45, 12, 1, h: 2);
    final e0 = bounceMechanical(elastic.first.y0, elastic.first.vx, elastic.first.vy0);
    final later = bounceAt(elastic, elastic.first.t1 + 0.05);
    final ledger = bounceEnergy(
      y: later.y,
      vx: later.vx,
      vy: later.vy,
      initial: e0,
    );
    expect(ledger.dissipated, closeTo(0, 1e-6));
    expect(ledger.kinetic, greaterThan(0));
  });

  test('空気抵抗は減った力学的エネルギーが熱になる', () {
    const params = LinearDragParams(h: 15, v0: 8, vt: 5);
    final start = linearDragEnergy(
      LinearDragKind.drop,
      params,
      linearDragAt(LinearDragKind.drop, params, 0),
    );
    final later = linearDragEnergy(
      LinearDragKind.drop,
      params,
      linearDragAt(LinearDragKind.drop, params, 0.5),
    );
    expect(start.dissipated, closeTo(0, 1e-6));
    expect(later.dissipated, greaterThan(0.1));
    expect(
      later.kinetic + later.potential + later.dissipated,
      closeTo(start.scale, 1e-6),
    );
    expect(later.legendHeat, isTrue);
    expect(later.potentialLabel, kLabelGravity);
  });

  test('動く斜面は滑り切っても力学的エネルギーが保存する', () {
    const params = MovableWedgeParams(
      thetaDeg: 30,
      cartMass: 2,
      blockMass: 1,
      length: 1.5,
    );
    final start = movableWedgeEnergy(params, movableWedgeAt(params, 0));
    final end = movableWedgeEnergy(
      params,
      movableWedgeAt(params, wedgeSlideDuration(params)),
    );
    expect(start.kinetic, closeTo(0, 1e-9));
    expect(start.potential, closeTo(start.scale, 1e-9));
    expect(end.potential, closeTo(0, 1e-6));
    expect(end.kinetic, closeTo(start.scale, 1e-6));
    expect(end.kineticPortions, hasLength(2));
    expect(
      end.kineticPortions[0].value + end.kineticPortions[1].value,
      closeTo(end.kinetic, 1e-9),
    );
  });

  test('鉛直ループは斜面を下るあいだ保存する', () {
    final sim = LoopSim(heightRatio: 1.75);
    final start = verticalLoopEnergy(sim.h, sim.snapshot());
    expect(start.kinetic, closeTo(0, 1e-9));
    expect(start.potential, closeTo(start.scale, 1e-9));
    for (var i = 0; i < 3000; i++) {
      sim.step(sim.dt);
    }
    final mid = verticalLoopEnergy(sim.h, sim.snapshot());
    expect(mid.kinetic, greaterThan(0));
    expect(mid.dissipated, closeTo(0, 1e-2));
    expect(mid.kinetic + mid.potential, closeTo(start.scale, 1e-2));
  });

  test('等速円運動のゲージは運動エネルギーだけで動かない', () {
    const params = CircularParams(r: 1, v: 2);
    final ledger = circularEnergy(params);
    expect(ledger.kinetic, closeTo(0.5 * kCircularMass * 4, 1e-12));
    expect(ledger.potential, 0);
    expect(ledger.scale, ledger.kinetic);
    expect(ledger.legendPotential, isFalse);
  });

  test('楕円軌道は近日点と遠日点で K+U が同じ', () {
    const a = 1.2;
    const e = 0.6;
    final peri = keplerMechanicalLedger(
      evolveKeplerEllipse(a: a, e: e, phase: 0),
    );
    final apo = keplerMechanicalLedger(
      evolveKeplerEllipse(a: a, e: e, phase: 0.5),
    );
    expect(peri.potentialLabel, kLabelGravitation);
    expect(peri.potential, closeTo(0, 1e-9));
    expect(peri.kinetic, closeTo(peri.scale, 1e-9));
    expect(apo.potential, greaterThan(apo.kinetic));
    expect(peri.kinetic + peri.potential, closeTo(peri.scale, 1e-8));
    expect(apo.kinetic + apo.potential, closeTo(peri.scale, 1e-8));
  });

  test('2体ケプラーも近日点と遠日点で合計が同じ', () {
    final peri = twoBodyKeplerEnergy(
      evolveTwoBodyKepler(a1: 0.4, a2: 0.6, e: 0.5, phase: 0),
    );
    final apo = twoBodyKeplerEnergy(
      evolveTwoBodyKepler(a1: 0.4, a2: 0.6, e: 0.5, phase: 0.5),
    );
    expect(peri.kinetic + peri.potential, closeTo(peri.scale, 1e-8));
    expect(apo.kinetic + apo.potential, closeTo(peri.scale, 1e-8));
    expect(apo.potential, greaterThan(peri.potential));
    expect(peri.kineticPortions, hasLength(2));
    expect(
      peri.kineticPortions[0].value + peri.kineticPortions[1].value,
      closeTo(peri.kinetic, 1e-9),
    );
    final sunEarth = twoBodyKeplerEnergy(
      evolveTwoBodyKepler(a1: 1 / 301, a2: 300 / 301, e: 0, phase: 0),
    );
    expect(
      sunEarth.kineticPortions[1].value,
      greaterThan(sunEarth.kineticPortions[0].value),
    );
  });
}
