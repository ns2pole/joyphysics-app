import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/eulerForce2D.dart';

void main() {
  const params = EulerParams(r: 1, alpha: 0.8, mass: 1);

  test('t = 0 ではオイラー力だけがあり、遠心力は 0', () {
    final s = eulerAt(params, 0);
    expect(s.omega, 0);
    expect(s.theta, 0);
    expect(s.centrifugal, 0);
    expect(s.realRadial, 0);
    expect(s.euler, closeTo(-params.mass * params.alpha * params.r, 1e-12));
    expect(s.realTangential + s.euler, closeTo(0, 1e-12));
  });

  test('角速度は αt、角度は (1/2)αt²、円周上を速くなる', () {
    final t = 1.5;
    final s = eulerAt(params, t);
    final omega = params.alpha * t;
    final theta = 0.5 * params.alpha * t * t;
    expect(s.omega, closeTo(omega, 1e-12));
    expect(s.theta, closeTo(theta, 1e-12));
    expect(s.x, closeTo(params.r * math.cos(theta), 1e-12));
    expect(s.y, closeTo(params.r * math.sin(theta), 1e-12));
    expect(s.speed, closeTo(omega * params.r, 1e-9));
    expect(s.x * s.vx + s.y * s.vy, closeTo(0, 1e-9));
  });

  test('台上では向心力と遠心力、接線力とオイラー力がつり合う', () {
    final s = eulerAt(params, 1.2);
    expect(s.realRadial + s.centrifugal, closeTo(0, 1e-12));
    expect(s.realTangential + s.euler, closeTo(0, 1e-12));
    expect(s.centrifugal, greaterThan(0));
    expect(s.euler, lessThan(0));
  });

  test('力学の慣性力にオイラー力がある', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final sections = dynamics.subcategories.where((s) => s.name == '慣性力');
    expect(sections.single.videos, contains(eulerForce2D));
    expect(eulerForce2D.title, 'オイラー力');
  });
}
