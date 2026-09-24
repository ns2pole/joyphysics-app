import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/coriolisSpiral2D.dart';

void main() {
  const params = SpiralParams(v: 1, omega: 2, mass: 1);

  test('地上では y 軸上を速さ v で進み、力は不要', () {
    final s = spiralLabAt(params, 0.4);
    expect(s.x, 0);
    expect(s.y, closeTo(0.4, 1e-12));
    expect(s.vx, 0);
    expect(s.vy, params.v);
  });

  test('回転系の解は vt sin、vt cos で、r = (v/ω)θ', () {
    final t = 0.35;
    final frame = spiralRotatingAt(params, t);
    expect(frame.xTilde, closeTo(params.v * t * math.sin(params.omega * t), 1e-12));
    expect(frame.yTilde, closeTo(params.v * t * math.cos(params.omega * t), 1e-12));
    final theta = params.omega * t;
    expect(frame.radius, closeTo(params.v / params.omega * theta, 1e-9));
  });

  test('t = 0 では遠心力は 0、コリオリは進行方向の右向き 2mωv', () {
    final frame = spiralRotatingAt(params, 0);
    expect(frame.xTilde, 0);
    expect(frame.yTilde, 0);
    expect(frame.vxTilde, closeTo(0, 1e-12));
    expect(frame.vyTilde, closeTo(params.v, 1e-12));
    expect(frame.centrifugalX, closeTo(0, 1e-12));
    expect(frame.centrifugalY, closeTo(0, 1e-12));
    expect(frame.coriolisX, closeTo(2 * params.mass * params.omega * params.v, 1e-12));
    expect(frame.coriolisY, closeTo(0, 1e-12));
  });

  test('v が負なら原点へ向かい、通り過ぎて反対側へ出る', () {
    const toward = SpiralParams(y0: 4, v: -2, omega: 2, mass: 1);
    final before = spiralLabAt(toward, 1);
    expect(before.y, closeTo(2, 1e-12));
    final after = spiralLabAt(toward, 3);
    expect(after.y, closeTo(-2, 1e-12));
    final frame = spiralRotatingAt(toward, 3);
    final along = -2.0;
    expect(frame.xTilde, closeTo(along * math.sin(6), 1e-12));
    expect(frame.yTilde, closeTo(along * math.cos(6), 1e-12));
    expect(frame.radius, closeTo(2, 1e-12));
  });

  test('力学の慣性力に等速直線運動の記事がある', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final sections = dynamics.subcategories.where((s) => s.name == '慣性力');
    expect(sections.single.videos, contains(coriolisSpiral2D));
    expect(coriolisSpiral2D.title, '遠心力とコリオリ力(等速直線運動)');
  });
}
