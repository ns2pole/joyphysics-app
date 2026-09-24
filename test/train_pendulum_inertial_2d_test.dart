import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/trainPendulumInertial2D.dart';

void main() {
  const params = TrainPendulumParams(accel: 3, length: 0.9, mass: 1, amplitudeDeg: 20);

  test('静止では傾きと張力が慣性系のつり合いと一致する', () {
    final lean = trainEquilibriumLean(params.accel);
    expect(math.tan(lean), closeTo(params.accel / kTrainG, 1e-12));
    final tension = trainEquilibriumTension(params.mass, params.accel);
    expect(tension, closeTo(params.mass * math.sqrt(kTrainG * kTrainG + 9), 1e-12));
    expect(tension * math.sin(lean), closeTo(params.mass * params.accel, 1e-9));
    expect(tension * math.cos(lean), closeTo(params.mass * kTrainG, 1e-9));
    expect(trainThetaAccel(trainEquilibriumTheta(params.accel), params.length, params.accel), closeTo(0, 1e-12));
  });

  test('A = 0 では鉛直に垂れ、張力は mg、周期は普通の振り子', () {
    expect(trainEquilibriumTheta(0), closeTo(0, 1e-12));
    expect(trainEquilibriumTension(2, 0), closeTo(19.6, 1e-12));
    expect(trainPendulumPeriod(params.length, 0), closeTo(2 * math.pi * math.sqrt(params.length / kTrainG), 1e-12));
  });

  test('揺れはつり合いの前後を往復し、加速度ゼロの周期に近い', () {
    const still = TrainPendulumParams(accel: 0, length: 1, mass: 1, amplitudeDeg: 8);
    const dt = 0.002;
    final period = trainPendulumPeriod(still.length, 0);
    final steps = (period / dt).round();
    final back = trainPendulumIntegrate(TrainPendulumKind.swing, still, dt, steps);
    expect(back.theta, closeTo(still.amplitude, 0.03));
    expect(back.omega.abs(), lessThan(0.2));

    var crossed = false;
    final eq = trainEquilibriumTheta(params.accel);
    for (var n = 1; n < 800; n++) {
      final s = trainPendulumIntegrate(TrainPendulumKind.swing, params, 0.01, n);
      if ((s.theta - eq) * params.amplitude < 0) {
        crossed = true;
        break;
      }
    }
    expect(crossed, isTrue);
  });

  test('静止の積分では角がつり合いのまま、電車は等加速度', () {
    final mid = trainPendulumIntegrate(TrainPendulumKind.rest, params, 0.01, 80);
    expect(mid.theta, closeTo(trainEquilibriumTheta(params.accel), 1e-12));
    expect(mid.omega, closeTo(0, 1e-12));
    expect(mid.cartV, closeTo(params.accel * mid.cycle, 1e-9));
    expect(mid.cartX, closeTo(0.5 * params.accel * mid.cycle * mid.cycle, 1e-9));
    expect(mid.tension, closeTo(trainEquilibriumTension(params.mass, params.accel), 1e-9));
  });

  test('地上の軌跡は支点の等加速度運動に糸の向きを足したもの', () {
    const t = 0.8;
    final theta = trainEquilibriumTheta(params.accel);
    final ground = trainBobGround(params.accel, t, params.length, theta);
    final train = trainBobTrain(params.length, theta);
    expect(ground.x, closeTo(0.5 * params.accel * t * t + params.length * math.sin(theta), 1e-12));
    expect(ground.y, closeTo(-params.length * math.cos(theta), 1e-12));
    expect(train.x, closeTo(params.length * math.sin(theta), 1e-12));
    expect(train.y, closeTo(ground.y, 1e-12));

    final later = trainBobGround(params.accel, t + 0.4, params.length, theta);
    expect(later.y, closeTo(ground.y, 1e-12));
    expect(later.x, greaterThan(ground.x));
  });

  test('揺れでも電車内の支点距離は l のまま', () {
    final mid = trainPendulumIntegrate(TrainPendulumKind.swing, params, 0.01, 40);
    final train = trainBobTrain(params.length, mid.theta);
    final ground = trainBobGround(params.accel, mid.t, params.length, mid.theta);
    expect(math.sqrt(train.x * train.x + train.y * train.y), closeTo(params.length, 1e-9));
    expect(ground.x - 0.5 * params.accel * mid.t * mid.t, closeTo(train.x, 1e-9));
    expect(ground.y, closeTo(train.y, 1e-9));
  });

  test('力学の慣性力に加速電車の振り子がある', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final sections = dynamics.subcategories.where((s) => s.name == '慣性力');
    expect(sections.single.videos, contains(trainPendulumInertial2D));
  });
}
