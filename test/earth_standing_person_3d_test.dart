import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/earthStandingPerson3D.dart';

void main() {
  group('物理のつじつま', () {
    test('慣性系の運動方程式残差が緯度全体でほぼ 0', () {
      for (final lat in [-90.0, -60.0, -35.0, 0.0, 20.0, 45.0, 90.0]) {
        for (final w in [0.5, 1.5, 2.5]) {
          final p = EarthStandingParams(latDeg: lat, omega: w, mass: 1.7);
          final f = earthStandingForces(p);
          expect(
            earthStandingInertialResidual(f, p.mass),
            lessThan(1e-9),
            reason: 'lat=$lat ω=$w',
          );
        }
      }
    });

    test('共回転系のつり合い残差が緯度全体でほぼ 0', () {
      for (final lat in [-90.0, -45.0, 0.0, 35.0, 90.0]) {
        for (final w in [0.8, 2.2, kEarthMaxOmega]) {
          final p = EarthStandingParams(latDeg: lat, omega: w, mass: 1.0);
          final f = earthStandingForces(p);
          expect(
            earthStandingRotatingResidual(f),
            lessThan(1e-9),
            reason: 'lat=$lat ω=$w',
          );
        }
      }
    });

    test('赤道: 摩擦 0、N = mg − mω²R、抗力は重力と反平行', () {
      const p = EarthStandingParams(latDeg: 0, omega: 2.0, mass: 2.0);
      final f = earthStandingForces(p);
      expect(f.rho, closeTo(kEarthR, 1e-12));
      expect(f.friction, closeTo(0, 1e-12));
      expect(f.normal, closeTo(p.mass * (kEarthG - p.omega * p.omega * kEarthR), 1e-9));
      // R と Fg は x 軸上で反対向き
      expect(f.gz, closeTo(0, 1e-12));
      expect(f.rz, closeTo(0, 1e-12));
      expect(f.gx < 0, isTrue);
      expect(f.rx > 0, isTrue);
      // 平行（反平行）: 外積相当 rz*gx - rx*gz ≈ 0 かつ内積 < 0
      expect(f.rx * f.gx, lessThan(0));
    });

    test('極: ρ=0、摩擦 0、N=mg、加速度 0', () {
      for (final lat in [-90.0, 90.0]) {
        final p = EarthStandingParams(latDeg: lat, omega: 2.5, mass: 1.5);
        final f = earthStandingForces(p);
        expect(f.rho.abs(), lessThan(1e-12));
        expect(f.ax.abs() + f.az.abs(), lessThan(1e-12));
        expect(f.friction.abs(), lessThan(1e-12));
        expect(f.normal, closeTo(p.mass * kEarthG, 1e-9));
        expect(f.cenX.abs(), lessThan(1e-12));
      }
    });

    test('中緯度: 摩擦は mω²ρ sinλ、抗力は重力と非平行', () {
      const p = EarthStandingParams(latDeg: 35, omega: 2.2, mass: 1.0);
      final f = earthStandingForces(p);
      final lam = p.latRad;
      expect(
        f.friction,
        closeTo(p.mass * p.omega * p.omega * f.rho * math.sin(lam), 1e-9),
      );
      expect(
        f.normal,
        closeTo(
          p.mass * kEarthG - p.mass * p.omega * p.omega * kEarthR * math.cos(lam) * math.cos(lam),
          1e-9,
        ),
      );
      // 外積の z 成分相当（2D）: rx*gz - rz*gx ≠ 0
      final cross = f.rx * f.gz - f.rz * f.gx;
      expect(cross.abs(), greaterThan(1e-6));
    });

    test('パラメータ範囲では垂直抗力 N が正（床から離れない）', () {
      for (final lat in [-90.0, -60.0, -30.0, 0.0, 30.0, 60.0, 90.0]) {
        for (final w in [kEarthMinOmega, kEarthDefaultOmega, kEarthMaxOmega]) {
          final p = EarthStandingParams(latDeg: lat, omega: w, mass: 1.0);
          final f = earthStandingForces(p);
          expect(f.normal, greaterThan(0), reason: 'lat=$lat ω=$w');
        }
      }
    });

    test('遠心力は慣性加速度の符号反転（大きさ mω²ρ）', () {
      const p = EarthStandingParams(latDeg: 40, omega: 2.0, mass: 3.0);
      final f = earthStandingForces(p);
      expect(f.cenX, closeTo(-p.mass * f.ax, 1e-12));
      expect(f.cenMag, closeTo(p.mass * p.omega * p.omega * f.rho, 1e-9));
    });

    test('真の力の合力は m a（軸向き）', () {
      const p = EarthStandingParams(latDeg: 35, omega: 2.7, mass: 1.5);
      final f = earthStandingForces(p);
      expect(f.sumTrueX, closeTo(p.mass * f.ax, 1e-9));
      expect(f.sumTrueZ, closeTo(p.mass * f.az, 1e-9));
      expect(f.sumTrueMag, closeTo(p.mass * p.omega * p.omega * f.rho, 1e-9));
    });

    test('サンプル位置は球面上で、共回転では y=0', () {
      const p = EarthStandingParams(latDeg: -20, omega: 1.5, mass: 1.0);
      final s = earthStandingSampleAt(p, 1.25);
      expect(
        s.x * s.x + s.y * s.y + s.z * s.z,
        closeTo(kEarthR * kEarthR, 1e-9),
      );
      expect(s.yRot, closeTo(0, 1e-12));
      expect(s.phi, closeTo(p.omega * 1.25, 1e-12));
    });
  });

  test('力学の慣性力に地上に立つ人と遠心力がある', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final sections = dynamics.subcategories.where((s) => s.name == '慣性力');
    expect(sections.length, 1);
    expect(sections.single.videos, contains(earthStandingPerson3D));
    expect(earthStandingPerson3D.title, '地上に立つ人と遠心力');
  });
}
