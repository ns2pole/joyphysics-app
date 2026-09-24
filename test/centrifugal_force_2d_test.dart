import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/centrifugalForce2D.dart';

void main() {
  const params = CentrifugalParams(r: 1, v: 2, mass: 1);

  test('張力と遠心力はどちらも m v²/R', () {
    expect(params.omega, closeTo(2, 1e-12));
    expect(params.tension, closeTo(4, 1e-12));
    expect(params.centrifugal, closeTo(params.tension, 1e-12));
  });

  test('質量を変えると張力も遠心力も同じ割合で変わる', () {
    const heavy = CentrifugalParams(r: 1, v: 2, mass: 2);
    expect(heavy.tension, closeTo(params.tension * 2, 1e-12));
    expect(heavy.centrifugal, closeTo(heavy.tension, 1e-12));
  });

  test('地上では円周上を等速で動き、半径方向の速度は 0', () {
    final period = 2 * math.pi * params.r / params.v;
    for (var i = 0; i <= 8; i++) {
      final s = centrifugalLabAt(params, period * i / 8);
      expect(s.x * s.x + s.y * s.y, closeTo(params.r * params.r, 1e-9));
      expect(s.speed, closeTo(params.v, 1e-9));
      expect(s.x * s.vx + s.y * s.vy, closeTo(0, 1e-9));
    }
  });

  test('一緒に回る座標系ではボールは静止し、張力と遠心力がつり合う', () {
    final frame = centrifugalRotatingAt(params);
    expect(frame.xTilde, params.r);
    expect(frame.yTilde, 0);
    expect(frame.vxTilde, 0);
    expect(frame.vyTilde, 0);
    expect(frame.tensionRadial + frame.centrifugalRadial, closeTo(0, 1e-12));
  });

  test('力学の慣性力に遠心力がある', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final sections = dynamics.subcategories.where((s) => s.name == '慣性力');
    expect(sections.length, 1);
    expect(sections.single.videos, contains(centrifugalForce2D));
    expect(centrifugalForce2D.title, '遠心力');
  });
}
