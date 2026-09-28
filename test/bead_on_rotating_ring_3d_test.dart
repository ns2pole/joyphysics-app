import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/beadOnRotatingRing3D.dart';

void main() {
  test('つり合い条件: ω² > g/R で cosθ = g/(ω²R)', () {
    const p = RingBeadParams(
      r: 0.8,
      omega: 5,
      mass: 1,
      theta0: 0.4,
      thetaDot0: 0,
    );
    expect(p.equilibriumCos, closeTo(kRingG / (25 * 0.8), 1e-12));
    expect(p.equilibriumTheta, closeTo(math.acos(kRingG / 20), 1e-12));
    expect(ringBeadAccel(p, p.equilibriumTheta!), closeTo(0, 1e-10));
  });

  test('ω が小さいと斜めつり合いはなく、底で加速度 0', () {
    const p = RingBeadParams(
      r: 1,
      omega: 1,
      mass: 1,
      theta0: 0.2,
      thetaDot0: 0,
    );
    expect(p.equilibriumTheta, isNull);
    expect(ringBeadAccel(p, 0), closeTo(0, 1e-12));
    expect(ringBeadAccel(p, 0.3) < 0, isTrue);
  });

  test('回転系の接線力の和が mR θ̈ と一致する', () {
    const p = RingBeadParams(
      r: 0.8,
      omega: 4.2,
      mass: 1.5,
      theta0: 0.7,
      thetaDot0: 0,
    );
    final phase = RingBeadPhase(t: 0, theta: 0.7, thetaDot: -0.5);
    final s = ringBeadSampleAt(p, phase);
    expect(
      s.forceTangential,
      closeTo(p.mass * p.r * s.thetaDDot, 1e-9),
    );
  });

  test('積分してもビーズは円環上に留まる', () {
    const p = RingBeadParams(
      r: 0.8,
      omega: 4.5,
      mass: 1,
      theta0: 0.5,
      thetaDot0: 1.2,
    );
    final phase = ringBeadIntegrate(p, 2.5);
    final s = ringBeadSampleAt(p, phase);
    expect(
      s.x * s.x + s.y * s.y + s.z * s.z,
      closeTo(p.r * p.r, 1e-6),
    );
    expect(s.yRot, closeTo(0, 1e-12));
  });

  test('力学の慣性力に回転する円環上のビーズがある', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final sections = dynamics.subcategories.where((s) => s.name == '慣性力');
    expect(sections.length, 1);
    expect(sections.single.videos, contains(beadOnRotatingRing3D));
    expect(beadOnRotatingRing3D.title, '回転する円環上のビーズ');
  });
}
