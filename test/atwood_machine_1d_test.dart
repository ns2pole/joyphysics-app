import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/atwoodMachine1D.dart';

void main() {
  test('g は 9.8 m/s²', () {
    expect(kAtwoodG, 9.8);
  });

  test('m1=2 kg、m2=1 kg では左が下り、加速度と張力は公式どおり', () {
    const params = AtwoodParams(m1: 2, m2: 1, h: 1.2);
    final a = (2 - 1) * 9.8 / 3;
    final tension = 2 * 2 * 1 * 9.8 / 3;
    expect(params.acceleration, closeTo(a, 1e-12));
    expect(params.tension, closeTo(tension, 1e-12));
    expect(a, inInclusiveRange(3, 3.4));

    final t = atwoodHitTime(params)!;
    expect(t, closeTo(math.sqrt(2 * 1.2 / a), 1e-12));
    expect(atwoodHitSpeed(params), closeTo(math.sqrt(2 * a * 1.2), 1e-12));

    final start = atwoodAt(params, 0);
    expect(start.s, closeTo(0, 1e-12));
    expect(start.v, closeTo(0, 1e-12));
    expect(start.a, closeTo(a, 1e-12));
    expect(start.tension, closeTo(tension, 1e-12));
    expect(start.stopped, isFalse);

    final mid = atwoodAt(params, t / 2);
    expect(mid.s, closeTo(0.5 * a * (t / 2) * (t / 2), 1e-9));
    expect(mid.v, closeTo(a * t / 2, 1e-9));
    expect(mid.s, closeTo(1.2 / 4, 1e-9));
  });

  test('床に着いたあとはそこで止まり、張力は 0', () {
    const params = AtwoodParams(m1: 2, m2: 1, h: 1.2);
    final t = atwoodHitTime(params)!;
    final landed = atwoodAt(params, t);
    expect(landed.s, closeTo(1.2, 1e-9));
    expect(landed.v, closeTo(0, 1e-12));
    expect(landed.stopped, isTrue);
    expect(landed.tension, closeTo(0, 1e-12));

    final later = atwoodAt(params, t + 4);
    expect(later.s, closeTo(landed.s, 1e-12));
    expect(later.t, closeTo(t, 1e-12));
    expect(later.stopped, isTrue);
  });

  test('右が重いと左の変位は負で、右が床に着く', () {
    const params = AtwoodParams(m1: 1, m2: 3, h: 0.8);
    expect(params.acceleration, lessThan(0));
    final t = atwoodHitTime(params)!;
    final landed = atwoodAt(params, t);
    expect(landed.s, closeTo(-0.8, 1e-9));
    expect(landed.stopped, isTrue);
    final mid = atwoodAt(params, t / 2);
    expect(mid.s, closeTo(-0.2, 1e-9));
    expect(mid.v, lessThan(0));
  });

  test('質量が等しいと加速度は 0 で、張力は重量に等しい', () {
    const params = AtwoodParams(m1: 1.5, m2: 1.5, h: 1);
    expect(atwoodHitTime(params), isNull);
    expect(atwoodHitSpeed(params), isNull);
    expect(params.acceleration, closeTo(0, 1e-12));
    expect(params.tension, closeTo(1.5 * 9.8, 1e-12));
    final later = atwoodAt(params, 3);
    expect(later.s, closeTo(0, 1e-12));
    expect(later.v, closeTo(0, 1e-12));
    expect(later.stopped, isFalse);
  });

  test('運動中は力学的エネルギーが保存され、着地で運動エネルギーが熱になる', () {
    const params = AtwoodParams(m1: 2, m2: 1, h: 1.2);
    final scale = 3 * 9.8 * 1.2;
    final t = atwoodHitTime(params)!;
    for (var i = 0; i < 6; i++) {
      final sample = atwoodAt(params, t * i / 6);
      final ledger = atwoodEnergy(params, sample);
      expect(
        ledger.kinetic + ledger.potential + ledger.dissipated,
        closeTo(scale, 1e-8),
      );
      expect(ledger.dissipated, closeTo(0, 1e-12));
    }
    final landed = atwoodEnergy(params, atwoodAt(params, t));
    expect(landed.kinetic, closeTo(0, 1e-12));
    expect(landed.dissipated, greaterThan(1));
    expect(
      landed.potential + landed.dissipated,
      closeTo(scale, 1e-8),
    );
  });

  test('点の間隔はあとほど広い', () {
    const params = AtwoodParams(m1: 2, m2: 1, h: 1.2);
    final strobes = atwoodStrobe(params, atwoodHitTime(params)!);
    expect(strobes.length, greaterThan(3));
    final firstGap = strobes[1].s - strobes[0].s;
    final lastGap = strobes.last.s - strobes[strobes.length - 2].s;
    expect(lastGap, greaterThan(firstGap));
  });

  test('力学の滑車にアトウッドの器械がある', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final pulley = dynamics.subcategories.firstWhere((s) => s.name == '滑車');
    expect(pulley.videos, contains(atwoodMachine1D));
    expect(atwoodMachine1D.title, '定滑車(アトウッドの器械)');
  });
}
