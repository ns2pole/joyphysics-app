import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/movableWedge1D.dart';

void main() {
  const params = MovableWedgeParams(
    thetaDeg: 30,
    cartMass: 2,
    blockMass: 1,
    length: 1.5,
  );

  test('台の加速度と移動距離は閉形式どおり', () {
    final th = 30 * math.pi / 180;
    final expectedA = 1 * 9.8 * math.sin(th) * math.cos(th) /
        (2 + 1 * math.sin(th) * math.sin(th));
    expect(wedgeCartAcceleration(params), closeTo(expectedA, 1e-12));
    expect(
      wedgeCartDistance(params),
      closeTo(1 * 1.5 * math.cos(th) / 3, 1e-12),
    );
    expect(wedgeNormal(params), greaterThan(0));
  });

  test('滑り切ると s = l で、台は L だけ動いている', () {
    final duration = wedgeSlideDuration(params);
    final landed = movableWedgeAt(params, duration);
    expect(landed.landed, isTrue);
    expect(landed.s, closeTo(params.length, 1e-9));
    expect(landed.yBlock, closeTo(0, 1e-9));
    expect(landed.xCart, closeTo(wedgeCartDistance(params), 1e-9));
    expect(landed.xBlock, closeTo(landed.xCart, 1e-9));

    final later = movableWedgeAt(params, duration + 3);
    expect(later.t, closeTo(duration, 1e-12));
    expect(later.xCart, closeTo(landed.xCart, 1e-12));
  });

  test('重心の水平位置は途中でも動かない', () {
    final x0 = params.length * math.cos(params.theta);
    for (var i = 0; i <= 8; i++) {
      final sample = movableWedgeAt(params, wedgeSlideDuration(params) * i / 8);
      final shift = params.blockMass * (sample.xBlock - x0) +
          params.cartMass * sample.xCart;
      expect(shift, closeTo(0, 1e-9));
    }
  });

  test('M を大きくすると L は短く、m を大きくすると L は長くなる', () {
    const heavy = MovableWedgeParams(
      thetaDeg: 30,
      cartMass: 8,
      blockMass: 1,
      length: 1.5,
    );
    const lightBlock = MovableWedgeParams(
      thetaDeg: 30,
      cartMass: 2,
      blockMass: 0.2,
      length: 1.5,
    );
    expect(wedgeCartDistance(heavy), lessThan(wedgeCartDistance(params)));
    expect(wedgeCartAcceleration(heavy), lessThan(wedgeCartAcceleration(params)));
    expect(wedgeCartDistance(lightBlock), lessThan(wedgeCartDistance(params)));
  });

  test('スライダーの端でも垂直抗力は正で、時間は有限', () {
    const corners = [
      MovableWedgeParams(thetaDeg: 20, cartMass: 0.5, blockMass: 4, length: 0.8),
      MovableWedgeParams(thetaDeg: 60, cartMass: 8, blockMass: 0.2, length: 3),
    ];
    for (final corner in corners) {
      expect(wedgeNormal(corner), greaterThan(0));
      final t = wedgeSlideDuration(corner);
      expect(t, greaterThan(0.05));
      expect(t, lessThan(5));
      final landed = movableWedgeAt(corner, t);
      expect(landed.s, closeTo(corner.length, 1e-8));
    }
  });

  test('力学の慣性力に動く斜面がある', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final section = dynamics.subcategories.firstWhere((s) => s.name == '慣性力');
    expect(section.videos, contains(movableWedge1D));
  });
}
