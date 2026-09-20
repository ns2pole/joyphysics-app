import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/keplerLaws2D.dart';

void main() {
  const a = 1.0;
  const e = 0.5;

  test('ケプラー方程式の残差が小さい', () {
    const mean = 1.2;
    final u = solveKeplerEccentricAnomaly(mean, e);
    expect(u - e * math.sin(u), closeTo(mean, 1e-12));
  });

  test('t=0 は近点', () {
    final s = evolveKeplerEllipse(a: a, e: e, phase: 0);
    expect(s.x, closeTo(keplerPeriapsisRadius(a, e), 1e-12));
    expect(s.y, closeTo(0, 1e-12));
    expect(s.vx.abs(), lessThan(1e-9));
    expect(s.vy, closeTo(keplerPeriapsisSpeed(a, e), 1e-9));
  });

  test('1周期後に同じ位置に戻る', () {
    final s0 = evolveKeplerEllipse(a: a, e: e, phase: 0);
    final s1 = evolveKeplerEllipse(a: a, e: e, phase: 1);
    expect(s1.x, closeTo(s0.x, 1e-9));
    expect(s1.y, closeTo(s0.y, 1e-9));
  });

  test('半周期は遠点', () {
    final s = evolveKeplerEllipse(a: a, e: e, phase: 0.5);
    expect(s.x, closeTo(-keplerApoapsisRadius(a, e), 1e-9));
    expect(s.y.abs(), lessThan(1e-8));
  });

  test('面積速度は一定', () {
    final s1 = keplerSweptAreaFromPeriapsis(a, e, 0.1);
    final s2 = keplerSweptAreaFromPeriapsis(a, e, 0.2);
    final s3 = keplerSweptAreaFromPeriapsis(a, e, 0.3);
    expect(s2 - s1, closeTo(s3 - s2, 1e-12));
    final h = keplerSpecificAngularMomentum(a, e);
    expect(s1, closeTo(0.5 * h * 0.1 * keplerPeriod(a), 1e-12));
  });

  test('T²/a³ は 4π²', () {
    for (final aa in [0.5, 1.0, 1.7]) {
      final t = keplerPeriod(aa);
      expect(t * t / (aa * aa * aa), closeTo(4 * math.pi * math.pi, 1e-12));
    }
  });

  test('比較軌道は半長軸2倍で周期は2√2倍', () {
    final a2 = keplerCompareSemiMajor(a);
    expect(a2, closeTo(2 * a, 1e-12));
    expect(
      keplerPeriod(a2),
      closeTo(2 * math.sqrt(2) * keplerPeriod(a), 1e-12),
    );
    expect(kKeplerPeriodRatio, closeTo(2 * math.sqrt(2), 1e-12));
  });

  test('(a,e) と近点の (r,v) は往復する', () {
    final r = keplerPeriapsisRadius(a, e);
    final v = keplerPeriapsisSpeed(a, e);
    final aBack = keplerSemiMajorFromPeriapsis(r, v);
    final eBack = keplerEccentricityFromPeriapsis(r, aBack);
    expect(aBack, closeTo(a, 1e-12));
    expect(eBack, closeTo(e, 1e-12));
  });

  test('極方程式と位置が一致する', () {
    final s = evolveKeplerEllipse(a: a, e: e, phase: 0.17);
    final expected = a * (1 - e * e) / (1 + e * math.cos(s.theta));
    expect(s.r, closeTo(expected, 1e-9));
  });

  test('近日点の速度ベクトルは接線で遠日点より長い', () {
    final peri = evolveKeplerEllipse(a: a, e: e, phase: 0);
    final apo = evolveKeplerEllipse(a: a, e: e, phase: 0.5);
    final vp = keplerVelocityArrowOffset(peri);
    final va = keplerVelocityArrowOffset(apo);
    expect(vp.x.abs(), lessThan(1e-9));
    expect(vp.y, greaterThan(0));
    expect(va.x.abs(), lessThan(1e-8));
    expect(va.y, lessThan(0));
    final lp = math.sqrt(vp.x * vp.x + vp.y * vp.y);
    final la = math.sqrt(va.x * va.x + va.y * va.y);
    expect(lp, greaterThan(la));
  });

  test('第2法則プリセットは扁平', () {
    final next = applyKeplerLawsPreset({'a': 1.0, 'e': 0.0}, KeplerLawsPreset.second);
    expect(next['e']!, greaterThan(0.5));
    expect(next['a'], 1.0);
  });

  test('1秒スライスは等間隔で新しいものが後', () {
    final s = keplerEqualTimeSlices(2.4, keep: 16);
    expect(s.length, 3);
    expect(s[0].t0, 0);
    expect(s[0].t1, 1);
    expect(s[1].t0, 1);
    expect(s[1].t1, 2);
    expect(s[2].t0, 2);
    expect(s[2].t1, closeTo(2.4, 1e-12));
    expect(s[2].colorIndex, 2);
  });

  test('keep は古いスライスを落として上塗り順を保つ', () {
    final s = keplerEqualTimeSlices(5.2, keep: 3);
    expect(s.first.t0, 3.0);
    expect(s.last.t1, closeTo(5.2, 1e-12));
    expect(s.length, 3);
    expect(s.last.colorIndex, greaterThan(s.first.colorIndex));
  });

  test('力学のケプラーの法則カテゴリにアニメがある', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final kepler = dynamics.subcategories.firstWhere((s) => s.name == 'ケプラーの法則');
    expect(kepler.videos, contains(keplerLaws2D));
    expect(kepler.videos.first, keplerLaws2D);
    expect(keplerLaws2D.title, 'ケプラーの3法則');
    expect(keplerLaws2D.iconName, 'dynamics');
  });
}
