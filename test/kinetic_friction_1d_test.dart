import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/kineticFriction1D.dart';

void main() {
  test('g は 9.8 m/s²', () {
    expect(kFrictionG, 9.8);
  });

  test('標準の初速と μ は停止時刻と停止距離が公式どおり', () {
    const params = KineticFrictionParams(v0: 4, mu: 0.20);
    final t = kineticFrictionStopTime(params)!;
    final x = kineticFrictionStopDistance(params)!;
    final a = 0.20 * 9.8;
    expect(t, closeTo(4 / a, 1e-12));
    expect(x, closeTo(16 / (2 * a), 1e-12));
    expect(t, inInclusiveRange(1.5, 2.5));
    expect(x, inInclusiveRange(3, 5));

    final start = kineticFrictionAt(params, 0);
    expect(start.x, closeTo(0, 1e-12));
    expect(start.v, closeTo(4, 1e-12));
    expect(start.a, closeTo(-a, 1e-12));
    expect(start.stopped, isFalse);

    final stopped = kineticFrictionAt(params, t);
    expect(stopped.x, closeTo(x, 1e-9));
    expect(stopped.v, closeTo(0, 1e-9));
    expect(stopped.a, closeTo(0, 1e-12));
    expect(stopped.stopped, isTrue);
  });

  test('停止時刻の半分では速さが半分、距離は停止距離の 3/4', () {
    const params = KineticFrictionParams(v0: 4, mu: 0.20);
    final t = kineticFrictionStopTime(params)!;
    final xStop = kineticFrictionStopDistance(params)!;
    final mid = kineticFrictionAt(params, t / 2);
    expect(mid.v, closeTo(2, 1e-9));
    expect(mid.x, closeTo(0.75 * xStop, 1e-9));
    expect(mid.a, closeTo(-0.20 * 9.8, 1e-12));

    for (var i = 0; i < 8; i++) {
      final s = kineticFrictionAt(params, t * i / 8);
      expect(s.v, closeTo(4 - 0.20 * 9.8 * s.t, 1e-9));
      expect(s.x, greaterThanOrEqualTo(-1e-12));
      expect(s.stopped, isFalse);
    }
  });

  test('停止時刻を過ぎても位置は止まったまま', () {
    const params = KineticFrictionParams(v0: 4, mu: 0.20);
    final t = kineticFrictionStopTime(params)!;
    final atStop = kineticFrictionAt(params, t);
    final later = kineticFrictionAt(params, t + 3);
    expect(later.x, closeTo(atStop.x, 1e-12));
    expect(later.v, closeTo(0, 1e-12));
    expect(later.a, closeTo(0, 1e-12));
    expect(later.stopped, isTrue);
    expect(later.t, closeTo(t, 1e-12));
  });

  test('μ = 0 は等速直線運動で止まらない', () {
    const params = KineticFrictionParams(v0: 4, mu: 0);
    expect(kineticFrictionStopTime(params), isNull);
    expect(kineticFrictionStopDistance(params), isNull);
    final s = kineticFrictionAt(params, 2.5);
    expect(s.x, closeTo(10, 1e-12));
    expect(s.v, closeTo(4, 1e-12));
    expect(s.a, closeTo(0, 1e-12));
    expect(s.stopped, isFalse);
  });

  test('初速を 2 倍すると時間は 2 倍、距離は 4 倍。μ を大きくすると両方短くなる', () {
    const slow = KineticFrictionParams(v0: 2, mu: 0.20);
    const fast = KineticFrictionParams(v0: 4, mu: 0.20);
    const rough = KineticFrictionParams(v0: 4, mu: 0.40);
    expect(
      kineticFrictionStopTime(fast),
      closeTo(kineticFrictionStopTime(slow)! * 2, 1e-12),
    );
    expect(
      kineticFrictionStopDistance(fast),
      closeTo(kineticFrictionStopDistance(slow)! * 4, 1e-12),
    );
    expect(kineticFrictionStopTime(rough)!, lessThan(kineticFrictionStopTime(fast)!));
    expect(
      kineticFrictionStopDistance(rough)!,
      lessThan(kineticFrictionStopDistance(fast)!),
    );
  });

  test('スライダーの端でも停止は正で有限。点の間隔はあとほど狭い', () {
    const corners = [
      KineticFrictionParams(v0: kFrictionMinV0, mu: kFrictionMaxMu),
      KineticFrictionParams(v0: kFrictionMaxV0, mu: kFrictionMaxMu),
    ];
    for (final params in corners) {
      final t = kineticFrictionStopTime(params)!;
      final x = kineticFrictionStopDistance(params)!;
      expect(t, greaterThan(0.1));
      expect(t, lessThan(2));
      expect(x, greaterThan(0.05));
      expect(x, lessThan(8));
      final stopped = kineticFrictionAt(params, t + 1);
      expect(stopped.v, closeTo(0, 1e-12));
      expect(stopped.x, closeTo(x, 1e-9));
    }

    const params = KineticFrictionParams(v0: 4, mu: 0.20);
    final strobes = kineticFrictionStrobe(params, kineticFrictionStopTime(params)!);
    expect(strobes.length, greaterThan(4));
    final firstGap = strobes[1].x - strobes[0].x;
    final lastGap = strobes.last.x - strobes[strobes.length - 2].x;
    expect(firstGap, greaterThan(lastGap));
  });

  test('力学の摩擦に水平面上の動摩擦力がある', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final friction = dynamics.subcategories.firstWhere((s) => s.name == '摩擦');
    expect(friction.videos, contains(kineticFriction1D));
    final falling = dynamics.subcategories.firstWhere((s) => s.name == '落下運動');
    expect(falling.videos, isNot(contains(kineticFriction1D)));
  });
}
