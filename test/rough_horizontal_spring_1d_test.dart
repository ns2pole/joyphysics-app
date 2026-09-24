import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/roughHorizontalSpring1D.dart';
import 'package:joyphysics/experiment/dynamics/animations/springOscillator1D.dart';

void main() {
  const released = RoughHorizontalSpringParams(
    m: kSpringDefaultM,
    k: kSpringDefaultK,
    muK: kRoughSpringDefaultMuK,
    muS: kRoughSpringDefaultMuS,
    x0: kHorizontalSpringDefaultX0,
    v0: 0,
  );

  test('バネの単元に粗い床の水平バネがある', () {
    final springs = categoriesData
        .firstWhere((c) => c.name == '力学')
        .subcategories
        .firstWhere((s) => s.name == 'バネ');
    expect(springs.videos.map((v) => v.title), contains('水平バネ（粗い床）'));
    expect(roughHorizontalSpring1D.isSimulation, isTrue);
  });

  test('摩擦なしはなめらかな水平バネと一致する', () {
    const smooth = RoughHorizontalSpringParams(
      m: kSpringDefaultM,
      k: kSpringDefaultK,
      muK: 0,
      muS: 0,
      x0: kHorizontalSpringDefaultX0,
      v0: 0.4,
    );
    const plain = HorizontalSpringParams(
      m: kSpringDefaultM,
      k: kSpringDefaultK,
      x0: kHorizontalSpringDefaultX0,
      v0: 0.4,
    );
    for (var i = 0; i <= 8; i++) {
      final t = plain.period * i / 8;
      final rough = roughHorizontalSpringAt(smooth, t);
      final ideal = horizontalSpringAt(plain, t);
      expect(rough.stuck, isFalse);
      expect(rough.x, closeTo(ideal.xi, 1e-9));
      expect(rough.v, closeTo(ideal.v, 1e-9));
    }
  });

  test('静止摩擦の範囲内で静かに置くと動かない', () {
    expect(released.deltaS, greaterThan(0.02));
    final held = RoughHorizontalSpringParams(
      m: released.m,
      k: released.k,
      muK: released.muK,
      muS: released.muS,
      x0: released.deltaS * 0.5,
      v0: 0,
    );
    final later = roughHorizontalSpringAt(held, 3);
    expect(later.stuck, isTrue);
    expect(later.x, closeTo(held.x0, 1e-12));
    expect(later.v, closeTo(0, 1e-12));
    expect(later.a, closeTo(0, 1e-12));
    expect(later.friction, closeTo(held.k * held.x0, 1e-9));
    final energy = roughHorizontalSpringEnergy(held, later);
    expect(energy.dissipated, closeTo(0, 1e-9));
    expect(energy.kinetic, closeTo(0, 1e-12));
  });

  test('半周期ごとに振れ幅は 2δ′ 減り、静止範囲に入ると止まる', () {
    final dk = released.deltaK;
    final ds = released.deltaS;
    expect(dk, closeTo(0.15 * 0.2 * 9.8 / 16, 1e-12));
    expect(ds, closeTo(2 * dk, 1e-12));
    final half = math.pi / released.omega;

    final start = roughHorizontalSpringAt(released, 0);
    expect(start.x, closeTo(0.10, 1e-12));
    expect(start.v, closeTo(0, 1e-12));
    expect(start.stuck, isFalse);
    expect(start.a, closeTo((-released.k * 0.10 + released.kineticFriction) / released.m, 1e-9));

    final first = roughHorizontalSpringAt(released, half);
    expect(first.stuck, isFalse);
    expect(first.v, closeTo(0, 1e-8));
    expect(first.x, closeTo(-(0.10 - 2 * dk), 1e-8));
    expect(first.x.abs(), greaterThan(ds));

    final second = roughHorizontalSpringAt(released, 2 * half);
    expect(second.stuck, isTrue);
    expect(second.v, closeTo(0, 1e-9));
    expect(second.x, closeTo(0.10 - 4 * dk, 1e-8));
    expect(second.x.abs(), lessThan(ds));

    final later = roughHorizontalSpringAt(released, 2 * half + 2);
    expect(later.x, closeTo(second.x, 1e-12));
    expect(later.stuck, isTrue);
    expect(later.a, closeTo(0, 1e-12));
  });

  test('既定の初期位置では3往復して静止摩擦で止まる', () {
    const demo = RoughHorizontalSpringParams(
      m: kSpringDefaultM,
      k: kSpringDefaultK,
      muK: kRoughSpringDefaultMuK,
      muS: kRoughSpringDefaultMuS,
    );
    expect(demo.x0, closeTo(kRoughSpringDefaultX0, 1e-12));
    expect(demo.v0, closeTo(0, 1e-12));
    final half = math.pi / demo.omega;
    for (var n = 1; n <= 5; n++) {
      final turning = roughHorizontalSpringAt(demo, n * half);
      expect(turning.stuck, isFalse, reason: 'half-period $n');
      expect(turning.v.abs(), lessThan(1e-6));
      expect(turning.x.abs(), greaterThan(demo.deltaS));
    }
    final stopped = roughHorizontalSpringAt(demo, 6 * half);
    expect(stopped.stuck, isTrue);
    expect(stopped.v, closeTo(0, 1e-9));
    expect(stopped.x.abs(), lessThanOrEqualTo(demo.deltaS + 1e-8));
    expect(stopped.x, greaterThan(0));
    final held = roughHorizontalSpringAt(demo, 6 * half + 1);
    expect(held.x, closeTo(stopped.x, 1e-12));
    expect(held.a, closeTo(0, 1e-12));
  });

  test('止まったときの熱は減った弾性エネルギー', () {
    final half = math.pi / released.omega;
    final stopped = roughHorizontalSpringAt(released, 2 * half + 0.2);
    final ledger = roughHorizontalSpringEnergy(released, stopped);
    final initial = 0.5 * released.k * released.x0 * released.x0;
    final left = 0.5 * released.k * stopped.x * stopped.x;
    expect(ledger.kinetic, closeTo(0, 1e-9));
    expect(ledger.potential, closeTo(left, 1e-8));
    expect(ledger.dissipated, closeTo(initial - left, 1e-8));
    expect(ledger.scale, closeTo(initial, 1e-12));
    expect(ledger.dissipated, greaterThan(ledger.potential));
  });

  test('静止摩擦係数は動摩擦係数を下回らない', () {
    final params = RoughHorizontalSpringParams.fromMap({
      'm': 0.2,
      'k': 16,
      'muK': 0.40,
      'muS': 0.10,
      'x0': 0.10,
      'v0': 0,
    });
    expect(params.muS, closeTo(0.40, 1e-12));
    expect(params.muK, closeTo(0.40, 1e-12));
  });

  test('初速を与えてもエネルギーは熱を含めて保存する', () {
    const pushed = RoughHorizontalSpringParams(
      m: kSpringDefaultM,
      k: kSpringDefaultK,
      muK: 0.10,
      muS: 0.25,
      x0: 0.05,
      v0: 0.80,
    );
    final e0 = 0.5 * pushed.m * pushed.v0 * pushed.v0 +
        0.5 * pushed.k * pushed.x0 * pushed.x0;
    for (var i = 0; i <= 12; i++) {
      final s = roughHorizontalSpringAt(pushed, pushed.omega == 0 ? 0 : i * 0.05);
      final ledger = roughHorizontalSpringEnergy(pushed, s);
      expect(
        ledger.kinetic + ledger.potential + ledger.dissipated,
        closeTo(e0, 1e-8),
      );
      expect(s.x.abs(), lessThanOrEqualTo(0.20));
    }
    final late = roughHorizontalSpringAt(pushed, 8);
    expect(late.stuck, isTrue);
    expect(late.x.abs(), lessThanOrEqualTo(pushed.deltaS + 1e-8));
  });
}
