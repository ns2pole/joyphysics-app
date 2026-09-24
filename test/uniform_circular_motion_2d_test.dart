import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/uniformCircularMotion2D.dart';

void main() {
  const params = CircularParams(r: 1, v: 2);

  test('周期は 2πR/v、向心加速度は v²/R', () {
    expect(params.period, closeTo(2 * math.pi * 1 / 2, 1e-12));
    expect(params.centripetalAccel, closeTo(4, 1e-12));
    expect(params.tension, closeTo(kCircularMass * 4, 1e-12));
    expect(params.omega, closeTo(2, 1e-12));
  });

  test('位置は円周上で、速度は接線・速さは一定', () {
    final period = params.period;
    for (var i = 0; i <= 8; i++) {
      final s = circularAt(params, period * i / 8);
      expect(s.x * s.x + s.y * s.y, closeTo(params.r * params.r, 1e-9));
      expect(s.speed, closeTo(params.v, 1e-9));
      expect(s.x * s.vx + s.y * s.vy, closeTo(0, 1e-9));
    }
  });

  test('初めは右側で上向き、半周で逆向き、1周でもとの位置', () {
    final start = circularAt(params, 0);
    expect(start.x, closeTo(params.r, 1e-12));
    expect(start.y, closeTo(0, 1e-12));
    expect(start.vx, closeTo(0, 1e-12));
    expect(start.vy, closeTo(params.v, 1e-12));

    final half = circularAt(params, params.period / 2);
    expect(half.x, closeTo(-params.r, 1e-9));
    expect(half.y, closeTo(0, 1e-9));
    expect(half.vy, closeTo(-params.v, 1e-9));

    final lap = circularAt(params, params.period);
    expect(lap.x, closeTo(params.r, 1e-9));
    expect(lap.y, closeTo(0, 1e-9));
    expect(lap.speed, closeTo(params.v, 1e-9));
  });

  test('残像は1周分で頭打ちになる', () {
    final oneLap = circularStrobe(params, params.period);
    final twoLaps = circularStrobe(params, params.period * 2);
    expect(twoLaps.length, oneLap.length);
    expect(oneLap.length, lessThan(80));
  });

  test('残像の間隔は vΔt の弧長', () {
    final strobes = circularStrobe(params, params.period);
    expect(strobes, isNotEmpty);
    final arc = params.v * kCircularStrobeDt;
    for (var i = 1; i < strobes.length; i++) {
      final a = strobes[i - 1];
      final b = strobes[i];
      final chord = math.sqrt(math.pow(b.x - a.x, 2) + math.pow(b.y - a.y, 2));
      final angle = 2 * math.asin((chord / (2 * params.r)).clamp(0.0, 1.0));
      expect(params.r * angle, closeTo(arc, 1e-9));
    }
  });

  test('力学の円運動に等速円運動がある', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final circular = dynamics.subcategories.firstWhere((s) => s.name == '円運動');
    expect(circular.videos, contains(uniformCircularMotion2D));
  });
}
