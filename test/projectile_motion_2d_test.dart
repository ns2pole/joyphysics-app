import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/dynamics/animations/projectileMotion2D.dart';

void main() {
  test('g は 9.8 m/s²', () {
    expect(kProjectileG, 9.8);
  });

  test('45° では飛行時間・到達距離・最高点が公式と一致する', () {
    const params = ProjectileParams(v0: 10, deg: 45);
    final t = projectileFlightDuration(params);
    final expectedT = 2 * 10 * math.sin(math.pi / 4) / 9.8;
    expect(t, closeTo(expectedT, 1e-12));
    expect(t, inInclusiveRange(1.2, 1.7));

    final range = projectileRange(params);
    expect(range, closeTo(10 * 10 / 9.8, 1e-9));
    expect(range, inInclusiveRange(8, 12));

    final apexT = t / 2;
    final apex = projectileAt(params, apexT);
    expect(apex.vy, closeTo(0, 1e-9));
    expect(apex.y, closeTo(projectileApexHeight(params), 1e-9));
    expect(apex.y, inInclusiveRange(2, 4));

    final landed = projectileAt(params, t);
    expect(landed.y, closeTo(0, 1e-9));
    expect(landed.x, closeTo(range, 1e-9));
    expect(landed.vx, closeTo(params.vx0, 1e-12));
    expect(landed.vy, closeTo(-params.vy0, 1e-9));
  });

  test('飛行中は地面より下に潜らない', () {
    const params = ProjectileParams(v0: 12, deg: 45);
    final t = projectileFlightDuration(params);
    expect(t, inInclusiveRange(1.0, 2.5));
    for (var i = 0; i <= 20; i++) {
      final s = projectileAt(params, t * i / 20);
      expect(s.y, greaterThan(-1e-8));
      expect(s.vx, closeTo(params.vx0, 1e-12));
      expect(s.vy, closeTo(params.vy0 - 9.8 * s.t, 1e-12));
    }
  });

  test('30° と 60° の到達距離は等しく、45° より短い', () {
    const a = ProjectileParams(v0: 15, deg: 30);
    const b = ProjectileParams(v0: 15, deg: 60);
    const c = ProjectileParams(v0: 15, deg: 45);
    expect(projectileRange(a), closeTo(projectileRange(b), 1e-9));
    expect(projectileRange(c), greaterThan(projectileRange(a)));
    expect(projectileFlightDuration(b), greaterThan(projectileFlightDuration(a)));
  });

  test('浅い角度でも数秒以内に着地する', () {
    const params = ProjectileParams(v0: 6, deg: 15);
    final t = projectileFlightDuration(params);
    expect(t, greaterThan(0.2));
    expect(t, lessThan(1.0));
    expect(projectileAt(params, t).y, closeTo(0, 1e-9));
    expect(projectileAt(params, t * 0.5).y, greaterThan(0));
  });

  test('高さ 6 m の高台からだと着地が遅くなる', () {
    const ground = ProjectileParams(v0: 12, deg: 45);
    const cliff = ProjectileParams(v0: 12, deg: 45, h: 6);
    final t0 = projectileFlightDuration(ground);
    final t = projectileFlightDuration(cliff);
    final vy = 12 * math.sin(math.pi / 4);
    final expected = (vy + math.sqrt(vy * vy + 2 * 9.8 * 6)) / 9.8;
    expect(t, closeTo(expected, 1e-12));
    expect(t, greaterThan(t0));
    expect(t, inInclusiveRange(1.5, 3.5));

    expect(projectileAt(cliff, 0).y, closeTo(6, 1e-12));
    final landed = projectileAt(cliff, t);
    expect(landed.y, closeTo(0, 1e-8));
    expect(landed.x, closeTo(projectileRange(cliff), 1e-8));
    expect(
      projectileApexHeight(cliff),
      closeTo(6 + vy * vy / (2 * 9.8), 1e-9),
    );
    for (var i = 0; i <= 16; i++) {
      expect(projectileAt(cliff, t * i / 16).y, greaterThan(-1e-8));
    }

    const shallow = ProjectileParams(v0: 15, deg: 30, h: 6);
    const steep = ProjectileParams(v0: 15, deg: 60, h: 6);
    expect(
      (projectileRange(shallow) - projectileRange(steep)).abs(),
      greaterThan(0.5),
    );
  });

  test('g を半分にすると平地 45° の到達距離は約 2 倍', () {
    const earth = ProjectileParams(v0: 10, deg: 45);
    const light = ProjectileParams(v0: 10, deg: 45, g: 4.9);
    expect(projectileRange(light), closeTo(projectileRange(earth) * 2, 1e-9));
    expect(projectileFlightDuration(light), closeTo(projectileFlightDuration(earth) * 2, 1e-9));
    expect(projectileApexHeight(light), closeTo(projectileApexHeight(earth) * 2, 1e-9));
  });

  test('下向きでも高台から着地し、最高点は投げ出し', () {
    const params = ProjectileParams(v0: 12, deg: -45, h: 6);
    expect(params.vy0, lessThan(0));
    expect(params.vx0, greaterThan(0));
    final t = projectileFlightDuration(params);
    final vy = 12 * math.sin(-math.pi / 4);
    final expected = (vy + math.sqrt(vy * vy + 2 * 9.8 * 6)) / 9.8;
    expect(t, closeTo(expected, 1e-12));
    expect(t, greaterThan(0.2));
    expect(t, lessThan(1.2));
    expect(projectileApexHeight(params), closeTo(6, 1e-12));
    expect(projectileAt(params, 0).y, closeTo(6, 1e-12));
    final landed = projectileAt(params, t);
    expect(landed.y, closeTo(0, 1e-8));
    expect(landed.x, closeTo(projectileRange(params), 1e-8));
    expect(landed.x, greaterThan(1));
    for (var i = 1; i <= 8; i++) {
      final s = projectileAt(params, t * i / 8);
      expect(s.y, lessThan(6 + 1e-8));
      expect(s.vy, lessThan(0));
    }
  });

  test('速い投射でも飛行時間は数秒の桁', () {
    const params = ProjectileParams(v0: 20, deg: 75);
    final t = projectileFlightDuration(params);
    expect(t, inInclusiveRange(2.0, 5.0));
    final landed = projectileAt(params, t);
    expect(landed.y, closeTo(0, 1e-8));
    expect(landed.x, closeTo(projectileRange(params), 1e-8));
    expect(projectileApexHeight(params), lessThan(25));
  });
}
