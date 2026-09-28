import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/arrow_screen.dart';
import 'package:joyphysics/experiment/dynamics/animations/conicalPendulum3D.dart';

void main() {
  group('物理のつじつま', () {
    test('慣性系の運動方程式残差が開き角全体でほぼ 0', () {
      for (final deg in [15.0, 30.0, 40.0, 55.0, 65.0]) {
        for (final length in [0.8, 1.2, 2.0]) {
          for (final mass in [0.5, 1.0, 3.5]) {
            final p = ConicalPendulumParams(
              thetaDeg: deg,
              length: length,
              mass: mass,
            );
            final f = conicalPendulumForces(p);
            expect(
              conicalInertialResidual(f, p.mass),
              lessThan(1e-9),
              reason: 'θ=$deg l=$length m=$mass',
            );
            expect(f.sumTrueX, closeTo(p.mass * f.ax, 1e-9));
            expect(f.sumTrueZ, closeTo(p.mass * f.az, 1e-9));
          }
        }
      }
    });

    test('回転系のつり合い残差がほぼ 0', () {
      for (final deg in [kConeMinThetaDeg, 40.0, kConeMaxThetaDeg]) {
        final p = ConicalPendulumParams(thetaDeg: deg, length: 1.2, mass: 1.7);
        final f = conicalPendulumForces(p);
        expect(conicalRotatingResidual(f), lessThan(1e-9), reason: 'θ=$deg');
      }
    });

    test('ω² = g/(l cosθ)、張力は mg/cosθ、周期は 2π√(h/g)', () {
      const p = ConicalPendulumParams(thetaDeg: 40, length: 1.2, mass: 2.0);
      final cosT = math.cos(p.theta);
      expect(p.omega * p.omega, closeTo(kConeG / (p.length * cosT), 1e-12));
      expect(p.tension, closeTo(p.mass * kConeG / cosT, 1e-12));
      expect(
        p.period,
        closeTo(2 * math.pi * math.sqrt(p.coneHeight / kConeG), 1e-12),
      );
      expect(p.coneHeight, closeTo(p.length * cosT, 1e-12));
      expect(p.radius, closeTo(p.length * math.sin(p.theta), 1e-12));
    });

    test('角速度は質量によらず、開き角が大きいほど速い', () {
      final light = ConicalPendulumParams(thetaDeg: 35, length: 1.0, mass: 0.5);
      final heavy = ConicalPendulumParams(thetaDeg: 35, length: 1.0, mass: 4.0);
      expect(light.omega, closeTo(heavy.omega, 1e-12));
      final wide = ConicalPendulumParams(thetaDeg: 60, length: 1.0, mass: 1.0);
      expect(wide.omega, greaterThan(light.omega));
    });

    test('遠心力は mω²r で、慣性加速度の符号反転', () {
      const p = ConicalPendulumParams(thetaDeg: 50, length: 1.5, mass: 1.3);
      final f = conicalPendulumForces(p);
      expect(f.cenMag, closeTo(p.mass * p.omega * p.omega * p.radius, 1e-9));
      expect(f.cenMag, closeTo(p.mass * kConeG * math.tan(p.theta), 1e-9));
      expect(f.cenX, closeTo(-p.mass * f.ax, 1e-12));
    });

    test('三力の比は円錐断面 l:h:r と相似', () {
      const p = ConicalPendulumParams(thetaDeg: 37, length: 1.1, mass: 2.4);
      final f = conicalPendulumForces(p);
      expect(
        f.tensionMag / p.length,
        closeTo(f.gravityMag / p.coneHeight, 1e-9),
      );
      expect(f.tensionMag / p.length, closeTo(f.cenMag / p.radius, 1e-9));
    });

    test('サンプルは糸長上にあり、回転系では y=0、速度は水平で半径に垂直', () {
      const p = ConicalPendulumParams(thetaDeg: 45, length: 1.0, mass: 1.0);
      final s = conicalPendulumSampleAt(p, 0.37);
      expect(
        s.x * s.x + s.y * s.y + s.z * s.z,
        closeTo(p.length * p.length, 1e-9),
      );
      expect(s.z, closeTo(-p.coneHeight, 1e-12));
      expect(s.yRot, closeTo(0, 1e-12));
      expect(s.xRot, closeTo(p.radius, 1e-12));
      expect(s.zRot, closeTo(s.z, 1e-12));
      expect(s.phi, closeTo(p.omega * 0.37, 1e-12));
      expect(s.x * s.vx + s.y * s.vy, closeTo(0, 1e-9));
      final speed = math.sqrt(s.vx * s.vx + s.vy * s.vy);
      expect(speed, closeTo(p.omega * p.radius, 1e-9));
      expect(s.vz.abs(), lessThan(1e-12));
    });

    test('半回転すると慣性系の位置は回転系の位置を φ だけ回したもの', () {
      const p = ConicalPendulumParams(thetaDeg: 30, length: 1.4, mass: 1.0);
      final t = math.pi / p.omega;
      final s = conicalPendulumSampleAt(p, t);
      expect(s.phi, closeTo(math.pi, 1e-9));
      expect(s.x, closeTo(-s.xRot, 1e-9));
      expect(s.y, closeTo(0, 1e-9));
      expect(s.z, closeTo(s.zRot, 1e-12));
    });
  });

  test('張力が視線に沿うと画面上の長さは潰れ、正面では潰れない', () {
    expect(
      arrowScreenForeshorten(screenPx: 20, pxPerMeter: 80),
      closeTo(1, 1e-12),
    );
    expect(
      arrowScreenForeshorten(screenPx: 2, pxPerMeter: 80),
      closeTo(0.1, 1e-12),
    );
    expect(arrowScreenForeshorten(screenPx: 0, pxPerMeter: 80), 0);

    const p = ConicalPendulumParams(thetaDeg: 40, length: 1.2, mass: 1);
    // 張力は糸に沿い、大きさは一周を通して一定。
    final early = conicalPendulumForces(p).tensionMag;
    final later = conicalPendulumSampleAt(p, 0.4).forces.tensionMag;
    expect(later, closeTo(early, 1e-12));

    // 視線を φ=0 の張力に合わせる。正投影ではこの瞬間、画面成分は 0。
    final view = (-math.sin(p.theta), 0.0, math.cos(p.theta));
    double sinPsi(double phi) {
      final u = (
        -math.sin(p.theta) * math.cos(phi),
        -math.sin(p.theta) * math.sin(phi),
        math.cos(p.theta),
      );
      final dot = u.$1 * view.$1 + u.$2 * view.$2 + u.$3 * view.$3;
      return math.sqrt((1 - dot * dot).clamp(0.0, 1.0));
    }

    const unit = 90.0;
    final collapsed = kArrowWorldEps * unit * sinPsi(0);
    final face = kArrowWorldEps * unit;
    expect(sinPsi(0), lessThan(1e-6));
    expect(
      arrowScreenForeshorten(screenPx: collapsed, pxPerMeter: unit),
      lessThan(1e-6),
    );
    expect(
      arrowScreenForeshorten(screenPx: face, pxPerMeter: unit),
      closeTo(1, 1e-12),
    );
    // 潰れを捨てて |S| のまま描くと、見えなくなる瞬間に矢印だけ全長で残る。
    final fullPx = 28 * p.tension / (p.mass * kConeG);
    final drawn =
        fullPx * arrowScreenForeshorten(screenPx: collapsed, pxPerMeter: unit);
    expect(fullPx, greaterThan(20));
    expect(drawn, lessThan(1));
  });

  test('力学の振り子に円錐振り子がある', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final pendulum = dynamics.subcategories.firstWhere((s) => s.name == '振り子');
    expect(pendulum.videos, contains(conicalPendulum3D));
    expect(conicalPendulum3D.title, '円錐振り子');
    expect(conicalPendulum3D.isSimulation, isTrue);
    expect(conicalPendulum3D.latex, isNot(contains(r'\dfrac')));
    expect(conicalPendulum3D.latex, isNot(contains(r'\tfrac')));
    expect(conicalPendulum3D.latex, contains(r'\frac{g}{l\cos\theta}'));
    expect(conicalPendulum3D.latex, contains(r'\frac{h}{g}'));
  });
}
