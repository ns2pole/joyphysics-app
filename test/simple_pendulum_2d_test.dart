import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/simplePendulum2D.dart';
import 'package:joyphysics/experiment/dynamics/pendulumPeriodMeasurement.dart';

void main() {
  const length = kPendulumDefaultL;

  test('楕円積分 K は既知の値と一致する', () {
    expect(completeEllipticK(0), closeTo(math.pi / 2, 1e-12));
    expect(completeEllipticK(0.5), closeTo(1.685750354812596, 1e-12));
    expect(
      completeEllipticK(math.sqrt(0.5)),
      closeTo(1.854074677301372, 1e-12),
    );
    final k = 0.5;
    final bigK = completeEllipticK(k);
    expect(jacobiElliptic(0, k).sn, closeTo(0, 1e-12));
    expect(jacobiElliptic(0, k).cn, closeTo(1, 1e-12));
    expect(jacobiElliptic(bigK, k).sn, closeTo(1, 1e-9));
    expect(jacobiElliptic(bigK, k).cn, closeTo(0, 1e-9));
    expect(jacobiElliptic(3 * bigK, k).sn, closeTo(-1, 1e-9));
  });

  test('小さい角の周期は振れ角によらず、実験記事の 30 cm と 60 cm と一致する', () {
    final period = pendulumSmallAnglePeriod(length);
    expect(period, closeTo(2 * math.pi * math.sqrt(length / 9.8), 1e-12));
    expect(pendulumSmallAnglePeriod(0.30), closeTo(1.10, 0.005));
    expect(pendulumSmallAnglePeriod(0.60), closeTo(1.55, 0.005));
    expect(pendulumSmallAnglePeriod(4 * length), closeTo(2 * period, 1e-12));

    final slow = pendulumSmallAngleAt(length, 8 * math.pi / 180, 0);
    final wide = pendulumSmallAngleAt(length, 18 * math.pi / 180, 0);
    expect(slow.theta, isNot(closeTo(wide.theta, 1e-3)));
    expect(
      pendulumSmallAngleAt(length, slow.theta, period / 4).theta,
      closeTo(0, 1e-9),
    );
    expect(
      pendulumSmallAngleAt(length, wide.theta, period / 4).theta,
      closeTo(0, 1e-9),
    );
    expect(
      pendulumSmallAngleAt(length, wide.theta, period / 2).theta,
      closeTo(-wide.theta, 1e-9),
    );
  });

  test('厳密な振り子は楕円積分の周期で端と最下点を回る', () {
    const theta0 = math.pi / 2;
    final period = pendulumExactPeriod(length, theta0);
    expect(pendulumPeriodRatio(theta0), closeTo(1.180340599016, 1e-9));
    expect(
      period / pendulumSmallAnglePeriod(length),
      closeTo(1.180340599016, 1e-9),
    );
    expect(pendulumExactPeriod(4 * length, theta0), closeTo(2 * period, 1e-9));

    final start = pendulumExactAt(length, theta0, 0);
    expect(start.theta, closeTo(theta0, 1e-9));
    expect(start.omega, closeTo(0, 1e-9));

    final bottom = pendulumExactAt(length, theta0, period / 4);
    final k = math.sin(theta0 / 2);
    expect(bottom.theta, closeTo(0, 1e-8));
    expect(
      bottom.omega,
      closeTo(-2 * k * math.sqrt(kPendulumG / length), 1e-8),
    );

    expect(
      pendulumExactAt(length, theta0, period / 2).theta,
      closeTo(-theta0, 1e-8),
    );
    expect(
      pendulumExactAt(length, theta0, period).theta,
      closeTo(theta0, 1e-8),
    );
    expect(pendulumExactAt(length, theta0, period).omega.abs(), lessThan(1e-8));

    final later = pendulumExactAt(length, theta0, period / 3 + 40 * period);
    final once = pendulumExactAt(length, theta0, period / 3);
    expect(later.theta, closeTo(once.theta, 1e-8));
    expect(later.omega, closeTo(once.omega, 1e-8));
  });

  test('運動方程式と、小さい角では二つの解が重なること', () {
    const theta0 = 60 * math.pi / 180;
    const dt = 1e-4;
    double accel(double t) {
      final th = pendulumExactAt(length, theta0, t).theta;
      final ahead = pendulumExactAt(length, theta0, t + dt).theta;
      final behind = pendulumExactAt(length, theta0, t + 2 * dt).theta;
      return (behind - 2 * ahead + th) / (dt * dt);
    }

    for (final t in [0.05, 0.4, 0.9, 1.6]) {
      final theta = pendulumExactAt(length, theta0, t + dt).theta;
      expect(accel(t), closeTo(-(kPendulumG / length) * math.sin(theta), 2e-3));
    }

    const small = 10 * math.pi / 180;
    final smallPeriod = pendulumSmallAnglePeriod(length);
    var maxGap = 0.0;
    for (var i = 0; i <= 24; i++) {
      final t = smallPeriod * i / 24;
      final gap =
          (pendulumExactAt(length, small, t).theta -
                  pendulumSmallAngleAt(length, small, t).theta)
              .abs();
      if (gap > maxGap) maxGap = gap;
    }
    expect(maxGap, lessThan(0.02));

    final atSmallQuarter = pendulumSmallAnglePeriod(length) / 4;
    expect(
      pendulumExactAt(length, math.pi / 2, atSmallQuarter).theta.abs(),
      greaterThan(0.25),
    );
  });

  test('60° の周期比は級数と楕円積分が合う', () {
    const theta0 = math.pi / 3;
    expect(pendulumPeriodRatio(theta0), closeTo(1.07318200715, 1e-8));
    expect(
      pendulumPeriodRatioSeries(theta0, terms: 12),
      closeTo(pendulumPeriodRatio(theta0), 1e-8),
    );
    const release = math.pi / 2;
    final start = pendulumExactAt(length, release, 0);
    expect(
      pendulumTensionRatio(
        theta: start.theta,
        omega: start.omega,
        length: length,
      ),
      closeTo(math.cos(release), 1e-8),
    );
    final bottom = pendulumExactAt(
      length,
      release,
      pendulumExactPeriod(length, release) / 4,
    );
    expect(
      pendulumTensionRatio(
        theta: bottom.theta,
        omega: bottom.omega,
        length: length,
      ),
      closeTo(3 - 2 * math.cos(release), 1e-6),
    );

    final bob = pendulumBob(length, 0);
    expect(bob.x, closeTo(0, 1e-12));
    expect(bob.y, closeTo(-length, 1e-12));
    final side = pendulumBob(length, math.pi / 2);
    expect(side.x, closeTo(length, 1e-12));
    expect(side.y.abs(), lessThan(1e-12));
  });

  test('力学の振り子は近似・厳密・比較を一つの記事にまとめてある', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final pendulum = dynamics.subcategories.firstWhere((s) => s.name == '振り子');
    expect(pendulum.videos.map((v) => v.title).toList(), [
      '単振り子の近似と厳密',
      '円錐振り子',
      '単振り子の周期',
    ]);
    expect(pendulum.videos, contains(simplePendulum2D));
    expect(pendulum.videos, contains(pendulumPeriodMeasurement));
    expect(simplePendulum2D.isSimulation, isTrue);
    expect(
      simplePendulum2D.latex,
      pendulumArticleLatex(PendulumArticleMode.compare),
    );
    for (final mode in PendulumArticleMode.values) {
      final html = pendulumArticleLatex(mode);
      expect(html, isNot(contains(r'\dfrac')));
      expect(html, isNot(contains(r'\tfrac')));
    }
    expect(
      pendulumArticleLatex(PendulumArticleMode.approximate),
      contains(r'\sqrt{\frac{l}{g}}'),
    );
    expect(pendulumArticleLatex(PendulumArticleMode.exact), contains('K(k)'));
    expect(
      pendulumArticleLatex(PendulumArticleMode.compare),
      contains(r'\frac{T}{T_{0}}'),
    );
  });
}
