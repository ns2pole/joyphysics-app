import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/kepler_ellipse.dart';
import 'package:joyphysics/experiment/dynamics/animations/twoBodyKepler2D.dart';

void main() {
  test('質量比は半長軸の逆数', () {
    expect(twoBodyKeplerMass1(0.2, 0.8), closeTo(0.8, 1e-12));
    expect(twoBodyKeplerMass2(0.2, 0.8), closeTo(0.2, 1e-12));
    expect(twoBodyKeplerMass1(0.2, 0.8) / twoBodyKeplerMass2(0.2, 0.8),
        closeTo(0.8 / 0.2, 1e-12));
  });

  test('重心は原点に留まる', () {
    for (final phase in [0.0, 0.17, 0.5, 0.91]) {
      final s = evolveTwoBodyKepler(a1: 0.3, a2: 0.7, e: 0.5, phase: phase);
      expect(s.cmx, closeTo(0, 1e-12));
      expect(s.cmy, closeTo(0, 1e-12));
    }
  });

  test('相対ベクトルはケプラー楕円', () {
    const a1 = 0.3;
    const a2 = 0.7;
    const e = 0.4;
    const phase = 0.22;
    final s = evolveTwoBodyKepler(a1: a1, a2: a2, e: e, phase: phase);
    final rel = evolveKeplerEllipse(
      a: a1 + a2,
      e: e,
      phase: phase,
      gm: kTwoBodyKeplerGM,
    );
    expect(s.x2 - s.x1, closeTo(rel.x, 1e-12));
    expect(s.y2 - s.y1, closeTo(rel.y, 1e-12));
    expect(s.vx2 - s.vx1, closeTo(rel.vx, 1e-12));
    expect(s.vy2 - s.vy1, closeTo(rel.vy, 1e-12));
  });

  test('T²/a³ は 4π²/GM', () {
    const a1 = 0.25;
    const a2 = 0.55;
    final a = a1 + a2;
    final t = keplerPeriod(a, gm: kTwoBodyKeplerGM);
    expect(
      t * t / (a * a * a),
      closeTo(4 * math.pi * math.pi / kTwoBodyKeplerGM, 1e-12),
    );
  });

  test('近点では両星とも r⊥v', () {
    final s = evolveTwoBodyKepler(a1: 0.35, a2: 0.65, e: 0.55, phase: 0);
    expect(s.x1 * s.vx1 + s.y1 * s.vy1, closeTo(0, 1e-12));
    expect(s.x2 * s.vx2 + s.y2 * s.vy2, closeTo(0, 1e-12));
    expect(s.r1, closeTo(keplerPeriapsisRadius(0.35, 0.55), 1e-12));
    expect(s.r2, closeTo(keplerPeriapsisRadius(0.65, 0.55), 1e-12));
  });

  test('等質量円は同じ距離', () {
    final p = applyTwoBodyKeplerPreset(TwoBodyKeplerPreset.equalCircle);
    final s = evolveTwoBodyKepler(
      a1: p['a1']!,
      a2: p['a2']!,
      e: p['e']!,
      phase: 0.3,
    );
    expect(s.r1, closeTo(s.r2, 1e-12));
    expect(s.params.m1, closeTo(s.params.m2, 1e-12));
  });

  test('冥王星-カロンは重心が主星ディスクの外', () {
    final p = applyTwoBodyKeplerPreset(TwoBodyKeplerPreset.charon);
    final params = TwoBodyKeplerParams.fromMap(p);
    expect(params.disk1, lessThan(params.a1));
  });

  test('地球-月と太陽-地球は重心が主星ディスクの中', () {
    for (final preset in [
      TwoBodyKeplerPreset.earthMoon,
      TwoBodyKeplerPreset.sunEarth,
    ]) {
      final p = applyTwoBodyKeplerPreset(preset);
      final params = TwoBodyKeplerParams.fromMap(p);
      expect(params.disk1, greaterThan(params.a1 * (1 + params.e)));
    }
  });

  test('楕円プリセットは等質量で扁平', () {
    final p = applyTwoBodyKeplerPreset(TwoBodyKeplerPreset.equalEllipse);
    expect(p['a1'], closeTo(p['a2']!, 1e-12));
    expect(p['e']!, greaterThan(0.5));
  });

  test('力学の2体問題カテゴリに連星がある', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final twoBody = dynamics.subcategories.firstWhere((s) => s.name == '2体問題');
    expect(twoBody.videos, contains(twoBodyKepler2D));
    expect(twoBodyKepler2D.title, '2体問題(重力・連星)');
    final kepler = dynamics.subcategories.firstWhere((s) => s.name == 'ケプラーの法則');
    expect(kepler.videos, isNot(contains(twoBodyKepler2D)));
  });
}
