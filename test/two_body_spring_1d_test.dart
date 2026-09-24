import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/twoBodySpring1D.dart';

void main() {
  const ics = TwoBodySpring1DIcs(
    x1: -2.0,
    x2: 2.0,
    v1: 0.2,
    v2: 0.8,
    m1: 1.0,
    m2: 2.0,
    k: 4.0,
    ell: 4.0,
  );

  test('t=0 は初期条件に戻る', () {
    final snap = evolveTwoBodySpring1D(ics, 0);
    expect(snap.x1, closeTo(ics.x1, 1e-12));
    expect(snap.x2, closeTo(ics.x2, 1e-12));
    expect(snap.v1, closeTo(ics.v1, 1e-12));
    expect(snap.v2, closeTo(ics.v2, 1e-12));
  });

  test('1周期後に相対座標が戻る', () {
    final t = 2 * math.pi / ics.omega;
    final snap = evolveTwoBodySpring1D(ics, t);
    expect(snap.r, closeTo(ics.r0, 1e-9));
    expect(snap.rDot, closeTo(ics.rDot0, 1e-9));
  });

  test('重心は等速直線運動', () {
    const t = 1.25;
    final snap = evolveTwoBodySpring1D(ics, t);
    expect(snap.rg, closeTo(ics.rg0 + ics.vg * t, 1e-12));
  });

  test('相対運動は自然長のまわりの単振動', () {
    const t = 0.37;
    final snap = evolveTwoBodySpring1D(ics, t);
    final expected = ics.ell +
        ics.xi0 * math.cos(ics.omega * t) +
        (ics.rDot0 / ics.omega) * math.sin(ics.omega * t);
    expect(snap.r, closeTo(expected, 1e-12));
  });

  test('初期配置は原点対称の自然長で右のみ初速', () {
    final p = TwoBodySpring1DSimulation().initialParameters;
    expect(p['ell'], 4.0);
    expect(p['x1'], -2.0);
    expect(p['x2'], 2.0);
    expect(p['v1'], 0.0);
    expect(p['v2'], kTwoBodySpringOneSideSpeed);
    expect(p['m1'], p['m2']);
    final live = TwoBodySpring1DIcs.fromParams(p);
    expect(live.r0, closeTo(live.ell, 1e-12));
    expect(twoBodySpringIcsAvoidCrossing(live), isTrue);
  });

  test('振幅がℓ未満なら交差しない', () {
    expect(ics.amplitude, lessThan(ics.ell));
    expect(twoBodySpringIcsAvoidCrossing(ics), isTrue);

    const crossing = TwoBodySpring1DIcs(
      x1: -4.0,
      x2: 4.0,
      v1: 0.0,
      v2: 0.0,
      m1: 1.0,
      m2: 1.0,
      k: 4.0,
      ell: 2.0,
    );
    expect(crossing.amplitude, greaterThan(crossing.ell));
    expect(twoBodySpringIcsAvoidCrossing(crossing), isFalse);
    expect(crossing.rMin, lessThan(0));
  });

  test('伸ばしすぎは Rmin>0 の範囲に戻す', () {
    final next = applyTwoBodySpring1DParam(
      {
        'x1': -2.0,
        'x2': 2.0,
        'v1': 0.0,
        'v2': 0.0,
        'm1': 1.0,
        'm2': 1.0,
        'k': 4.0,
        'ell': 4.0,
      },
      'x2',
      8.0,
    );
    final clamped = TwoBodySpring1DIcs.fromParams(next);
    expect(twoBodySpringIcsAvoidCrossing(clamped), isTrue);
    expect(clamped.x1, closeTo(-2.0, 1e-12));
    expect(clamped.r0, lessThan(2 * clamped.ell));
    expect(clamped.rMin, greaterThan(0));
  });

  test('相対速度が大きすぎると交差しないよう制限する', () {
    final next = applyTwoBodySpring1DParam(
      {
        'x1': -2.0,
        'x2': 2.0,
        'v1': 0.0,
        'v2': 0.0,
        'm1': 1.0,
        'm2': 1.0,
        'k': 4.0,
        'ell': 4.0,
      },
      'v2',
      3.0,
    );
    final clamped = TwoBodySpring1DIcs.fromParams(next);
    expect(twoBodySpringIcsAvoidCrossing(clamped), isTrue);
    expect(clamped.amplitude, lessThan(clamped.ell));
  });

  test('ℓを変えると原点対称の自然長に戻る', () {
    final next = applyTwoBodySpring1DParam(
      {
        'x1': -1.0,
        'x2': 3.5,
        'v1': 0.4,
        'v2': -0.2,
        'm1': 1.0,
        'm2': 2.0,
        'k': 4.0,
        'ell': 4.0,
      },
      'ell',
      5.0,
    );
    expect(next['ell'], 5.0);
    expect(next['x1'], closeTo(-2.5, 1e-12));
    expect(next['x2'], closeTo(2.5, 1e-12));
    expect(twoBodySpringIcsAvoidCrossing(TwoBodySpring1DIcs.fromParams(next)), isTrue);
  });

  Map<String, double> defaults() =>
      Map<String, double>.from(TwoBodySpring1DSimulation().initialParameters);

  test('遠ざけて配置は自然長より広く速度ゼロ', () {
    final next = applyTwoBodySpring1DPreset(defaults(), TwoBodySpring1DPreset.far);
    final ics = TwoBodySpring1DIcs.fromParams(next);
    expect(ics.r0, closeTo(kTwoBodySpringFarSeparationFactor * ics.ell, 1e-12));
    expect(ics.r0, greaterThan(ics.ell));
    expect(ics.x1, closeTo(-ics.x2, 1e-12));
    expect(ics.v1, 0.0);
    expect(ics.v2, 0.0);
    expect(twoBodySpringIcsAvoidCrossing(ics), isTrue);
  });

  test('近づけて配置は自然長より狭く速度ゼロ', () {
    final next =
        applyTwoBodySpring1DPreset(defaults(), TwoBodySpring1DPreset.close);
    final ics = TwoBodySpring1DIcs.fromParams(next);
    expect(ics.r0, closeTo(kTwoBodySpringCloseSeparationFactor * ics.ell, 1e-12));
    expect(ics.r0, lessThan(ics.ell));
    expect(ics.r0, greaterThan(0));
    expect(ics.x1, closeTo(-ics.x2, 1e-12));
    expect(ics.v1, 0.0);
    expect(ics.v2, 0.0);
    expect(twoBodySpringIcsAvoidCrossing(ics), isTrue);
  });

  test('右のみ初速ありは自然長配置で v1=0', () {
    final next = applyTwoBodySpring1DPreset(
      defaults(),
      TwoBodySpring1DPreset.rightVelocity,
    );
    final ics = TwoBodySpring1DIcs.fromParams(next);
    expect(ics.r0, closeTo(ics.ell, 1e-12));
    expect(ics.x1, closeTo(-ics.ell / 2, 1e-12));
    expect(ics.x2, closeTo(ics.ell / 2, 1e-12));
    expect(ics.v1, 0.0);
    expect(ics.v2, kTwoBodySpringOneSideSpeed);
    expect(twoBodySpringIcsAvoidCrossing(ics), isTrue);
  });

  test('左のみ初速ありは自然長配置で v2=0', () {
    final next = applyTwoBodySpring1DPreset(
      defaults(),
      TwoBodySpring1DPreset.leftVelocity,
    );
    final ics = TwoBodySpring1DIcs.fromParams(next);
    expect(ics.r0, closeTo(ics.ell, 1e-12));
    expect(ics.x1, closeTo(-ics.ell / 2, 1e-12));
    expect(ics.x2, closeTo(ics.ell / 2, 1e-12));
    expect(ics.v1, kTwoBodySpringOneSideSpeed);
    expect(ics.v2, 0.0);
    expect(twoBodySpringIcsAvoidCrossing(ics), isTrue);
  });

  test('運動エネルギーは各質点の和', () {
    final snap = evolveTwoBodySpring1D(ics, 0.7);
    final ledger = twoBodySpringEnergy(ics, snap);
    expect(ledger.kineticPortions, hasLength(2));
    expect(
      ledger.kineticPortions[0].value,
      closeTo(0.5 * ics.m1 * snap.v1 * snap.v1, 1e-12),
    );
    expect(
      ledger.kineticPortions[1].value,
      closeTo(0.5 * ics.m2 * snap.v2 * snap.v2, 1e-12),
    );
    expect(
      ledger.kineticPortions[0].value + ledger.kineticPortions[1].value,
      closeTo(ledger.kinetic, 1e-12),
    );
    expect(ledger.kineticPortions[0].value, isNot(closeTo(ledger.kineticPortions[1].value, 1e-6)));
  });

  test('力学の2体問題カテゴリにばねの2体問題がある', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final twoBody = dynamics.subcategories.firstWhere((s) => s.name == '2体問題');
    expect(twoBody.videos, contains(twoBodySpring1D));
    expect(twoBodySpring1D.iconName, 'dynamics');
    final springs = dynamics.subcategories.firstWhere((s) => s.name == 'バネ');
    expect(springs.videos, isNot(contains(twoBodySpring1D)));
    final falling = dynamics.subcategories.firstWhere((s) => s.name == '落下運動');
    expect(falling.videos, isNot(contains(twoBodySpring1D)));
    final pendulum = dynamics.subcategories.firstWhere((s) => s.name == '振り子');
    expect(pendulum.videos, isNot(contains(twoBodySpring1D)));
  });
}
