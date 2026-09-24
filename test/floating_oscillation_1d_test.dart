import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/dynamics/animations/floatingOscillation1D.dart';

void main() {
  const woodInWater = FloatParams(rho: 1000, y0: 0.14);

  test('喫水は密度比でかけ、周期は h と g だけで決まる', () {
    expect(floatSigma(1000), closeTo(0.5, 1e-12));
    expect(woodInWater.draft, closeTo(0.10, 1e-12));
    final period = floatPeriod(1000);
    expect(period, closeTo(2 * math.pi * math.sqrt(0.10 / kFloatG), 1e-12));
    expect(period, inInclusiveRange(0.55, 0.75));

    const heavierLiquid = FloatParams(rho: 2000, y0: 0.14);
    expect(heavierLiquid.draft, closeTo(0.05, 1e-12));
    expect(
      floatPeriod(2000),
      closeTo(period / math.sqrt(2), 1e-9),
    );
  });

  test('標準の初期深さは単振動で、T/4 でつりあい、T/2 で反対側', () {
    expect(floatRegime(woodInWater), FloatRegime.harmonic);
    final period = floatPeriod(woodInWater.rho);
    final omega = floatOmega(woodInWater.rho);
    const amplitude = 0.04;

    final start = floatAt(woodInWater, 0);
    expect(start.y, closeTo(0.14, 1e-12));
    expect(start.v, closeTo(0, 1e-12));
    expect(start.a, closeTo(-omega * omega * amplitude, 1e-9));

    final quarter = floatAt(woodInWater, period / 4);
    expect(quarter.y, closeTo(0.10, 1e-9));
    expect(quarter.v, closeTo(-amplitude * omega, 1e-9));
    expect(quarter.v.abs(), inInclusiveRange(0.2, 0.6));

    final half = floatAt(woodInWater, period / 2);
    expect(half.y, closeTo(0.06, 1e-9));
    expect(half.v, closeTo(0, 1e-9));
    expect(half.inAir, isFalse);
    expect(half.fullySubmerged, isFalse);

    final back = floatAt(woodInWater, period);
    expect(back.y, closeTo(0.14, 1e-8));
    expect(back.v, closeTo(0, 1e-8));
  });

  test('軽い物体を全没から離すと水面から出る', () {
    const light = FloatParams(rho: kFloatRhoObject / 0.3, y0: kFloatObjectH);
    expect(light.sigma, closeTo(0.3, 1e-12));
    expect(light.draft, lessThan(kFloatObjectH / 2));
    expect(floatRegime(light), FloatRegime.jumps);

    var leftWater = false;
    var cameBack = false;
    for (var i = 0; i <= 400; i++) {
      final s = floatAt(light, i * 0.01);
      if (s.inAir) leftWater = true;
      if (leftWater && s.y > 0.01) cameBack = true;
    }
    expect(leftWater, isTrue);
    expect(cameBack, isTrue);
  });

  test('半分より重い浮体は、ちょうど全没からでは飛び出さない', () {
    const deepDraft = FloatParams(rho: kFloatRhoObject / 0.8, y0: kFloatObjectH);
    expect(deepDraft.draft, closeTo(0.16, 1e-12));
    expect(deepDraft.draft, greaterThan(kFloatObjectH / 2));
    expect(floatRegime(deepDraft), FloatRegime.rises);

    for (var i = 0; i <= 300; i++) {
      final s = floatAt(deepDraft, i * 0.02);
      expect(s.y, greaterThan(-1e-6));
    }
    final later = floatAt(deepDraft, 2.0);
    expect(later.y, lessThan(kFloatObjectH));
    expect(later.fullySubmerged, isFalse);
  });

  test('同じ浮体でも深く沈めて離すと飛び出す', () {
    const pushed = FloatParams(rho: kFloatRhoObject / 0.8, y0: 0.55);
    expect(floatRegime(pushed), FloatRegime.jumps);
    var minY = pushed.y0;
    for (var i = 0; i <= 400; i++) {
      final y = floatAt(pushed, i * 0.015).y;
      if (y < minY) minY = y;
    }
    expect(minY, lessThan(0));
  });

  test('液体より重い物体は水底で止まる', () {
    const sinker = FloatParams(rho: kFloatRhoObject / 1.2, y0: 0.10);
    expect(sinker.sigma, greaterThan(1));
    expect(floatRegime(sinker), FloatRegime.sinks);
    expect(floatAccel(kFloatObjectH, sinker.rho), greaterThan(0));

    final settled = floatAt(sinker, 4.0);
    expect(settled.onFloor, isTrue);
    expect(settled.y, closeTo(kFloatTank, 1e-6));
    expect(settled.v, closeTo(0, 1e-6));
  });

  test('密度が等しいと、全没で置くと止まり、浅い位置から離すと水底まで進む', () {
    const held = FloatParams(rho: kFloatRhoObject, y0: kFloatObjectH);
    expect(floatRegime(held), FloatRegime.neutral);
    expect(floatAccel(kFloatObjectH, held.rho), closeTo(0, 1e-12));
    final still = floatAt(held, 2.0);
    expect(still.y, closeTo(kFloatObjectH, 1e-6));
    expect(still.v, closeTo(0, 1e-6));

    const matched = FloatParams(rho: kFloatRhoObject, y0: 0.10);
    final omega = math.sqrt(kFloatG / kFloatObjectH);
    final arrived = floatAt(matched, 0.5 * math.pi / omega);
    expect(arrived.y, closeTo(kFloatObjectH, 1e-6));
    expect(arrived.v, closeTo(0.10 * omega, 1e-6));
    expect(arrived.v, greaterThan(0.5));

    final settled = floatAt(matched, 3.0);
    expect(settled.onFloor, isTrue);
    expect(settled.v, closeTo(0, 1e-6));
  });

  test('三つの領域の加速度が境でつながる', () {
    const rho = 1000.0;
    final h = floatDraft(rho);
    expect(floatAccel(-0.01, rho), closeTo(kFloatG, 1e-12));
    expect(floatAccel(0, rho), closeTo(kFloatG, 1e-9));
    expect(floatAccel(h, rho), closeTo(0, 1e-9));
    final full = kFloatG * (1 - rho / kFloatRhoObject);
    expect(floatAccel(kFloatObjectH, rho), closeTo(full, 1e-9));
    expect(floatAccel(kFloatObjectH + 0.1, rho), closeTo(full, 1e-9));
    expect(full, lessThan(0));
  });
}
