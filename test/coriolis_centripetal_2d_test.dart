import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/coriolisCentripetal2D.dart';

void main() {
  const params = RestRotatingParams(r: 1, omega: 2, mass: 1);

  test('静止物体を回って見ると、コリオリは内向きで遠心力の2倍', () {
    expect(params.centrifugal, closeTo(4, 1e-12));
    expect(params.coriolisRadial, closeTo(-8, 1e-12));
    expect(params.centripetal, closeTo(4, 1e-12));
    expect(params.centrifugal + params.coriolisRadial, closeTo(-params.centripetal, 1e-12));
    expect(params.rotatingSpeed, closeTo(2, 1e-12));
  });

  test('地上では位置も速度も変わらない', () {
    final a = restLabAt(params, 0);
    final b = restLabAt(params, 1.2);
    expect(a.x, params.r);
    expect(a.y, 0);
    expect(b.x, a.x);
    expect(b.y, a.y);
  });

  test('人の座標系では円周上を速さ ΩR で動き、合力が向心力', () {
    final frame = restRotatingAt(params, 0.3);
    expect(frame.xTilde * frame.xTilde + frame.yTilde * frame.yTilde, closeTo(1, 1e-9));
    expect(frame.speed, closeTo(params.rotatingSpeed, 1e-9));
    expect(frame.xTilde * frame.vxTilde + frame.yTilde * frame.vyTilde, closeTo(0, 1e-9));
    final radial = frame.centrifugalRadial + frame.coriolisRadial;
    expect(radial, closeTo(-params.mass * params.omega * params.omega * params.r, 1e-9));
    final speedSign = frame.vxTilde * (-frame.yTilde) + frame.vyTilde * frame.xTilde;
    expect(speedSign, lessThan(0));
  });

  test('半周で反対側に来る', () {
    final half = restRotatingAt(params, math.pi / params.omega);
    expect(half.xTilde, closeTo(-params.r, 1e-9));
    expect(half.yTilde, closeTo(0, 1e-9));
  });

  test('力学の慣性力に遠心力とコリオリ力がある', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final sections = dynamics.subcategories.where((s) => s.name == '慣性力');
    expect(sections.single.videos, contains(coriolisCentripetal2D));
    expect(coriolisCentripetal2D.title, '遠心力とコリオリ力(静止物体)');
  });
}
