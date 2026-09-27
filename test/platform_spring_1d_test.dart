import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/platformSpring1D.dart';

void main() {
  const stuck = PlatformSpringParams(
    bigM: 0.50,
    m: 0.20,
    k: 40,
    g: 9.8,
    y0: 0.25,
  );

  const flies = PlatformSpringParams(
    bigM: 0.50,
    m: 0.20,
    k: 40,
    g: 9.8,
    y0: 0.40,
  );

  const bouncy = PlatformSpringParams(
    bigM: 0.50,
    m: 0.20,
    k: 40,
    g: 9.8,
    y0: 0.40,
    e: 0.80,
  );

  test('つりあいと周期は M+m と k で決まる', () {
    expect(stuck.delta, closeTo(0.70 * 9.8 / 40, 1e-12));
    expect(stuck.period, closeTo(2 * math.pi * math.sqrt(0.70 / 40), 1e-12));
    expect(stuck.willSeparate, isFalse);
    expect(flies.willSeparate, isTrue);
    expect(flies.y0, greaterThanOrEqualTo(2 * flies.delta));
  });

  test('2δ 未満なら一体の単振動で、T/2 で反対側の端', () {
    final period = stuck.period;
    final start = platformSpringAt(stuck, 0);
    expect(start.contact, isTrue);
    expect(start.yPlatform, closeTo(stuck.y0, 1e-12));
    expect(start.vPlatform, closeTo(0, 1e-12));
    expect(start.normal, closeTo(stuck.m * stuck.k * stuck.y0 / stuck.totalMass, 1e-9));

    final half = platformSpringAt(stuck, period / 2);
    expect(half.contact, isTrue);
    expect(half.yPlatform, closeTo(2 * stuck.delta - stuck.y0, 1e-9));
    expect(half.vPlatform, closeTo(0, 1e-9));
    expect(half.yPlatform, greaterThan(0));

    final back = platformSpringAt(stuck, period);
    expect(back.yPlatform, closeTo(stuck.y0, 1e-8));
    expect(back.contact, isTrue);
  });

  test('2δ 以上なら自然長でおもりが離れる', () {
    expect(flies.willSeparate, isTrue);
    var left = false;
    var sawNegativeMass = false;
    for (var i = 0; i <= 400; i++) {
      final s = platformSpringAt(flies, i * 0.005);
      if (!s.contact) {
        left = true;
        if (s.yMass < s.yPlatform - 1e-4) sawNegativeMass = true;
      }
    }
    expect(left, isTrue);
    expect(sawNegativeMass, isTrue);

    // 分離時刻付近で y≈0
    final period = flies.period;
    var sepY = 1.0;
    for (var i = 0; i <= 200; i++) {
      final s = platformSpringAt(flies, period * i / 200);
      if (!s.contact) {
        sepY = s.yPlatform.abs();
        break;
      }
    }
    expect(sepY, lessThan(0.02));
  });

  test('接触中の N は m k y / (M+m)', () {
    for (var i = 0; i <= 16; i++) {
      final s = platformSpringAt(stuck, stuck.period * i / 16);
      expect(s.contact, isTrue);
      final expected = stuck.m * stuck.k * s.yPlatform / stuck.totalMass;
      expect(s.normal, closeTo(expected, 1e-8));
    }
  });

  test('衝突の反発係数 e で相対速度が決まる', () {
    final hit = platformSpringImpact(
      bigM: 0.5,
      m: 0.2,
      e: 0.8,
      vPlatform: -0.5,
      vMass: 1.5,
    );
    final uRel = 1.5 - (-0.5);
    expect(hit.vMass - hit.vPlatform, closeTo(-0.8 * uRel, 1e-12));
    expect(
      0.5 * hit.vPlatform + 0.2 * hit.vMass,
      closeTo(0.5 * (-0.5) + 0.2 * 1.5, 1e-12),
    );

    final stick = platformSpringImpact(
      bigM: 0.5,
      m: 0.2,
      e: 0.0,
      vPlatform: -0.5,
      vMass: 1.5,
    );
    expect(stick.vPlatform, closeTo(stick.vMass, 1e-12));
  });

  test('e>0 なら再接触後に弾んで離れる', () {
    var sawLeave = false;
    var sawBounceApart = false;
    var wasContact = true;
    for (var i = 0; i <= 800; i++) {
      final s = platformSpringAt(bouncy, i * 0.01);
      if (!s.contact) sawLeave = true;
      // 一度離れたあと再接触し、また離れて相対速度が上向き（おもりが上）
      if (wasContact && !s.contact && s.t > 0.15) {
        if (s.vMass < s.vPlatform - 1e-3) {
          sawBounceApart = true;
        }
      }
      wasContact = s.contact;
    }
    expect(sawLeave, isTrue);
    expect(sawBounceApart, isTrue);
  });

  test('単振動カテゴリに登録されている', () {
    final shm = categoriesData
        .firstWhere((c) => c.name == '力学')
        .subcategories
        .firstWhere((s) => s.name == '単振動');
    expect(shm.videos, contains(platformSpring1D));
  });
}
